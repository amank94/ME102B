function [stepped_cables] = stepped_cable_lengths(ideal_cable_length, step_length)
stepped_cables = zeros(8,length(ideal_cable_length));
for i = 1:8
    stepped_cables(i,:) = ceil((ideal_cable_length(i,:) - ideal_cable_length(i,1))./step_length).*step_length + ideal_cable_length(i,1);
end

end