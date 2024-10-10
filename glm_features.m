function [stim_muae, predictors] = glm_features(nwb, offset, stim_probs, p)
%GLM_FEATURES
%stim_muae: Stimuli x Samples in Time x Trials
%predictors: Stimuli x Samples in Time x Trials x Features
% Features = [Time in session, Pupil z-score, Trial, Stimulus Count/Index,
%             Oddball, Orientation, Sequence type (block),
%             Conditional Surprisal, Marginal Surprisal, Cumulative Conditional Surprisal,
%             Cumulative Marginal Surprisal];
[trials, stims, stim_info] = passiveglo_block_times(nwb, stim_probs);
trials(:, 1) = trials(:, 1) - offset;
trials(:, 2) = trials(:, 2) + offset;
pupils = time_zscore(epoch_signal(nwb, 'pupil', trials));
[muae, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, trials, stims, p);
[stim_muae, predictors] = glm_features_in_trial(muae, pupils, times_in_trial, stims_in_trial);
predictors(:, :, :, 1) = predictors(:, :, :, 1) + repmat(permute(stims(:, :, 1), [2, 3, 1, 4]), [1, size(predictors, 2), 1]);
predictors = cat(4, predictors, repmat(permute(stim_info, [2, 4, 1, 3]), [1, size(predictors, 2), 1, 1]));
end
