function [muae_zs, times] = muae_from_times(probe_signal,trial_times,baseline)
%MUAE_FROM_TIMES Summary of this function goes here
%   Detailed explanation goes here
[muae, times] = epoch_from_times(probe_signal, trial_times);
freq = probe_signal.starting_time_rate;
muae_bs = baseline_correct(muae, 1:(baseline * freq));
muae_zs = permute(trial_zscore(permute(muae_bs, [1, 3, 2])), [1, 3, 2]);
end

