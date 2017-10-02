% Johnathan Corvello
% 9.15.2017

%% Things to do 

%{ 
To do:
- 2D vs 3D swapping
- NEED A FUNCTION TO ACCOUNT FOR PULLey to Wynch spool based on position
- motor motion for desired position change
- default tension on bottom cables
- For the work space, we will need to account for the thicknesses of the frame and pulley locations inside the frame. Since the frame tube center axes can be 1000x1000x1000 or the inside faces of the tubes can be 1000x1000x1000 @ally @connor
%}

%{
 Completed:
 - how fast our effector moves ==> ETHAN got this

%}

%{
Parameters That Affect Mass Held

Motor Torque (dynamic/static)
X,Y,Z height of effector
Wynch Finaldrive
Effector Size (minimal)
%}

%{
We can have a secondary mounting scheme like what you are saying though for the faster agility motion
because the deceleration and accel events will involve quite a bit of force
the control of cable tension gets much more difficult
when the object is not light and you try to go fast
since then you are fighting the stretch of the cable as the main deltas between opposing cables. Where increased object weight adds more stabilizing downwards and stretches cables more
make sure we have a centralized controller
because if we're messing with dominos the exact path the end effector takes matters, not just a state function
so youll need to give incremental setpoints
or implement and a MIMO position and velocity controller
if you just tell the strings go from length A to B
physics takes over while the end effector is in motion
and slight mechanical advantage on one string vs another causes it to not move in a straight line to its destination
%}

%% Cable Robot Project

clear all
close all
clc

%% Robot Dimensions Inputs

g = 9.81; % m/s^2

% Cable Volume, Total Volume of Frame
fx = 1000; % mm 
fy = 1000; 
fz = 1000; % 0 for 2D, ## for 3D
Vcable = fx*fy*fz;

% Mount Volume, Pickup Locations
px = fx;
py = fy;
pzb = .4*fz;
pzt = fz;
Vmount = px*py*(pzt-pzb);

% Gap Volume, pos = Gap (effector below bottom mounts), neg = Overlap (effector above bottom mounts)
GapRatio = -.8;
Vgap = fx*fy*GapRatio*pzb;

% Overall Effective Effector - Effector Pickups
ex = 125; % mm 
ey = 125; % mm
ez = 125; % mm
Veffector = ex*ey*ez;

% Working Volume
wx = fx; 
wy = fy;
wzt = pzb*(1-GapRatio);
wzb = 2.9*ez;
Vworking = wx*wy*(wzt-wzb);
VbaseGap = wx*wy*wzb;

% Total Volume = Cable Volume = Mount Volume + Working Volume + Gap ==> Gap
Vtotal = Vmount + Vworking + Vgap + VbaseGap;

if Vtotal == Vcable
    disp('Volumes check out all good')
else
    disp('Volumes DO NOT check out all good')
end

DesiredPosition = [.2*wx,.5*wy,.9*wzt]; % In the geometric center of the end effector!!!! Which we will have to have pulleys inside frame so chillin

if DesiredPosition(1)>wx || DesiredPosition(2)>wy || DesiredPosition(3)>wzt || DesiredPosition(1)<0 || DesiredPosition(2)<0 || DesiredPosition(3)<wzb
    disp('Desired Position is NOT within the working volume.')
else
    disp('Desired Position is within the working volume.')
end

%% End Effector Pickups

% Overall Effective Effector - Effector Pickups
ex = 125; % mm 
ey = 125; % mm
ez = 125; % mm

% Bottom Mounts
effector1b = DesiredPosition + [-ex/2,-ey/2,-ez/2]; % [X, Y, Z] mm
effector2b = DesiredPosition + [ex/2,-ey/2,-ez/2];
effector3b = DesiredPosition + [ex/2,ey/2,-ez/2];
effector4b = DesiredPosition + [-ex/2,ey/2,-ez/2];

