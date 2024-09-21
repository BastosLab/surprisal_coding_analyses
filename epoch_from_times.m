function [data] = epoch_from_times(probe_signal,trial_times)
%EPOCH_FROM_TIMES Summary of this function goes here
%   Detailed explanation goes here
freq = probe_signal.starting_time_rate;
idxs = nearest_index(probe_signal.timestamps(:), trial_times(:, 1));
vrange = [0, mean(trial_times(:, 2) - trial_times(:, 1)) * freq];
data = epoch_data(probe_signal.data, idxs, vrange);
end

