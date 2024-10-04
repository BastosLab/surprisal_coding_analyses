function [beta,Sigma,E,CovB,logL] = longitudinal_regression(stim_muae_zs, predictors)
%LONGITUDINAL_REGRESSION
% Response matrix [Samples in Time x Trials]
% Design matrices length-(Samples in Time) cell-array of Trials x Features
onset_muae_zs = squeeze(stim_muae_zs(1, :, :));
onset_predictors = squeeze(predictors(1, :, :, :));
oddball_muae_zs = squeeze(stim_muae_zs(4, :, :));
oddball_predictors = squeeze(predictors(4, :, :, :));

muae_zs = cat(1, onset_muae_zs, oddball_muae_zs);
temporal_predictors = cell(size(muae_zs, 1), 1);
for t=1:size(onset_predictors, 1)
    temporal_predictors{t} = cat(2, ones(size(muae_zs, 2), 1), squeeze(onset_predictors(t, :, :)));
end
for t=1:size(oddball_predictors, 1)
    s = t + size(onset_predictors, 1);
    temporal_predictors{s} = cat(2, ones(size(muae_zs, 2), 1), squeeze(oddball_predictors(t, :, :)));
end

[beta,Sigma,E,CovB,logL] = mvregress(temporal_predictors, muae_zs);
end
