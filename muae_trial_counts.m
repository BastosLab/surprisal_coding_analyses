%%
clear; close all;

datadir = '/mnt/data/surprisal_coding/';
savedir = '/mnt/data/surprisal_coding/epoched';
cd(savedir) %main nwb data folder
fs = dir('*.mat');

load('info_with_manual_areas.mat');
load('glo_stim_probs.mat', 'stim_probs');

ProbeInfo = info;
Areas = unique(ProbeInfo.area);
fake_areas = strcmp(Areas, 'BadElectrode') | strcmp(Areas, 'OutOfBrain') | strcmp(Areas, 'placeholder');
RealAreas = Areas(~fake_areas);

AREAS_HIERARCHY = {'PFC', 'FEF', 'MST', 'MT', 'V4', 'V3', 'V2', 'V1'}';
trial_counts = table('Size', [size(fs, 1) 8], 'VariableTypes', ["string", "string", ...
    "int32", "int32", "int32", "int32", "int32", "int32"], 'VariableNames', ["Session", "Pattern", ...
    "Habituation", "LO", "GO", "RandomControl", "SequenceControl", "Total"]);

for sess = [1:size(fs, 1)]
    load(fs(sess).name);
    fs(sess).name
    datastruct.session

    avg_stim_times = squeeze(mean(datastruct.stim_times, 1));
    avg_stim_times(:, 2) = avg_stim_times(:, 2) + 0.075;
    stim_indices = round(avg_stim_times * 1000);

    nwb = nwbRead([datadir, datastruct.session]);
    intervals = nwb.intervals.get('passive_glo').vectordata;
    interval_trial_nums = intervals.get('trial_num').data(:);
    [selected_trials,~,~] = passiveglo_block_times(nwb, stim_probs);
    if datastruct.stim_info(1, 1, 2) == 45
        session_type = 'AAAB';
        habituation_angles = [45, 45, 45, 135];
    else
        session_type = 'BBBA';
        habituation_angles = [135, 135, 135, 45];
    end
    habituation = all(datastruct.stim_info(1:50, :, 2) == repmat(habituation_angles, [50, 1]), 2);

    correct_intervals = logical(intervals.get('correct').data(:));
    lo_intervals = logical(intervals.get('lo_gloexp').data(:));
    lo_trials = unique(interval_trial_nums(lo_intervals & correct_intervals));
    los_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        los_selected(s) = any(lo_trials == selected_trials(s));
    end

    go_intervals = logical(intervals.get('go_gloexp').data(:));
    go_trials = unique(interval_trial_nums(go_intervals & correct_intervals));
    gos_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        gos_selected(s) = any(go_trials == selected_trials(s));
    end

    rndctl_intervals = logical(intervals.get('rndctl').data(:));
    rndctl_trials = unique(interval_trial_nums(rndctl_intervals & correct_intervals));
    rndctl_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        rndctl_selected(s) = any(rndctl_trials == selected_trials(s));
    end

    seqctl_intervals = logical(intervals.get('seqctl').data(:));
    seqctl_trials = unique(interval_trial_nums(seqctl_intervals & correct_intervals));
    seqctl_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        seqctl_selected(s) = any(seqctl_trials == selected_trials(s));
    end

    trial_counts(sess, :) = {datastruct.session, session_type, sum(habituation), ...
        sum(los_selected) - sum(habituation), sum(gos_selected), sum(rndctl_selected), ...
        sum(seqctl_selected), length(unique(interval_trial_nums(correct_intervals)))};

    clear nwb;
end
writetable(trial_counts, "trial_counts.csv");