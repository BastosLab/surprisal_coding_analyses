function [trial_nums,stimulus_intervals,trial_intervals] = passiveglo_intervals(nwb)
%PASSIVEGLO_INTERVALS Summary of this function goes here
%   Detailed explanation goes here
intervals = nwb.intervals.get('passive_glo').vectordata;
correct_intervals = intervals.get('correct').data(:);

interval_trial_nums = intervals.get('trial_num').data(:);
if ismember('stimulus_number', intervals.keys)
    interval_stimulus_nums = intervals.get('stimulus_number').data(:);
else
    events = intervals.get('event_code_type').data(:);
    EVENT_TYPES = dictionary([{'fix cue appearance'}, {'presentation 1'}, ...
        {'presentation 2'}, {'presentation 3'}, {'presentation 4'}, ...
        {'reward'}], [1:6]);
    interval_stimulus_nums = EVENT_TYPES(events);
end
trial_nums = unique(interval_trial_nums(logical(correct_intervals)));

trial_intervals = nan(numel(trial_nums), 2);
stimulus_intervals = nan(numel(trial_nums), 5);
for t = 1:numel(trial_nums)
    trial = trial_nums(t);
    trial_intervals(t, 1) = find(interval_trial_nums == trial, 1, 'first');
    trial_intervals(t, 2) = find(interval_trial_nums == trial, 1, 'last');

    for s = 1:5
        stimulus_intervals(t, s) = find(interval_trial_nums == trial & interval_stimulus_nums == s, 1, 'first');
    end
end
end