% Top Mounts
effector1t = DesiredPosition + [-ex/2,-ey/2,ez/2]; % [X, Y, Z] mm
effector2t = DesiredPosition + [ex/2,-ey/2,ez/2];
effector3t = DesiredPosition + [ex/2,ey/2,ez/2];
effector4t = DesiredPosition + [-ex/2,ey/2,ez/2];

EffectorCornerPositionArray = [effector1b;effector2b;effector3b;effector4b;effector1t;effector2t;effector3t;effector4t];
% Change order of rows if effector corners are not matching to the mounting corners

%% String Vectors Based on Position 3D

% As z of effector increases the leverage with string tensions decreases too

% Bottom Mounts [X, Y, Z] mm
mount1b = [0,0,pzb]; 
mount2b = [px,0,pzb]; 
mount3b = [px,py,pzb]; 
mount4b = [0,py,pzb];

% Top Mounts [X, Y, Z] mm
mount1t = [0,0,pzt]; 
mount2t = [px,0,pzt]; 
mount3t = [px,py,pzt]; 
mount4t = [0,py,pzt];

MountCornerPositionArray = [mount1b;mount2b;mount3b;mount4b;mount1t;mount2t;mount3t;mount4t];

WireLength = zeros(8,1);

for i = 1:length(MountCornerPositionArray)
    WireLength(i) = norm(MountCornerPositionArray(i,:)-EffectorCornerPositionArray(i,:));
end

WireLength

% NEED A FUNCTION TO ACCOUNT FOR wire length from PULLey to Wynch spool based on position


%% Spool Diameter Calc - Max Motion

% X Y Z are where the string pulley is located
% NEED A FUNCTION TO ACCOUNT FOR PULLet to Wynch spool based on position

SpoolLength = 55; % mm
SpoolExtra = 10;
EffectiveSpoolLength = SpoolLength - SpoolExtra;

MaxWireLength = max(WireLength);
WireSafety = 152; % 3in on each end

TotalWireLength = MaxWireLength + WireSafety;

Wirethick = 1.9+.125; %mm
Spacing = 1.75;
Pitch = Wirethick + Spacing  % match to metric all thread

NumTurns = (EffectiveSpoolLength / Pitch)

SpoolDiameter = TotalWireLength / (pi*NumTurns) %mm

%% Motor Torque and Speed Specs
T_motor_Nm = [.45,.225]; % Nm [STALL, MIN TORQUE]
w_motor_rpm = [0, 200]; %rpm  [STALL, MIN SPEED]

motor_shaft_dia = 4.5; %mm
F_shaftdia = T_motor_Nm/(motor_shaft_dia/(2*1000)); % N

%% Wynch Gearing - Single Reduction

gear_motor_pd = 9.6; % mm, primary gear
gear_motor_pitch = .5; % gear pitch
gear_motor_n = 24; % number of teeth

gear_spool_pd = 22; % mm, secondary gear
gear_spool_pitch = .5; 
gear_spool_n = 55; 

finaldrive = 1; %gear_spool_pd / gear_motor_pd

finaldrive_check = gear_spool_n/gear_motor_n;

if round(finaldrive,2) ~= round(finaldrive_check,2)
    disp('error in teeth and pitch diameters')
end

%% String Tension on Spool Max / Min

T_spool_Nm = T_motor_Nm * finaldrive % Nm

F_wire_N = T_spool_Nm / (SpoolDiameter/(1000*2)) % N

disp(['The maximum / minimum tension for one wire is ' num2str(round(F_wire_N(1),1)) ' / ' num2str(round(F_wire_N(2),1)) 'N'])


%% Effector Mass Max / Min

WireUnitVectors = zeros(8,3);
WireTension_X = zeros(8,1);
WireTension_Y = zeros(8,1);
WireTension_Z = zeros(8,1);


