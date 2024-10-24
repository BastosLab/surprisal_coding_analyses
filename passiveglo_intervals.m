function [stimulus_intervals,trial_intervals] = passiveglo_intervals(nwb)
%PASSIVEGLO_INTERVALS Summary of this function goes here
%   Detailed explanation goes here
intervals = nwb.intervals.get('passive_glo').vectordata;
correct_intervals = intervals.get('correct').data(:);
block_intervals = strcmp(intervals.get('sequence_type').data(:), 'gloexp');
block_intervals = block_intervals | strcmp(intervals.get('sequence_type').data(:), 'rndctl');
block_intervals = block_intervals | strcmp(intervals.get('sequence_type').data(:), 'seqctl');
block_intervals = block_intervals & logical(correct_intervals);

interval_trial_nums = intervals.get('trial_num').data(:);
interval_stimulus_nums = intervals.get('stimulus_number').data(:);
trial_nums = unique(interval_trial_nums(block_intervals));

trial_intervals = nan(numel(trial_nums), 2);
stimulus_intervals = nan(numel(trial_nums), 5);
for t = 1:numel(trial_nums)
    trial = trial_nums(t);
    trial_intervals(t, 1) = find(interval_trial_nums == trial, 1, 'first');
    trial_intervals(t, 2) = find(interval_trial_nums == trial, 1, 'last');

    for s = 1:5
        stimulus_intervals(t, s) = find(interval_trial_nums == trial & interval_stimulus_nums == s);
    end
end
end

