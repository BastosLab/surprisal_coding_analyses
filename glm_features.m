function [stim_muae_zs, predictors] = glm_features(nwb, intervals_mask, baseline)
%GLM_FEATURES
%stim_muae_zs: Stimuli x Samples in Time x Trials
%predictors: Stimuli x Samples in Time x Trials x Features
[trials, stims, stim_info] = passiveglo_block_times(nwb, intervals_mask);
rewards = epoch_signal(nwb, 'reward', trials);
pupils = epoch_signal(nwb, 'pupil', trials);
pupils = squeeze(mean(pupils(:, 1:500, :), 2))';
[muae_zs, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, trials, stims, baseline);
[stim_muae_zs, predictors] = glm_features_in_trial(muae_zs, times_in_trial, stims_in_trial);
stim_info = cat(3, stims, stim_info);
predictors = cat(4, predictors, repmat(permute(stim_info, [2, 4, 1, 3]), [1, size(predictors, 2), 1, 1]));
end

