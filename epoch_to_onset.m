function [stims_in_trial] = epoch_to_onset(stim_times, idx, baseline)
%EPOCH_STIMTIMES Summary of this function goes here
%   Detailed explanation goes here
stims_in_trial = stim_times(:, :, :) - stim_times(:, idx, 1) + baseline;
end

