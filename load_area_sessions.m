function [stim_muae,predictors] = load_area_sessions(sessions_path)
%LOAD_AREA_SESSIONS Summary of this function goes here
%   Detailed explanation goes here
sessions = load(sessions_path, 'SESSIONS');
sessions = sessions.SESSIONS;
stim_muae = nan;
predictors = nan;
for s=1:size(sessions, 1)
    nwb = nwbRead(sessions{s, 1}, 'ignorecache');
    stim_probs = load(sessions{s, 2}, 'stim_probs');
    stim_probs = stim_probs.stim_probs;

    areas = unique(nwb.general_extracellular_ephys_electrodes.vectordata.get("location").data(:));
    probe = find(areas == sessions{s, 3}) - 1;
    [smz, ps] = glm_features(nwb, 0.5, stim_probs, probe);
    if isnan(stim_muae)
        stim_muae = smz;
        predictors = ps;
    else
        stim_muae = cat(3, stim_muae, smz);
        predictors = cat(3, predictors, ps);
    end
end
end

