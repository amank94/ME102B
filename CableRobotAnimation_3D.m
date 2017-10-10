function [myMovie1] = CableRobotAnimation_3D()


%% Length Determination and Inputs
tic
pt_A = [200,200,700];
pt_B = [450,330,300];
leg = EPP_3D(pt_A, pt_B); % POINTS GO HERE
time_step = 0.1;
V_max = 200; % max allowable effector velocity (mm/s)
A_max = 500; % max allowable effector acceleration (mm/s^2)
V_tol = 0.1; % velocity tolerance (mm/s) for start and end of motion with sigmoid

%% from jpc

g = 981; % mm/s^2

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
ez = 50; % mm
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

%% Sigmoid Calculations

[x_position,y_position,z_position,t] = sigmoidShit(pt_A, pt_B, V_max, A_max, leg, time_step, V_tol);
%% LET'S MAKE A MOVIE

hFigure = figure;
numberOfFrames = length(t);
% Set up the movie structure.
% Preallocate recalledMovie, which will be an array of structures.
% First get a cell array with all the frames.
allTheFrames = cell(numberOfFrames,1);
vidHeight = 1000;
vidWidth = 1000;
allTheFrames(:) = {zeros(vidHeight, vidWidth, 2, 'uint8')};
% Next get a cell array with all the colormaps.
allTheColorMaps = cell(numberOfFrames,1);
allTheColorMaps(:) = {zeros(256, 2)};
% Now combine these to make the array of structures.
myMovie1 = struct('cdata', allTheFrames, 'colormap', allTheColorMaps);
% Create a VideoWriter object to write the video out to a new, different file.
% writerObj = VideoWriter('problem_3.avi');
% open(writerObj);
% Need to change from the default renderer to zbuffer to get it to work right.
% openGL doesn't work and Painters is way too slow.
set(gcf, 'renderer', 'zbuffer');
	
%%

figure()
set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
[x, y] = meshgrid(0:1:1000,0:1:1000);
for frameIndex = 1 : numberOfFrames
	%z = exp(-(x-t(frameIndex)).^2-(y-t(frameIndex)).^2);
	%y = exp(-(x-t(frameIndex)).^2);
%fig1 = subplot(1,2,1)
%{
    % Frame Volume
plot([0,fy],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fy],[fz,fz],'g','LineWidth',2) % Top
plot([fy,fy],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left
%{
% Working Volume
plot([0,wy],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wy],[wzt,wzt],'b','LineWidth',1) % Top
plot([wy,wy],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left
%}
% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(py,pzb,'m*')
plot(py,pzt,'m*')

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')
    %}

DesiredPosition = [x_position(frameIndex),y_position(frameIndex), z_position(frameIndex)]

    if DesiredPosition(1)>wx || DesiredPosition(2)>wy || DesiredPosition(3)>wzt || DesiredPosition(1)<0 || DesiredPosition(2)<0 || DesiredPosition(3)<wzb
      disp('Desired Position is NOT within the working volume.')
    else
       disp('Desired Position is within the working volume.')
    end

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

    WireLength = zeros(8,1);

    for i = 1:length(MountCornerPositionArray)
        WireLength(i) = norm(MountCornerPositionArray(i,:)-EffectorCornerPositionArray(i,:));
    end

    WireUnitVectors = zeros(8,3);
    WireVectors = MountCornerPositionArray-EffectorCornerPositionArray; % vector going from effector to mounts

    for i = 1:length(WireVectors)
        WireUnitVectors(i,:) = WireVectors(i,:) / norm(WireVectors(i,:));
    end

    % Plotting Cable Robot - 3D
  
    plot3([effector1t(1),mount1t(1)],[effector1t(2),mount1t(2)],[effector1t(3),mount1t(3)],'k','LineWidth',3) % bottom
	title('Cable Robot 3D View')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    zlabel('Z (mm)')

    axis([0 1000 0 1000 0 1000])
    hold on
    plot3([effector2t(1),mount2t(1)],[effector2t(2),mount2t(2)],[effector2t(3),mount2t(3)],'k','LineWidth',3) % bottom
    plot3([effector3t(1),mount3t(1)],[effector3t(2),mount3t(2)],[effector3t(3),mount3t(3)],'k','LineWidth',3) % bottom
    plot3([effector4t(1),mount4t(1)],[effector4t(2),mount4t(2)],[effector4t(3),mount4t(3)],'k','LineWidth',3) % bottom

    
    % plot effector
    plot3([effector1t(1),effector2t(1)],[effector1t(2),effector2t(2)],[effector1t(3),effector2t(3)],'b','LineWidth',3) % bottom
    plot3([effector2t(1),effector3t(1)],[effector2t(2),effector3t(2)],[effector2t(3),effector3t(3)],'b','LineWidth',3) % bottom
    plot3([effector3t(1),effector4t(1)],[effector3t(2),effector4t(2)],[effector3t(3),effector4t(3)],'b','LineWidth',3) % bottom
    plot3([effector4t(1),effector1t(1)],[effector4t(2),effector1t(2)],[effector4t(3),effector1t(3)],'b','LineWidth',3) % bottom

    
    caption = sprintf('Top View: Frame #%d of %d, t = %.1f', frameIndex, numberOfFrames, t(frameIndex));
	title(caption, 'FontSize', 20);
    
