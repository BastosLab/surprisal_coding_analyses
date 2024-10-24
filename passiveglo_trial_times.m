function [trial_times] = passiveglo_trial_times(nwb, trial_intervals)
%PASSIVEGLO_TRIAL_TIMES Summary of this function goes here
%   Detailed explanation goes here
trial_times = nan(size(trial_intervals));
trial_times(:, 1) = nwb.intervals.get('passive_glo').start_time.data(trial_intervals(:, 1));
trial_times(:, 2) = nwb.intervals.get('passive_glo').stop_time.data(trial_intervals(:, 2));
end

