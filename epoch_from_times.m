function [data, times] = epoch_from_times(probe_signal,trial_times,smoothing)
%EPOCH_FROM_TIMES Summary of this function goes here
%   Detailed explanation goes here
freq = probe_signal.starting_time_rate;
idxs = nearest_index(probe_signal.timestamps(:), trial_times(:, 1));
vrange = [0, mean(trial_times(:, 2) - trial_times(:, 1)) * freq];
data = epoch_data(probe_signal.data, idxs, vrange);
times = 0:(1/freq):(size(data, 2) / freq);
times = times(:, 1:size(data, 2));
data = smoothdata(data, 2, "gaussian", smoothing * freq);
end
