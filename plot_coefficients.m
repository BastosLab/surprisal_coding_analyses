function [] = plot_coefficients(betas,std_devs)
%PLOT_COEFFICIENTS Summary of this function goes here
%   Detailed explanation goes here
xs = 1:size(betas, 1);
bar(xs, betas);
hold on;
er = errorbar(xs, betas, 2.576 * std_devs, 2.576 * std_devs);
er.Color = [0 0 0];
er.LineStyle = 'none';
xticklabels({'Y-intercept', 'Time in session', 'Pupil width', 'Trial', ...
    'Stimulus Index', 'Oddball', 'Orientation', ...
    'Block type', 'Conditional Surprisal', 'Marginal Surprisal', ...
    'Cumulative Conditional Surprisal', 'Cumulative Marginal Surprisal'});
hold off;
title("Longitudinal regression coefficients (\beta) with 99% confidence intervals");
end

