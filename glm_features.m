function [muae, predictors] = glm_features(nwb, trials, smoothing, stim_probs, p)
%GLM_FEATURES
%muae: Samples in Time x Trials
%predictors: Stimuli x Samples in Time x Trials x Features
% Features = [Time in session, Pupil z-score, Trial, Stimulus Count/Index,
%             Oddball, Orientation, Sequence type (block),
%             Conditional Surprisal, Marginal Surprisal, Cumulative Conditional Surprisal,
%             Cumulative Marginal Surprisal];
[stims, stim_info] = passiveglo_block_times(nwb, stim_probs);
pupils = time_zscore(epoch_signal(nwb, 'pupil', trials));
[muae, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, trials, smoothing, stims, p);
predictors = glm_features_in_trial(pupils, times_in_trial, stims_in_trial, stim_info);
predictors(:, :, 1) = predictors(:, :, 1) + repmat(permute(trials(:, 1), [2, 1]), [size(predictors, 1), 1]);
end