% fig2 = subplot(1,2,2)
 %{
  % Frame Volume
plot([0,fy],[0,0],'g','LineWidth',2) % Bottom
hold all
plot([0,fy],[fz,fz],'g','LineWidth',2) % Top
plot([fy,fy],[0,fz],'g','LineWidth',2) % Right
plot([0,0],[0,fz],'g','LineWidth',2) % Left
%{
% Working Volume
plot([0,wy],[wzb,wzb],'b','LineWidth',1) % Bottom
plot([0,wy],[wzt,wzt],'b','LineWidth',1) % Top
plot([wy,wy],[wzb,wzt],'b','LineWidth',1) % Right
plot([0,0],[wzb,wzt],'b','LineWidth',1) % Left
%}
% Pickup Locations
plot(0,pzb,'m*')
plot(0,pzt,'m*')
plot(py,pzb,'m*')
plot(py,pzt,'m*')

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')
    
    DesiredPosition = [x_position(frameIndex),y_position(frameIndex), z_position(frameIndex)]

    if DesiredPosition(1)>wx || DesiredPosition(2)>wy || DesiredPosition(3)>wzt || DesiredPosition(1)<0 || DesiredPosition(2)<0 || DesiredPosition(3)<wzb
      disp('Desired Position is NOT within the working volume.')
    else
       disp('Desired Position is within the working volume.')
    end

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

    WireLength = zeros(8,1);

    for i = 1:length(MountCornerPositionArray)
        WireLength(i) = norm(MountCornerPositionArray(i,:)-EffectorCornerPositionArray(i,:));
    end

    WireUnitVectors = zeros(8,3);
    WireVectors = MountCornerPositionArray-EffectorCornerPositionArray; % vector going from effector to mounts

    for i = 1:length(WireVectors)
        WireUnitVectors(i,:) = WireVectors(i,:) / norm(WireVectors(i,:));
    end

    % SIDE VIEW, YZ

% Effector Position
plot([effector1b(2),effector4b(2)],[effector1b(3),effector4b(3)],'c','LineWidth',3) % bottom
plot([effector1t(2),effector4t(2)],[effector1t(3),effector1t(3)],'c','LineWidth',3) % top
plot([effector1b(2),effector1t(2)],[effector1b(3),effector1t(3)],'c','LineWidth',3) % left
plot([effector4b(2),effector4t(2)],[effector4b(3),effector4t(3)],'c','LineWidth',3) % right
plot(DesiredPosition(2),DesiredPosition(3),'c*')

% Wires
plot([EffectorCornerPositionArray(1,2),EffectorCornerPositionArray(1,2)+WireVectors(1,2)],[EffectorCornerPositionArray(1,3),EffectorCornerPositionArray(1,3)+WireVectors(1,3)],'k','LineWidth',3) % bottom
plot([EffectorCornerPositionArray(4,2),EffectorCornerPositionArray(4,2)+WireVectors(4,2)],[EffectorCornerPositionArray(4,3),EffectorCornerPositionArray(4,3)+WireVectors(4,3)],'k','LineWidth',3) % bottom
plot([EffectorCornerPositionArray(5,2),EffectorCornerPositionArray(5,2)+WireVectors(5,2)],[EffectorCornerPositionArray(5,3),EffectorCornerPositionArray(5,3)+WireVectors(5,3)],'k','LineWidth',3) % bottom
plot([EffectorCornerPositionArray(8,2),EffectorCornerPositionArray(8,2)+WireVectors(8,2)],[EffectorCornerPositionArray(8,3),EffectorCornerPositionArray(8,3)+WireVectors(8,3)],'k','LineWidth',3) % bottom

title('YZ Plane: Side View')
xlabel('Y')
ylabel('Z')
    
    
    %cla reset;
	% Enlarge figure to full screen.
% 	set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
	%plot(x,y);
	%axis('tight')
	%zlim([0, 1]);
	caption = sprintf('Side View: Frame #%d of %d, t = %.1f', frameIndex, numberOfFrames, t(frameIndex));
	title(caption, 'FontSize', 20);
 
 %}
 
 
	drawnow;
	thisFrame = getframe(gca);
	% Write this frame out to a new video file.