nominal_wire_tension = .1; % N
% It being a pick and place, need less dynamic tension
TensionPercentage = .70; % How much tension is being used for statically holding the mass up, what is left 1-.65 is able to be used for dynamics
TensionStatic = F_wire_N(2)*TensionPercentage % NEED TO TAKE MIN TORQUE WHILE MOTOR SPINNING
TensionDynamic = F_wire_N(2)*(1-TensionPercentage)

% When moving we get less tension, need to find min tension while moving at
% a given speed and determine if that is fast or slow for what we want!!

F_wire_static = TensionStatic - nominal_wire_tension % N

% Top Wires using all that is left, Bottom wires only putting out nominal tension
F_wire_static_matrix = [nominal_wire_tension; nominal_wire_tension; nominal_wire_tension; nominal_wire_tension; F_wire_static; F_wire_static; F_wire_static; F_wire_static]
% FIX THE WIRE TENSION so it sums itself regardless of desired position!!!

WireVectors = MountCornerPositionArray-EffectorCornerPositionArray; % vector going from effector to mounts


for i = 1:length(WireVectors)
    WireUnitVectors(i,:) = WireVectors(i,:) / norm(WireVectors(i,:));
end

% Wire Tension in Each Direction
for i = 1:length(WireVectors)
    WireTension_X(i) = sum(F_wire_static_matrix(i)*WireUnitVectors(i,:).*[1,0,0]);
    WireTension_Y(i) = sum(F_wire_static_matrix(i)*WireUnitVectors(i,:).*[0,1,0]);
    WireTension_Z(i) = sum(F_wire_static_matrix(i)*WireUnitVectors(i,:).*[0,0,1]);
end

% Sum of Forces in X, Y, Z directions
Fx_sum = sum(WireTension_X)
Fy_sum = sum(WireTension_Y)
Fz_sum_static = sum(WireTension_Z)

% Allowable Mass
mass_allowable_static = Fz_sum_static / g % kg

%% Plotting Cable Robot - Individual Plots

% FRONT VIEW, XZ
figure(1)

