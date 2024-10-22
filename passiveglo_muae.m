function [muae_zs, times_in_trial, stims_in_trial] = passiveglo_muae(nwb, trials, stims, baseline, p)
%CHANNEL_TIME_FEATURES
%muaez_zs: Channels x Samples in Time x Trials
%times_in_trial: 1 x Samples in Time
%stims_in_trial: Stimuli x 2 Times

stims_in_trial = epoch_stimtimes(trials, stims);
probe0_data = nwb.acquisition.get(['probe_', int2str(p), '_muae']).electricalseries.get(['probe_', int2str(p), '_muae_data']);
[muae_zs, times_in_trial] = muae_from_times(probe0_data, trials, baseline);
end

