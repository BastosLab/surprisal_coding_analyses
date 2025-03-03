function [normed_signal] = baseline_normalize(signals, bstarts, bends)
%BASELINE_ZSCORE z-score the signals relative to the baselines described by
% bstarts and bends, measured in array indices
%   Detailed explanation goes here
for t = 1:size(signals, 3)
    slice = bstarts(t):bends(t);
    signals(:, :, t) = baseline_correct(signals(:, :, t), slice);
end
normed_signal = trial_sem(signals);
end

