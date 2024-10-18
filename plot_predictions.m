function [] = plot_predictions(stim_muae_zs, stim_predictors, beta_zs, name)
%PLOT_PREDICTIONS Summary of this function goes here
%   Detailed explanation goes here
predictor_dims = size(stim_predictors);
beta_zs = repmat(permute(beta_zs, [2, 3, 4, 1]), [predictor_dims(1:3), 1]);
stim_recons = dot(stim_predictors, beta_zs(:, :, :, 2:end), 4) + beta_zs(:, :, :, 1);

stim_muae_zs = squeeze(mean(stim_muae_zs, 3));
stim_recons = squeeze(mean(stim_recons, 3));
times_in_session = squeeze(mean(stim_predictors(:, :, :, 1), 3));

figure;
plot(squeeze(times_in_session(1, :)), squeeze(stim_muae_zs(1, :)), "--c", ...
     squeeze(times_in_session(1, :)), squeeze(stim_recons(1, :)), "-b", ...
     squeeze(times_in_session(2, :)), squeeze(stim_muae_zs(2, :)), "--c", ...
     squeeze(times_in_session(2, :)), squeeze(stim_recons(2, :)), "-b", ...
     squeeze(times_in_session(3, :)), squeeze(stim_muae_zs(3, :)), "--c", ...
     squeeze(times_in_session(3, :)), squeeze(stim_recons(3, :)), "-b", ...
     squeeze(times_in_session(4, :)), squeeze(stim_muae_zs(4, :)), "--c", ...
     squeeze(times_in_session(4, :)), squeeze(stim_recons(4, :)), "-b");
ylim([-0.02, 0.025]); title(name); ylabel("MUAe z-score"); xlabel("Time in session (seconds)");
end
