function [zscored_signal] = time_zscore(epoched_signal)
%TIME_ZSCORE Summary of this function goes here
% zscored_signal: Channels x Samples in Time x Trials
centered_signal = epoched_signal - mean(epoched_signal, 2);
sigma = std(epoched_signal, 0, 2);
zscored_signal = centered_signal ./ sigma;
end

