%%
clear; close all;

savedir = '/mnt/data/epoched_mouse_passiveglo/';
cd(savedir) %main nwb data folder
fs = dir('*.mat');

load('glo_stim_probs.mat', 'stim_probs');

AREAS_HIERARCHY = {'V1', 'LM', 'RL', 'AL', 'PM', 'AM'}';

AreaMuas = struct;
for a=1:size(AREAS_HIERARCHY, 1)
    area = AREAS_HIERARCHY(a);
    area = area{1};
    AreaMuas.(area) = struct;
    AreaMuas.(area).num_channels = 0;
    AreaMuas.(area).lo = zeros(1, 7001, 0);
    AreaMuas.(area).go = zeros(1, 7001, 0);
    AreaMuas.(area).rndctrl = zeros(1, 7001, 0);
    AreaMuas.(area).seqctrl = zeros(1, 7001, 0);
end

for sess = [1:size(fs, 1)]
    load(fs(sess).name);
    fs(sess).name
    datastruct.session

    selected_trials = 1:size(datastruct.stim_info, 1);
    % Oddball status of last presentation = local, block = main.
    lo_trials = datastruct.stim_info(:, 4, 1) == 1 & datastruct.stim_info(:, 4, 3) == 1;
    los_selected = selected_trials(lo_trials);
    % Oddball status of last presentation = global, block = main.
    go_trials = datastruct.stim_info(:, 4, 1) == 2 & datastruct.stim_info(:, 4, 3) == 1;
    gos_selected = selected_trials(go_trials);
    % Random control block
    rndctl_selected = selected_trials(datastruct.stim_info(:, 4, 3) == 2);
    seqctl_selected = selected_trials(datastruct.stim_info(:, 4, 3) == 3);

    num_trials = size(gos_selected, 2) + size(los_selected, 2) + size(seqctl_selected, 2) + size(rndctl_selected, 2);
    num_trials

    for a= 1:size(datastruct.areas, 1)
        area = datastruct.areas{a};
        if ~any(strcmp(area, AREAS_HIERARCHY))
            continue;
        end
        if size(datastruct.muae{a}, 1) > 0
            AreaMuas.(area).num_channels = AreaMuas.(area).num_channels + size(datastruct.muae{a}, 1);
            area_muae = datastruct.muae{a};
            
            lo_muae = mean(area_muae(:, :, los_selected), 1);
            AreaMuas.(area).lo = cat(3, AreaMuas.(area).lo, lo_muae);

            go_muae = mean(area_muae(:, :, gos_selected), 1);
            AreaMuas.(area).go = cat(3, AreaMuas.(area).go, go_muae);

            rndctl_muae = mean(area_muae(:, :, rndctl_selected), 1);
            AreaMuas.(area).rndctrl = cat(3, AreaMuas.(area).rndctrl, rndctl_muae);

            seqctl_muae = mean(area_muae(:, :, seqctl_selected), 1);
            AreaMuas.(area).seqctrl = cat(3, AreaMuas.(area).seqctrl, seqctl_muae);
        end
    end

    clear nwb;
end

avg_stim_times = squeeze(mean(datastruct.stim_times, 1));

figure;
tiledlayout(size(AREAS_HIERARCHY, 1), 1);
for a = 1:size(AREAS_HIERARCHY, 1)
    area = AREAS_HIERARCHY(a);
    area = area{1};

    nexttile;
    oddball_muae = cat(3, AreaMuas.(area).lo, AreaMuas.(area).go);
    area_muae = cat(3, oddball_muae, AreaMuas.(area).rndctrl, AreaMuas.(area).seqctrl);
    imagesc(squeeze(area_muae)');
    yline(size(AreaMuas.(area).lo, 3));
    yline(size(oddball_muae, 3));
    yline(size(oddball_muae, 3) + size(AreaMuas.(area).rndctrl, 3));
    for s = 2:size(avg_stim_times, 1)
        xline(avg_stim_times(s, 1) * 1000, '--g');
        xline(avg_stim_times(s, 2) * 1000, '--r');
    end
    colorbar; clim([-7, 7]);
    xlabel("Time in trial (milliseconds)"); ylabel("Trial number");

    title(sprintf(['All trials (', area, ', N=%d)'], AreaMuas.(area).num_channels));
end

figure;
tiledlayout(size(AREAS_HIERARCHY, 1), 1);
for a = 1:size(AREAS_HIERARCHY, 1)
    area = AREAS_HIERARCHY(a);
    area = area{1};

    nexttile;
    plot(squeeze(mean(AreaMuas.(area).lo, 3)), 'r');

    hold on;
    plot(squeeze(mean(AreaMuas.(area).go, 3))', 'b');
    for s = 2:size(avg_stim_times, 1)
        xline(avg_stim_times(s, 1) * 1000, '--g');
        xline((avg_stim_times(s, 2) + 0.150) * 1000, '--r');
    end

    legend('Local oddball', 'Global oddball');
    title(sprintf([area, '(N=%d)'], AreaMuas.(area).num_channels));
end

figure;
tiledlayout(size(AREAS_HIERARCHY, 1), 2);
p1_on = int64((avg_stim_times(2, 1) - 0.050) * 1000);
p1_off = int64((avg_stim_times(2, 2) + 0.200) * 1000);

for a = 1:size(AREAS_HIERARCHY, 1)
    area = AREAS_HIERARCHY(a);
    area = area{1};

    nexttile;
    area_lo = squeeze(mean(AreaMuas.(area).lo(:, p1_on:p1_off, :), 3))';
    times = 1:size(area_lo, 1);
    plot((times - 51)', area_lo, 'r');
    xline(0); xlim([-60, 710]); ylim([0, 0.31]);
    title(sprintf('%s (Local Oddball)', area));

    nexttile;
    area_go = squeeze(mean(AreaMuas.(area).go(:, p1_on:p1_off, :), 3))';
    times = 1:size(area_go, 1);
    plot((times - 51)', area_go, 'b');
    xline(0); xlim([-60, 710]); ylim([0, 0.31]);
    title(sprintf('%s (Global Oddball)', area));
end
sgtitle('Convolved SUA (Presentation 1)');