%  	writeVideo(writerObj, thisFrame);
	myMovie1(frameIndex) = thisFrame;
%    cla(fig1)
%    cla(fig2)
cla reset
end


%{
for frameIndex = 1 : numberOfFrames
	%z = exp(-(x-t(frameIndex)).^2-(y-t(frameIndex)).^2);
    
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

text(fx-200,100+200,'Frame','Color','green')
text(fx-200,100+150,'Pickups','Color','m')
text(fx-200,100+100,'Work Space','Color','b')
text(fx-200,100+50,'Effector','Color','cyan')
text(fx-200,100,'Wires','Color','k')
    
    DesiredPosition = [x_position(frameIndex),y_position(frameIndex), z_position(frameIndex)]

    if DesiredPosition(1)>wx || DesiredPosition(2)>wy || DesiredPosition(3)>wzt || DesiredPosition(1)<0 || DesiredPosition(2)<0 || DesiredPosition(3)<wzb
      disp('Desired Position is NOT within the working volume.')
    else
       disp('Desired Position is within the working volume.')
    end

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

    WireLength = zeros(8,1);

    for i = 1:length(MountCornerPositionArray)
        WireLength(i) = norm(MountCornerPositionArray(i,:)-EffectorCornerPositionArray(i,:));
    end

    WireUnitVectors = zeros(8,3);
    WireVectors = MountCornerPositionArray-EffectorCornerPositionArray; % vector going from effector to mounts

    for i = 1:length(WireVectors)
        WireUnitVectors(i,:) = WireVectors(i,:) / norm(WireVectors(i,:));
    end

    % SIDE VIEW, YZ

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
    
    
    %cla reset;
	% Enlarge figure to full screen.
% 	set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
	%plot(x,y);
	%axis('tight')
	%zlim([0, 1]);
	caption = sprintf('Side View: Frame #%d of %d, t = %.1f', frameIndex, numberOfFrames, t(frameIndex));
	title(caption, 'FontSize', 15);
	drawnow;
	thisFrame = getframe(gca);
	% Write this frame out to a new video file.
%  	writeVideo(writerObj, thisFrame);
	myMovie2(frameIndex) = thisFrame;
    cla reset;
end
%}
% close(writerObj);
message = sprintf('Done creating movie\nDo you want to play it?');
button = questdlg(message, 'Continue?', 'Yes', 'No', 'Yes');
drawnow;	% Refresh screen to get rid of dialog box remnants.
close(hFigure);
if strcmpi(button, 'No')
   return;
end
hFigure = figure;
title('Cable Robot Lives!!!', 'FontSize', 20);
% Get rid of extra set of axes that it makes for some reason.
%axis off;
% Play the movie.
figure()
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
movie(myMovie1);
%movie(myMovie2);
uiwait(helpdlg('Done with demo!'));
%close(hFigure);

end
