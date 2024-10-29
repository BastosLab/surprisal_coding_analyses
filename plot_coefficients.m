function [] = plot_coefficients(betas,std_devs, area)
%PLOT_COEFFICIENTS Summary of this function goes here
%   Detailed explanation goes here
betas = betas(2:end);
std_devs = std_devs(2:end);
xs = 1:size(betas, 1);
bar(xs, betas);
hold on;
er = errorbar(xs, betas, 2.576 * std_devs, 2.576 * std_devs);
er.Color = [0 0 0];
er.LineStyle = 'none';
xticklabels({'Time in session', 'Pupil width', 'Trial', ...
    'Stimulus Index', 'Oddball', 'Orientation', ...
    'Block type', 'Conditional Surprisal', 'Marginal Surprisal', ...
    'Cumulative Conditional Surprisal', 'Cumulative Marginal Surprisal', ...
    'Session', 'Animal'});
hold off;
title(strcat("Longitudinal regression coefficients (\beta) with 99% confidence intervals (", area, ")"));
end

