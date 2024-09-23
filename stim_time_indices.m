function [indices] = stim_time_indices(times, stim_times)
%STIM_TIME_INDICES Summary of this function goes here
%   Detailed explanation goes here
indices = [];
for s=1:size(stim_times, 1)
    start_idx = nearest_index(squeeze(times(1, :, s)), stim_times(s, 1));
    end_idx = nearest_index(squeeze(times(1, :, s)), stim_times(s, 2));
    idx = cat(2, start_idx, end_idx);
    indices = cat(1, indices, idx);
end
end

