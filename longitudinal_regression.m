function [beta,Sigma,E,CovB,logL] = longitudinal_regression(muae, predictors)
%LONGITUDINAL_REGRESSION
% Response matrix [Samples in Time x Trials]
% Design matrices length-(Samples in Time) cell-array of Trials x Features
temporal_predictors = cell(size(muae, 1), 1);
for t=1:size(predictors, 1)
    temporal_predictors{t} = cat(2, ones(size(muae, 2), 1), squeeze(predictors(t, :, :)));
end

[beta,Sigma,E,CovB,logL] = mvregress(temporal_predictors, muae, 'algorithm', 'cwls');
end
