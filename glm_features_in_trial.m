function [stim_muae, predictors] = glm_features_in_trial(muae, pupils, times_in_trial, stims_in_trial)
%GLM_FEATURES
% stim_muae: Stimuli x Samples in Time x Trials
% predictors: Stimuli x Samples in Time x Trials x Features
% Features = [Time in trial, Pupil z-score, Trial, Stimulus Count/Index];
ntrials = size(muae, 3);
nstims = size(stims_in_trial, 1);
stim_indices = stim_time_indices(times_in_trial, stims_in_trial);
ntimes = round(mean(stim_indices(:, 2) - stim_indices(:, 1)));

stim_muae = nan(nstims, ntimes, ntrials);
predictors = nan(nstims, ntimes, ntrials, 4);
for s=1:nstims
    last_idx = stim_indices(s, 1) + ntimes - 1;
    stim_muae(s, :, :) = mean(muae(:, stim_indices(s, 1):last_idx, :), 1);

    predictor = zeros(ntrials, 2);
    predictor(:, 1) = 1:ntrials;
    predictor(:, 2) = s;
    predictor = repmat(permute(predictor, [4, 3, 1, 2]), [1, ntimes, 1, 1]);

    stim_times_in_trial = permute(times_in_trial(:, stim_indices(s, 1):last_idx), [3, 1, 2]);
    predictors(s, :, :, 1) = repmat(stim_times_in_trial, [1, 1, 1, ntrials]);
    predictors(s, :, :, 2) = pupils(:, stim_indices(s, 1):last_idx, :);
    predictors(s, :, :, 3:end) = predictor;
end
end

