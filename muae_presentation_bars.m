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

AREAS_HIERARCHY = {'PFC', 'FEF', 'MST', 'MT', 'V4', 'V3', 'V2', 'V1'}';

for sess = [1:size(fs, 1)]
    load(fs(sess).name);
    fs(sess).name
    datastruct.session

    avg_stim_times = squeeze(mean(datastruct.stim_times, 1));
    avg_stim_times(:, 2) = avg_stim_times(:, 2) + 0.075;
    stim_indices = round(avg_stim_times * 1000);

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

    initial_angles = datastruct.stim_info(los_selected(1:50), 1, 2);
    if all(initial_angles == 45)
        session_type = 'AAAB';
    else
        session_type = 'BBBA';
    end

    session_area_count = 0;
    for a=1:size(AREAS_HIERARCHY, 1)
        area = AREAS_HIERARCHY{a};
        if ~any(strcmp(area, RealAreas))
            continue;
        end
        if size(datastruct.muae{a}, 1) > 0
            session_area_count = session_area_count + 1;
        end
    end
    if session_area_count == 0
        continue;
    end
    fig = figure;
    t = tiledlayout(session_area_count, 5);
    title(t, [datastruct.session, ' ', session_type], 'Interpreter', 'none');

    for a= 1:size(AREAS_HIERARCHY, 1)
        area = AREAS_HIERARCHY{a};
        if ~any(strcmp(area, RealAreas))
            continue;
        end
        if size(datastruct.muae{a}, 1) > 0
            area_muae = datastruct.muae{a};
            
            lo_muae = area_muae(:, :, los_selected);
            go_muae = area_muae(:, :, gos_selected);
            rndctl_muae = area_muae(:, :, rndctl_selected);
            seqctl_muae = area_muae(:, :, seqctl_selected);

            presentations = struct;
            presentations.lo = zeros(4, size(lo_muae, 3));
            presentations.go = zeros(4, size(go_muae, 3));
            presentations.rndctrl = zeros(4, size(rndctl_muae, 3));
            presentations.seqctrl = zeros(4, size(seqctl_muae, 3));
            for p=1:4
                presentations.lo(p, :) = squeeze(mean( ...
                    lo_muae(:, stim_indices(p+1, 1):stim_indices(p+1, 2), :), ...
                    [1, 2]));
                presentations.go(p, :) = squeeze(mean( ...
                    go_muae(:, stim_indices(p+1, 1):stim_indices(p+1, 2), :), ...
                    [1, 2]));
                presentations.rndctrl(p, :) = squeeze(mean( ...
                    rndctl_muae(:, stim_indices(p+1, 1):stim_indices(p+1, 2), :), ...
                    [1, 2]));
                presentations.seqctrl(p, :) = squeeze(mean( ...
                    seqctl_muae(:, stim_indices(p+1, 1):stim_indices(p+1, 2), :), ...
                    [1, 2]));
            end

            habit_mus = squeeze(mean(presentations.lo(:, 1:50), 2));
            lo_mus = squeeze(mean(presentations.lo(:, 51:end), 2));
            go_mus = squeeze(mean(presentations.go, 2));
            rndctrl_mus = squeeze(mean(presentations.rndctrl, 2));
            seqctrl_mus = squeeze(mean(presentations.seqctrl, 2));
            range_max = max(cat(1, lo_mus, go_mus, rndctrl_mus, seqctrl_mus)');
            range_min = min(cat(1, lo_mus, go_mus, rndctrl_mus, seqctrl_mus)');

            nexttile;
            sems = squeeze(std(presentations.lo(:, 1:50), 0, 2)) / size(presentations.lo(:, 1:50), 2);
            bar(["P1", "P2", "P3", "P4"], habit_mus);
            hold on;
            er = errorbar(1:4, habit_mus, -sems, sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([range_min - 1, range_max + 1]);
            title(string([area, ', ', 'Habituation']));

            nexttile;
            sems = squeeze(std(presentations.lo, 0, 2)) / size(presentations.lo, 2);
            bar(["P1", "P2", "P3", "P4"], lo_mus);
            hold on;
            er = errorbar(1:4, lo_mus, -sems, sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([range_min - 1, range_max + 1]);
            title(string([area, ', ', 'Local Oddball']));

            nexttile;
            sems = squeeze(std(presentations.go, 0, 2)) / size(presentations.go, 2);
            bar(["P1", "P2", "P3", "P4"], go_mus);
            hold on;
            er = errorbar(1:4, go_mus, -sems, sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([range_min - 1, range_max + 1]);
            title(string([area, ', ', 'Global Oddball']));

            nexttile;
            sems = squeeze(std(presentations.rndctrl, 0, 2)) / size(presentations.rndctrl, 2);
            bar(["P1", "P2", "P3", "P4"], rndctrl_mus);
            hold on;
            er = errorbar(1:4, rndctrl_mus, -sems, sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([range_min - 1, range_max + 1]);
            title(string([area, ', ', 'Random Control']));

            nexttile;
            sems = squeeze(std(presentations.seqctrl, 0, 2)) / size(presentations.seqctrl, 2);
            bar(["P1", "P2", "P3", "P4"], seqctrl_mus);
            hold on;
            er = errorbar(1:4, seqctrl_mus, -sems, sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([range_min - 1, range_max + 1]);
            title(string([area, ', ', 'Sequence Control']));
        end
    end

    exportgraphics(fig, [fs(sess).name, '.pdf']);
    clear nwb;
end
