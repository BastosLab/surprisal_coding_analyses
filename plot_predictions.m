function [] = plot_predictions(muae, predictors, beta, name)
%PLOT_PREDICTIONS Summary of this function goes here
%   Detailed explanation goes here
predictor_dims = size(predictors);
beta = repmat(permute(beta, [2, 3, 1]), [predictor_dims(1:2), 1]);
recons = dot(predictors, beta(:, :, :), 3);

muae = squeeze(mean(muae, 2));
recons = squeeze(mean(recons, 2));
times_in_session = squeeze(mean(predictors(:, :, 1), 2));

figure;
plot(times_in_session, muae, "-b", times_in_session, recons, "--C");
title(name); ylabel("MUAe (\muV)"); xlabel("Time in session (seconds)");
end

