function [beta,Sigma,E,CovB,logL] = longitudinal_regression(stim_muae_zs, predictors)
%LONGITUDINAL_REGRESSION
onset_muae_zs = squeeze(stim_muae_zs(1, :, :));
onset_predictors = squeeze(predictors(1, :, :, :));
oddball_muae_zs = squeeze(stim_muae_zs(4, :, :));
oddball_predictors = squeeze(predictors(4, :, :, :));

muae_zs = cat(1, onset_muae_zs, oddball_muae_zs)';
trial_predictors = cell(size(muae_zs, 1), 1);
for t=1:size(stim_muae_zs, 3)
    trial_predictors{t} = cat(1, squeeze(onset_predictors(:, t, :)), squeeze(oddball_predictors(:, t, :)));
    trial_predictors{t} = cat(2, ones(size(muae_zs, 2), 1), trial_predictors{t});
end

[beta,Sigma,E,CovB,logL] = mvregress(trial_predictors, muae_zs);
end

