function [data] = epoch_from_offsetted_times(mua, offset, oddball_times)
%EPOCH_FROM_OFFSETTED_TIMES Summary of this function goes here
%   Detailed explanation goes here
freq = mua.starting_time_rate;
idxs = nearest_index(mua.timestamps(:), oddball_times) + offset;
data = epoch_data(mua.data, idxs, [int64(5 * freq), int64(2 * freq)]);
end
