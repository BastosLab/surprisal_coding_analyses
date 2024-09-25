function [muae_zs, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, intervals_mask, baseline)
%CHANNEL_TIME_FEATURES Summary of this function goes here
%   Detailed explanation goes here

[trials, stims] = passiveglo_block_times(nwb, intervals_mask);
stims_in_trial = epoch_stimtimes(trials, stims);
probe0_data = nwb.acquisition.get('probe_0_muae').electricalseries.get('probe_0_muae_data');
[muae_zs, times_in_trial] = muae_from_times(probe0_data, trials, baseline);
end

