function [beta, std_devs, logL, pval] = test_area_sessions(sessions, area)
%TEST_AREA_SESSIONS Summary of this function goes here
%   Detailed explanation goes here
[stim_muae_zs, predictors] = load_area_sessions(sessions);
[beta,Sigma,E,CovB,logL] = longitudinal_regression(stim_muae_zs, predictors);
std_devs = sqrt(diag(CovB));
[beta, std_devs]
plot_coefficients(beta, sqrt(diag(CovB)));
plot_predictions(stim_muae_zs, predictors, beta, area);

[b,S,EE,C,logL_null] = longitudinal_regression(stim_muae_zs, predictors(:, :, :, 1:end-4));
LR = 2 * (logL - logL_null);
pval = 1 - chi2cdf(LR,4);
pval
end

