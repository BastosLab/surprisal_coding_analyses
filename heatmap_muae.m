function [im] = heatmap_muae(muae_zs, dt, stim_times)
times_in_trial = 0:dt:(size(muae_zs, 2) * dt);
trials = 1:size(muae_zs, 3);

figure;
im = imagesc('XData', times_in_trial, 'YData', trials, 'CData', transpose(squeeze(mean(muae_zs, 1))));
colormap("parula"); colorbar; clim([-1, 1]); xlim([-inf, inf]); ylim([-inf, inf]);
xline(stim_times, '-'); set(gca,'YDir','reverse');
end
