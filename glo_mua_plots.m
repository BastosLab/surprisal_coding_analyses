%%
clear; close all;

datadir = '/mnt/data/surprisal_coding/';
savedir = '/mnt/data/surprisal_coding/epoched';
cd(savedir) %main nwb data folder
fs = dir('*.mat');

load('info_with_manual_areas.mat');
load('glo_stim_probs.mat', 'stim_probs');

ProbeInfo = info;
Areas = unique(ProbeInfo.area);
fake_areas = strcmp(Areas, 'BadElectrode') | strcmp(Areas, 'OutOfBrain') | strcmp(Areas, 'placeholder');
RealAreas = Areas(~fake_areas);

AreaMuas = struct;
for a=1:size(RealAreas, 1)
    area = RealAreas(a);
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

    nwb = nwbRead([datadir, datastruct.session]);
    intervals = nwb.intervals.get('passive_glo').vectordata;
    interval_trial_nums = intervals.get('trial_num').data(:);
    [selected_trials,~,~] = passiveglo_block_times(nwb, stim_probs);

    correct_intervals = logical(intervals.get('correct').data(:));
    lo_intervals = logical(intervals.get('lo_gloexp').data(:));
    lo_trials = unique(interval_trial_nums(lo_intervals & correct_intervals));
    los_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        los_selected(s) = any(lo_trials == selected_trials(s));
    end

    go_intervals = logical(intervals.get('go_gloexp').data(:));
    go_trials = unique(interval_trial_nums(go_intervals & correct_intervals));
    gos_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        gos_selected(s) = any(go_trials == selected_trials(s));
    end

    rndctl_intervals = logical(intervals.get('rndctl').data(:));
    rndctl_trials = unique(interval_trial_nums(rndctl_intervals & correct_intervals));
    rndctl_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        rndctl_selected(s) = any(rndctl_trials == selected_trials(s));
    end

    seqctl_intervals = logical(intervals.get('seqctl').data(:));
    seqctl_trials = unique(interval_trial_nums(seqctl_intervals & correct_intervals));
    seqctl_selected = false(size(selected_trials, 1), 1);
    for s =1:size(selected_trials, 1)
        seqctl_selected(s) = any(seqctl_trials == selected_trials(s));
    end

    for a= 1:size(datastruct.areas, 1)
        area = datastruct.areas{a};
        if ~any(strcmp(area, RealAreas))
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

AREAS_HIERARCHY = {'PFC', 'FEF', 'MST', 'MT', 'V4', 'V3', 'V2', 'V1'}';
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
    colorbar; clim([-25, 50]);
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
        xline((avg_stim_times(s, 2) + 0.075) * 1000, '--r');
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
    xline(0);
    title(sprintf('%s (Local Oddball)', area));

    nexttile;
    area_go = squeeze(mean(AreaMuas.(area).go(:, p1_on:p1_off, :), 3))';
    times = 1:size(area_go, 1);
    plot((times - 51)', area_go, 'b');
    xline(0);
    title(sprintf('%s (Global Oddball)', area));
end