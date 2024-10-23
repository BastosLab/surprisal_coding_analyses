function [beta,Sigma,E,CovB,logL] = longitudinal_regression(stim_muae, predictors)
%LONGITUDINAL_REGRESSION
% Response matrix [Samples in Time x Trials]
% Design matrices length-(Samples in Time) cell-array of Trials x Features
muae = cat(1, ...
    cat(1, squeeze(stim_muae(1, :, :)), squeeze(stim_muae(2, :, :))), ...
    cat(1, squeeze(stim_muae(3, :, :)), squeeze(stim_muae(4, :, :))));

predictors = cat(1, ...
    cat(1, squeeze(predictors(1, :, :, :)), squeeze(predictors(2, :, :, :))), ...
    cat(1, squeeze(predictors(3, :, :, :)), squeeze(predictors(4, :, :, :))));

temporal_predictors = cell(size(muae, 1), 1);
for t=1:size(predictors, 1)
    temporal_predictors{t} = cat(2, ones(size(muae, 2), 1), squeeze(predictors(t, :, :)));
end

[beta,Sigma,E,CovB,logL] = mvregress(temporal_predictors, muae, 'algorithm', 'cwls');
end
