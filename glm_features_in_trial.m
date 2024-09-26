function [stim_muae_zs, predictors] = glm_features_in_trial(muae_zs, pupils, times_in_trial, stims_in_trial)
%GLM_FEATURES
% stim_muae_zs: Stimuli x Samples in Time x Trials
% predictors: Stimuli x Samples in Time x Trials x Features
ntrials = size(muae_zs, 3);
nstims = size(stims_in_trial, 1);
stim_indices = stim_time_indices(times_in_trial, stims_in_trial);
ntimes = round(mean(stim_indices(:, 2) - stim_indices(:, 1)));

stim_muae_zs = nan(nstims, ntimes, ntrials);
predictors = nan(nstims, ntimes, ntrials, 5);
for s=1:nstims
    last_idx = stim_indices(s, 1) + ntimes - 1;
    stim_muae_zs(s, :, :) = mean(muae_zs(:, stim_indices(s, 1):last_idx, :), 1);

    predictor = zeros(ntrials, 3);
    predictor(:, 1) = 1:ntrials;
    predictor(:, 2) = squeeze(mean(stims_in_trial(s, :), 2));
    predictor(:, 3) = s;
    predictor = repmat(permute(predictor, [4, 3, 1, 2]), [1, ntimes, 1, 1]);

    stim_times_in_trial = permute(times_in_trial(:, stim_indices(s, 1):last_idx), [3, 1, 2]);
    predictors(s, :, :, 1) = repmat(stim_times_in_trial, [1, 1, 1, ntrials]);
    predictors(s, :, :, 2) = pupils(:, stim_indices(s, 1):last_idx, :);
    predictors(s, :, :, 3:end) = predictor;
end
end

