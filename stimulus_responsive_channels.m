function [chans] = stimulus_responsive_channels(muae,times,stim_times)
%STIMULUS_RESPONSIVE_CHANNELS Summary of this function goes here
% Compare time-averages of the 50-250ms after the onset of stim 1 with that
% of 200ms in baseline via a Wilcoxon rank-sum test.
baseline_start = nearest_index(times, stim_times(:, 2, 1) - 0.250);
baseline_end = nearest_index(times, stim_times(:, 2, 1) -  0.050);

p1_start = nearest_index(times, stim_times(:, 2, 1) + 0.050);
p1_end = nearest_index(times, stim_times(:, 2, 1) + 0.250);

baseline_avg = zeros(size(muae, 1), size(muae, 3));
p1_avg = zeros(size(muae, 1), size(muae, 3));
for t = 1:size(muae, 3)
    slice = baseline_start(t):baseline_end(t);
    baseline_avg(:, t) = squeeze(mean(muae(:, slice, t), 2));

    slice = p1_start(t):p1_end(t);
    p1_avg(:, t) = squeeze(mean(muae(:, slice, t), 2));
end

chans = false(size(muae, 1), 1);
for c = 1:size(muae, 1)
    [~, chans(c)] = ranksum(p1_avg(c, :), baseline_avg(c, :));
end
chans = chans';
end