% Frame Volume
plot([0,fx],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fx],[fz,fz],'g','LineWidth',2) % Top
plot([fx,fx],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left

% Working Volume
plot([0,wx],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wx],[wzt,wzt],'b','LineWidth',1) % Top
plot([wx,wx],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(px,pzb,'m*')
plot(px,pzt,'m*')

% Effector Position
plot([effector1b(1),effector2b(1)],[effector1b(3),effector2b(3)],'c','LineWidth',1) % bottom
plot([effector1t(1),effector2t(1)],[effector1t(3),effector1t(3)],'c','LineWidth',1) % top
plot([effector1b(1),effector1t(1)],[effector1b(3),effector1t(3)],'c','LineWidth',1) % left
plot([effector2b(1),effector2t(1)],[effector2b(3),effector2t(3)],'c','LineWidth',1) % right
plot(DesiredPosition(1),DesiredPosition(3),'c*')

% Wires
plot([EffectorCornerPositionArray(1,1),EffectorCornerPositionArray(1,1)+WireVectors(1,1)],[EffectorCornerPositionArray(1,3),EffectorCornerPositionArray(1,3)+WireVectors(1,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(2,1),EffectorCornerPositionArray(2,1)+WireVectors(2,1)],[EffectorCornerPositionArray(2,3),EffectorCornerPositionArray(2,3)+WireVectors(2,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(5,1),EffectorCornerPositionArray(5,1)+WireVectors(5,1)],[EffectorCornerPositionArray(5,3),EffectorCornerPositionArray(5,3)+WireVectors(5,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(6,1),EffectorCornerPositionArray(6,1)+WireVectors(6,1)],[EffectorCornerPositionArray(6,3),EffectorCornerPositionArray(6,3)+WireVectors(6,3)],'k','LineWidth',1) % bottom

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')

title('XZ Plane: Front View')
xlabel('X')
ylabel('Z')



% SIDE VIEW, YZ
figure(2)

% Frame Volume
plot([0,fy],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fy],[fz,fz],'g','LineWidth',2) % Top
plot([fy,fy],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left

% Working Volume
plot([0,wy],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wy],[wzt,wzt],'b','LineWidth',1) % Top
plot([wy,wy],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(py,pzb,'m*')
plot(py,pzt,'m*')

% Effector Position
plot([effector1b(2),effector4b(2)],[effector1b(3),effector4b(3)],'c','LineWidth',1) % bottom
plot([effector1t(2),effector4t(2)],[effector1t(3),effector1t(3)],'c','LineWidth',1) % top
plot([effector1b(2),effector1t(2)],[effector1b(3),effector1t(3)],'c','LineWidth',1) % left
plot([effector4b(2),effector4t(2)],[effector4b(3),effector4t(3)],'c','LineWidth',1) % right
plot(DesiredPosition(2),DesiredPosition(3),'c*')

% Wires
plot([EffectorCornerPositionArray(1,2),EffectorCornerPositionArray(1,2)+WireVectors(1,2)],[EffectorCornerPositionArray(1,3),EffectorCornerPositionArray(1,3)+WireVectors(1,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(4,2),EffectorCornerPositionArray(4,2)+WireVectors(4,2)],[EffectorCornerPositionArray(4,3),EffectorCornerPositionArray(4,3)+WireVectors(4,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(5,2),EffectorCornerPositionArray(5,2)+WireVectors(5,2)],[EffectorCornerPositionArray(5,3),EffectorCornerPositionArray(5,3)+WireVectors(5,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(8,2),EffectorCornerPositionArray(8,2)+WireVectors(8,2)],[EffectorCornerPositionArray(8,3),EffectorCornerPositionArray(8,3)+WireVectors(8,3)],'k','LineWidth',1) % bottom

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')

title('YZ Plane: Side View')
xlabel('Y')
ylabel('Z')



% TOP VIEW, XY
figure(3)

% Frame Volume
plot([0,fx],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fx],[fy,fy],'g','LineWidth',2) % Top
plot([fx,fx],[0,fy],'g','LineWidth',2) % Right
plot([0,0],[0,fy],'g','LineWidth',2) % Left

% Working Volume
plot([0,wx],[0,0],'b','LineWidth',1) % Bottom
plot([0,wx],[wy,wy],'b','LineWidth',1) % Top
plot([wx,wx],[0,wy],'b','LineWidth',1) % Right
plot([0,0],[0,wy],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,0,'m*')
plot(0,py,'m*')
plot(px,0,'m*')
plot(px,py,'m*')

% Effector Position
plot([effector1t(1),effector2t(1)],[effector1t(2),effector2t(2)],'c','LineWidth',1) % bottom
plot([effector1t(1),effector4t(1)],[effector1t(2),effector4t(2)],'c','LineWidth',1) % left
plot([effector2t(1),effector3t(1)],[effector2t(2),effector3t(2)],'c','LineWidth',1) % right
plot([effector3t(1),effector4t(1)],[effector3t(2),effector4t(2)],'c','LineWidth',1) % top
plot(DesiredPosition(1),DesiredPosition(2),'c*')

% Wires
plot([EffectorCornerPositionArray(1,1),EffectorCornerPositionArray(1,1)+WireVectors(1,1)],[EffectorCornerPositionArray(1,2),EffectorCornerPositionArray(1,2)+WireVectors(1,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(2,1),EffectorCornerPositionArray(2,1)+WireVectors(2,1)],[EffectorCornerPositionArray(2,2),EffectorCornerPositionArray(2,2)+WireVectors(2,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(3,1),EffectorCornerPositionArray(3,1)+WireVectors(3,1)],[EffectorCornerPositionArray(3,2),EffectorCornerPositionArray(3,2)+WireVectors(3,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(4,1),EffectorCornerPositionArray(4,1)+WireVectors(4,1)],[EffectorCornerPositionArray(4,2),EffectorCornerPositionArray(4,2)+WireVectors(4,2)],'k','LineWidth',1) % bottom

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')

title('XY Plane: Top View')
xlabel('X')
ylabel('Y')

%% Plotting Cable Robot - Subplots

% FRONT VIEW, XZ
figure(4)

subplot(2,2,3)
% Frame Volume
plot([0,fx],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fx],[fz,fz],'g','LineWidth',2) % Top
plot([fx,fx],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left

% Working Volume
plot([0,wx],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wx],[wzt,wzt],'b','LineWidth',1) % Top
plot([wx,wx],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(px,pzb,'m*')
plot(px,pzt,'m*')

% Effector Position
plot([effector1b(1),effector2b(1)],[effector1b(3),effector2b(3)],'c','LineWidth',1) % bottom
plot([effector1t(1),effector2t(1)],[effector1t(3),effector1t(3)],'c','LineWidth',1) % top
plot([effector1b(1),effector1t(1)],[effector1b(3),effector1t(3)],'c','LineWidth',1) % left
plot([effector2b(1),effector2t(1)],[effector2b(3),effector2t(3)],'c','LineWidth',1) % right
plot(DesiredPosition(1),DesiredPosition(3),'c*')

% Wires
plot([EffectorCornerPositionArray(1,1),EffectorCornerPositionArray(1,1)+WireVectors(1,1)],[EffectorCornerPositionArray(1,3),EffectorCornerPositionArray(1,3)+WireVectors(1,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(2,1),EffectorCornerPositionArray(2,1)+WireVectors(2,1)],[EffectorCornerPositionArray(2,3),EffectorCornerPositionArray(2,3)+WireVectors(2,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(5,1),EffectorCornerPositionArray(5,1)+WireVectors(5,1)],[EffectorCornerPositionArray(5,3),EffectorCornerPositionArray(5,3)+WireVectors(5,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(6,1),EffectorCornerPositionArray(6,1)+WireVectors(6,1)],[EffectorCornerPositionArray(6,3),EffectorCornerPositionArray(6,3)+WireVectors(6,3)],'k','LineWidth',1) % bottom


title('XZ Plane: Front View')
xlabel('X')
ylabel('Z')


% SIDE VIEW, YZ
subplot(2,2,4)
% Frame Volume
plot([0,fy],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fy],[fz,fz],'g','LineWidth',2) % Top
plot([fy,fy],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left

% Working Volume
plot([0,wy],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wy],[wzt,wzt],'b','LineWidth',1) % Top
plot([wy,wy],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(py,pzb,'m*')
plot(py,pzt,'m*')

% Effector Position
plot([effector1b(2),effector4b(2)],[effector1b(3),effector4b(3)],'c','LineWidth',1) % bottom
plot([effector1t(2),effector4t(2)],[effector1t(3),effector1t(3)],'c','LineWidth',1) % top
plot([effector1b(2),effector1t(2)],[effector1b(3),effector1t(3)],'c','LineWidth',1) % left
plot([effector4b(2),effector4t(2)],[effector4b(3),effector4t(3)],'c','LineWidth',1) % right
plot(DesiredPosition(2),DesiredPosition(3),'c*')

% Wires
plot([EffectorCornerPositionArray(1,2),EffectorCornerPositionArray(1,2)+WireVectors(1,2)],[EffectorCornerPositionArray(1,3),EffectorCornerPositionArray(1,3)+WireVectors(1,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(4,2),EffectorCornerPositionArray(4,2)+WireVectors(4,2)],[EffectorCornerPositionArray(4,3),EffectorCornerPositionArray(4,3)+WireVectors(4,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(5,2),EffectorCornerPositionArray(5,2)+WireVectors(5,2)],[EffectorCornerPositionArray(5,3),EffectorCornerPositionArray(5,3)+WireVectors(5,3)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(8,2),EffectorCornerPositionArray(8,2)+WireVectors(8,2)],[EffectorCornerPositionArray(8,3),EffectorCornerPositionArray(8,3)+WireVectors(8,3)],'k','LineWidth',1) % bottom

title('YZ Plane: Side View')
xlabel('Y')
ylabel('Z')


% TOP VIEW, XY
subplot(2,2,1)

% Frame Volume
plot([0,fx],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fx],[fy,fy],'g','LineWidth',2) % Top
plot([fx,fx],[0,fy],'g','LineWidth',2) % Right
plot([0,0],[0,fy],'g','LineWidth',2) % Left

% Working Volume
plot([0,wx],[0,0],'b','LineWidth',1) % Bottom
plot([0,wx],[wy,wy],'b','LineWidth',1) % Top
plot([wx,wx],[0,wy],'b','LineWidth',1) % Right
plot([0,0],[0,wy],'b','LineWidth',1) % Left

% Pickup Locations
plot(0,0,'m*')
plot(0,py,'m*')
plot(px,0,'m*')
plot(px,py,'m*')

% Effector Position
plot([effector1t(1),effector2t(1)],[effector1t(2),effector2t(2)],'c','LineWidth',1) % bottom
plot([effector1t(1),effector4t(1)],[effector1t(2),effector4t(2)],'c','LineWidth',1) % left
plot([effector2t(1),effector3t(1)],[effector2t(2),effector3t(2)],'c','LineWidth',1) % right
plot([effector3t(1),effector4t(1)],[effector3t(2),effector4t(2)],'c','LineWidth',1) % top
plot(DesiredPosition(1),DesiredPosition(2),'c*')

% Wires
plot([EffectorCornerPositionArray(1,1),EffectorCornerPositionArray(1,1)+WireVectors(1,1)],[EffectorCornerPositionArray(1,2),EffectorCornerPositionArray(1,2)+WireVectors(1,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(2,1),EffectorCornerPositionArray(2,1)+WireVectors(2,1)],[EffectorCornerPositionArray(2,2),EffectorCornerPositionArray(2,2)+WireVectors(2,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(3,1),EffectorCornerPositionArray(3,1)+WireVectors(3,1)],[EffectorCornerPositionArray(3,2),EffectorCornerPositionArray(3,2)+WireVectors(3,2)],'k','LineWidth',1) % bottom
plot([EffectorCornerPositionArray(4,1),EffectorCornerPositionArray(4,1)+WireVectors(4,1)],[EffectorCornerPositionArray(4,2),EffectorCornerPositionArray(4,2)+WireVectors(4,2)],'k','LineWidth',1) % bottom

title('XY Plane: Top View')
xlabel('X')
ylabel('Y')

subplot(2,2,2)
axis([0,fx,0,fx])
text(fx/2-200,900,'Frame','Color','green','FontSize',15)
text(fx/2-200,700,'Pickups','Color','m','FontSize',15)
text(fx/2-200,500,'Work Space','Color','b','FontSize',15)
text(fx/2-200,300,'Effector','Color','cyan','FontSize',15)
text(fx/2-200,100,'Wires','Color','k','FontSize',15)


%% Conversion from motor rotation to change in wire length

motor_degreePerstep = 1.8; % deg/step
motor_radPerstep = motor_degreePerstep*pi/180;
spool_radPerstep = motor_radPerstep / finaldrive; 
spool_arcPerRad = (SpoolDiameter/2); % s/theta = r,  s=r*theta*180/pi

wynch_wirelengthPerstep = spool_radPerstep * spool_arcPerRad % arc is equiv to wire length

wynch_wirelengthPerstep_inches = wynch_wirelengthPerstep * .039

%% Motor Signal for Change between two points

Current = [0,0,0];
Desired = [500,500,500];

%% Encoder Precision to wire length

% If encoder precision is greater than motor precision then there is a window of uncertainty
% If encoder is less than " " then we know the motor precision well

detents = 600;
delta_theta = 360/detents;
delta_arc = (SpoolDiameter/2)*delta_theta*pi/180 % mm

delta_arc_inches = delta_arc*.039
