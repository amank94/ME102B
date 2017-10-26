function [step_length] = step_length_calculator(spr, drive_ratio, spool_radius)

step_length = (pi*2*spool_radius)/(spr*drive_ratio); % arc length swept by each step (i.e. cable length change)

end