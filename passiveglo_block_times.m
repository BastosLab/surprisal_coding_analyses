function [trial_times, stim_times, stim_info] = passiveglo_block_times(nwb, stim_probs)
%EPOCH_PASSIVEGLO_BLOCK
% trial_times: Trials x 2
% stim_times: Trials x Stimuli x 2
% stim_info: Trials x Stimuli x Features ([Oddball, Orientation, Sequence type (block), Conditional Surprisal, Marginal Surprisal])
intervals = nwb.intervals.get('passive_glo').vectordata;
correct_intervals = intervals.get('correct').data(:);
block_intervals = strcmp(intervals.get('sequence_type').data(:), 'gloexp');
block_intervals = block_intervals | strcmp(intervals.get('sequence_type').data(:), 'rndctl');
block_intervals = block_intervals | strcmp(intervals.get('sequence_type').data(:), 'seqctl');
block_intervals = block_intervals & logical(correct_intervals);

count_a = cumsum(intervals.get('orientation').data(:) == 45);
count_b = cumsum(intervals.get('orientation').data(:) == 135);
count_nan = cumsum(isnan(intervals.get('orientation').data(:)));
marginalA = count_a ./ ((1:size(count_a, 1))' - count_nan);
marginalB = count_b ./ ((1:size(count_b, 1))' - count_nan);
marginals = cat(2, marginalA, marginalB);

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

trial_times = nan(size(trial_intervals));
trial_times(:, 1) = nwb.intervals.get('passive_glo').start_time.data(trial_intervals(:, 1));
trial_times(:, 2) = nwb.intervals.get('passive_glo').stop_time.data(trial_intervals(:, 2));

% Don't just store start-end here. Also store oddball_status, orientation,
% block number (main = 1, rand ctl = 2, seq ctl = 3). Use those to
% calculate further derived features.
stim_times = nan(size(stimulus_intervals, 1), 4, 2);
stim_info = nan(size(stimulus_intervals, 1), 4, 5);
sequence_types = {'gloexp', 'rndctl', 'seqctl'};
for s = 1:4
    stim_intervals = stimulus_intervals(:, s+1);
    stim_times(:, s, 1) = nwb.intervals.get('passive_glo').start_time.data(stim_intervals);
    stim_times(:, s, 2) = nwb.intervals.get('passive_glo').stop_time.data(stim_intervals);

    if intervals.isKey('oddball_status')
        stim_info(:, s, 1) = intervals.get('oddball_status').data(stim_intervals);
    else
        if s ~= 4
            stim_info(:, s, 1) = zeros(size(stim_info(:, s, 1)));
        else
            is_glo = strcmp(intervals.get('sequence_type').data(stim_intervals), 'gloexp');
            is_a = intervals.get('orientation').data(stim_intervals) == 45;
            is_b = intervals.get('orientation').data(stim_intervals) == 135;
            stim_info(:, s, 1) = int32(is_glo & is_b) + (int32(is_glo & is_a) * 2);
        end
    end
    stim_info(:, s, 2) = intervals.get('orientation').data(stim_intervals);
    stim_sequence_types = intervals.get('sequence_type').data(stim_intervals);
    for seq = 1:numel(stim_sequence_types)
        stim_info(seq, s, 3) = find(strcmp(sequence_types, stim_sequence_types(seq)));
    end
    oddball_status = stim_info(:, s, 1) + 1;
    stim_angles = (stim_info(:, s, 2) == 135) + 1;
    stim_marginals = marginals(stim_intervals, :);
    for t = 1:numel(trial_nums)
        stim_info(t, s, 4) = -log2(stim_probs(oddball_status(t), stim_angles(t), stim_info(t, s, 3)));
        stim_info(t, s, 5) = -log2(stim_marginals(t, stim_angles(t)));
    end
end
stim_info = cat(3, stim_info, cumsum(stim_info(:, :, 4:5), 2));
end