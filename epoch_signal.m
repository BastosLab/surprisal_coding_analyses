function [data] = epoch_signal(nwb,signal,trial_times)
%EPOCH_REWARDS Summary of this function goes here
%   Detailed explanation goes here
signal = nwb.acquisition.get([signal '_1_tracking']).timeseries;
signal = signal.get(signal.keys{1});
dt = mean(diff(signal.timestamps(:)));

idxs = int64(nearest_index(signal.timestamps(:), trial_times(:, 1)));
vrange = [0, int64(mean(trial_times(:, 2) - trial_times(:, 1)) / dt)];
data = epoch_data(permute(signal.data(:), [2, 1]), idxs, vrange);
end