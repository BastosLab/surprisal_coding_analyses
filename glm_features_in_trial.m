function [predictors] = glm_features_in_trial(muae, pupils, times_in_trial, stims_in_trial)
%GLM_FEATURES
% predictors: Samples in Time x Trials x Features
% Features = [Time in trial, Pupil z-score, Trial, Stimulus Count/Index];
ntrials = size(muae, 3);
nstims = size(stims_in_trial, 1);
stim_indices = stim_time_indices(times_in_trial, stims_in_trial);
stim_length = round(mean(stim_indices(:, 2) - stim_indices(:, 1)));
ntimes = size(muae_zs, 2);

predictors = nan(ntimes, ntrials, 4);
predictors(:, :, 1) = repmat(permute(times_in_trial, [2, 1]), [1, ntrials]);
predictors(:, :, 2) = pupils;
predictors(:, :, 3) = 1:ntrials;
for s=1:nstims
    predictors(stim_indices(s, 1):stim_indices(s, 2), :, 4) = s;
end
end

