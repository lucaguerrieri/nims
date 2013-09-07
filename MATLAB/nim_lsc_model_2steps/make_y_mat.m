function [y_mat] = make_y_mat(out_of_sample_y,n_steps_ahead) 

% arrange y data to be conformable with forecast matrix
y_mat = nan*zeros(length(out_of_sample_y),n_steps_ahead);

for this_step = 1:n_steps_ahead
    y_mat(1:end-this_step+1,this_step) = out_of_sample_y(this_step:end);
end






