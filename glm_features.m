function [stim_muae_zs, predictors] = glm_features(nwb, intervals_mask, baseline)
%GLM_FEATURES Summary of this function goes here
%   Detailed explanation goes here
[trials, stims] = passiveglo_block_times(nwb, intervals_mask);
rewards = epoch_signal(nwb, 'reward', trials);
pupils = epoch_signal(nwb, 'pupil', trials);
pupils = squeeze(mean(pupils(:, 1:500, :), 2))';
[muae_zs, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, ...
    nwb.intervals.get('passive_glo').vectordata.get('correct').data(:), ...
    baseline ...
);
[stim_muae_zs, predictors] = glm_features_in_trial(muae_zs, times_in_trial, stims_in_trial);
predictors = cat(2, predictors, permute(stims, [2, 3, 1]));
end

