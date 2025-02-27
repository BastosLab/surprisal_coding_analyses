function [zscored_signal] = time_zscore(epoched_signal)
%TIME_ZSCORE Summary of this function goes here
% zscored_signal: Channels x Samples in Time x Trials
flat_signal = reshape(epoched_signal, size(epoched_signal, 1), ...
    size(epoched_signal, 2) * size(epoched_signal, 3));
centered_signal = epoched_signal - mean(flat_signal, 2);
sigma = std(flat_signal, 0, 2);
zscored_signal = centered_signal ./ sigma;
end

