function [stim_muae_zs, predictors] = glm_features_in_trial(muae_zs, times_in_trial, stims_in_trial)
%GLM_FEATURES Summary of this function goes here
%   Detailed explanation goes here
nchannels = size(muae_zs, 1);
nstims = size(stims_in_trial, 1);
ntrials = size(muae_zs, 3);
stim_indices = stim_time_indices(times_in_trial, stims_in_trial);

stim_muae_zs = nan(nstims, nchannels, ntrials);
predictors = nan(nstims, 3 + nstims, ntrials);
for s=1:nstims
    stim_timeslices = muae_zs(:, stim_indices(s, 1):stim_indices(s, 2), :);
    stim_muae_zs(s, :, :) = squeeze(mean(stim_timeslices, 2));

    predictor = zeros(3 + nstims, ntrials);
    predictor(s, :) = 1;
    predictor(end-2, :) = 1:ntrials;
    predictor(end-1, :) = stims_in_trial(s, 1);
    predictor(end, :) = s;

    predictors(s, :, :) = predictor;
end
end

