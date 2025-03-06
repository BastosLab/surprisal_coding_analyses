function [chans] = glo_chansel(muae, stim_info)
%GLO_CHANSEL Summary of this function goes here
%   Detailed explanation goes here

CHANSEL_BASELINE_START = 1500;
CHANSEL_BASELINE_END = 1700;
CHANSEL_STIM_START = 1950;
CHANSEL_STIM_END = 2150;

lo_trials = (stim_info(:, 4, 1) == 1) & (stim_info(:, 4, 3) == 1);
muae_lo = muae(:, :, lo_trials);
chans = zeros(size(muae,1), 1);
for c = 1:length(chans)
    muae_lobs = squeeze(mean(muae_lo(c, CHANSEL_BASELINE_START:CHANSEL_BASELINE_END, :), 2));
    muae_lostim = squeeze(mean(muae_lo(c, CHANSEL_STIM_START:CHANSEL_STIM_END, :), 2));
    [~,chans(c),stats(c)] = ranksum(muae_lobs, muae_lostim);
end
chans = ([stats.zval]<0 & logical(chans)')';
end

