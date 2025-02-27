function [muae,predictors] = load_area_sessions(sessions_path)
%LOAD_AREA_SESSIONS Summary of this function goes here
%   Detailed explanation goes here
sessions = load(sessions_path, 'SESSIONS');
sessions = sessions.SESSIONS;
trial_times = nan;
for s=1:size(sessions, 1)
    nwb = nwbRead(sessions{s, 1}, 'ignorecache');
    [~,trial_intervals] = passiveglo_intervals(nwb);
    [session_trial_times] = passiveglo_trial_times(nwb, trial_intervals);
    if isnan(trial_times)
        trial_times = session_trial_times;
    else
        trial_times = cat(1, trial_times, session_trial_times);
    end

    dts = session_trial_times(:, 2) - session_trial_times(:, 1);
    trial_length = mean(dts);
    trial_length_sd = std(dts);
    sessions{s, 1}
    [trial_length, trial_length_sd]

    clear nwb;
end
trial_times(:, 1) = trial_times(:, 1) - 0.5;
trial_times(:, 2) = trial_times(:, 2) + 0.5;
dts = trial_times(:, 2) - trial_times(:, 1);
trial_length = mean(dts);
edge_smoothing = std(dts);
[trial_length, edge_smoothing]
clear trial_times;

muae = nan;
predictors = nan;
for s=1:size(sessions, 1)
    nwb = nwbRead(sessions{s, 1}, 'ignorecache');
    stim_probs = load(sessions{s, 2}, 'stim_probs');
    stim_probs = stim_probs.stim_probs;

    [~,trial_intervals] = passiveglo_intervals(nwb);
    [trials] = passiveglo_trial_times(nwb, trial_intervals);
    trials(:, 2) = trials(:, 1) + trial_length;
    areas = unique(nwb.general_extracellular_ephys_electrodes.vectordata.get("location").data(:));
    probe = find(contains(areas, sessions{s, 3})) - 1;
    [smz, ps] = glm_features(nwb, trials, edge_smoothing, stim_probs, probe);
    ps = cat(3, ps, repmat(permute(s, [3, 1, 2]), [size(ps, 1), size(ps, 2), 1]));
    % ar1s = zeros(size(smz, 1), size(smz, 2), 1);
    % ar1s(2:end, :) = smz(1:end-1, :);
    % ps = cat(3, ps, ar1s);

    if isnan(muae)
        muae = smz;
        predictors = ps;
    else
        muae = cat(2, muae, smz);
        predictors = cat(2, predictors, ps);
    end
end
end

