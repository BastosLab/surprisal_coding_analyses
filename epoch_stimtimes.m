function [stims_in_trial] = epoch_stimtimes(trial_times,stim_times)
%EPOCH_STIMTIMES Summary of this function goes here
%   Detailed explanation goes here
stims_in_trial = stim_times(:, :, :) - permute(trial_times(:, 1), [1, 3, 2]);
stims_in_trial = squeeze(mean(stims_in_trial, 1));
end

