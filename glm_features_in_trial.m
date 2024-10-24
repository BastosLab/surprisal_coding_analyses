function [predictors] = glm_features_in_trial(pupils, times_in_trial, stims_in_trial, stim_info)
%GLM_FEATURES
% predictors: Samples in Time x Trials x Features
% Features = [Time in trial, Pupil z-score, Trial, Stimulus Count/Index,
% Oddball, Orientation, Sequence type (block), Conditional Surprisal,
% Marginal Surprisal, Cumulative Conditional Surprisal,
% Cumulative Marginal Surprisal];
ntrials = size(stim_info, 1);
nstims = size(stims_in_trial, 1);
stim_indices = stim_time_indices(times_in_trial, stims_in_trial);
ntimes = size(times_in_trial, 2);

predictors = zeros(ntimes, ntrials, 11);
predictors(:, :, 1) = repmat(permute(times_in_trial, [2, 1]), [1, ntrials]);
predictors(:, :, 2) = pupils(:, 1:ntimes, :);
predictors(:, :, 3) = repmat(1:ntrials, [ntimes, 1]);
for s=1:nstims
    predictors(stim_indices(s, 1):stim_indices(s, 2), :, 4) = s;
    stimulus_predictors = repmat(permute(stim_info(:, s, :), [2, 1, 3]), [stim_indices(s, 2) - stim_indices(s, 1) + 1, 1, 1]);
    predictors(stim_indices(s, 1):stim_indices(s, 2), :, 5:11) = stimulus_predictors;
end
end

