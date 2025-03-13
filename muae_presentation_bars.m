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
    for a=1:size(datastruct.areas, 1)
        area = datastruct.areas{a};
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
    t = tiledlayout(session_area_count, 4);
    title(t, [datastruct.session, ' ', session_type], 'Interpreter', 'none');

    for a= 1:size(datastruct.areas, 1)
        area = datastruct.areas{a};
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
            seqctrl_as = datastruct.stim_info(seqctl_selected, 1, 2) == 45;
            seqctrl_amus = squeeze(mean(presentations.seqctrl(:, seqctrl_as), 2));
            seqctrl_bs = datastruct.stim_info(seqctl_selected, 1, 2) == 135;
            seqctrl_bmus = squeeze(mean(presentations.seqctrl(:, seqctrl_bs), 2));
            seqctrl_mus = cat(1, seqctrl_amus, seqctrl_bmus);
            range_max = max(cat(1, habit_mus, lo_mus, go_mus, rndctrl_mus, seqctrl_mus)');
            range_min = min(cat(1, habit_mus, lo_mus, go_mus, rndctrl_mus, seqctrl_mus)');

            nexttile;
            sems = squeeze(std(presentations.lo(:, 1:50), 0, 2)) / size(presentations.lo(:, 1:50), 2);
            bar(["P1", "P2", "P3", "P4"], habit_mus);
            hold on;
            er = errorbar(1:4, habit_mus, -2 * sems, 2 * sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([min(range_min * 1.25, 0), max(range_max * 1.25, 0)]);
            title(string([area, ', ', 'Habituation']));

            nexttile;
            lo_sems = squeeze(std(presentations.lo, 0, 2)) / size(presentations.lo, 2);
            go_sems = squeeze(std(presentations.go, 0, 2)) / size(presentations.go, 2);
            oddball_mus = zeros(size(lo_mus, 1) * 2, 1);
            oddball_sems = zeros(size(lo_mus, 1) * 2, 1);
            for p = 1:size(lo_mus, 1)
                oddball_mus(p*2-1) = lo_mus(p);
                oddball_mus(p*2) = go_mus(p);

                oddball_sems(p*2-1) = lo_sems(p);
                oddball_sems(p*2) = go_sems(p);
            end
            b = bar(["P1 (LO)", "P1 (GO)", "P2 (LO)", "P2 (GO)", "P3 (LO)", ...
                "P3 (GO)", "P4 (LO)", "P4 (GO)"], oddball_mus, 'FaceColor','flat');
            b.CData(2:2:end, :) = repmat([1. 0. 0.], [4, 1]);
            hold on;
            er = errorbar(1:8, oddball_mus, -2 * oddball_sems, 2 * oddball_sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([min(range_min * 1.25, 0), max(range_max * 1.25, 0)]);
            title(string([area, ', ', 'Oddball/Main Block']));

            nexttile;
            rndctrl_p1_as = datastruct.stim_info(rndctl_selected, 1, 2) == 45;
            rndctrl_p1_amus = squeeze(mean(presentations.rndctrl(1, rndctrl_p1_as), 2));
            rndctrl_p1_asems = squeeze(std(presentations.rndctrl(1, rndctrl_p1_as), 0, 2)) / size(presentations.rndctrl(1, rndctrl_p1_as), 2);
            rndctrl_p1_bs = datastruct.stim_info(rndctl_selected, 1, 2) == 135;
            rndctrl_p1_bmus = squeeze(mean(presentations.rndctrl(1, rndctrl_p1_bs), 2));
            rndctrl_p1_bsems = squeeze(std(presentations.rndctrl(1, rndctrl_p1_bs), 0, 2)) / size(presentations.rndctrl(1, rndctrl_p1_bs), 2);

            rndctrl_p2_as = datastruct.stim_info(rndctl_selected, 2, 2) == 45;
            rndctrl_p2_amus = squeeze(mean(presentations.rndctrl(2, rndctrl_p2_as), 2));
            rndctrl_p2_asems = squeeze(std(presentations.rndctrl(2, rndctrl_p2_as), 0, 2)) / size(presentations.rndctrl(2, rndctrl_p2_as), 2);
            rndctrl_p2_bs = datastruct.stim_info(rndctl_selected, 2, 2) == 135;
            rndctrl_p2_bmus = squeeze(mean(presentations.rndctrl(2, rndctrl_p2_bs), 2));
            rndctrl_p2_bsems = squeeze(std(presentations.rndctrl(2, rndctrl_p2_bs), 0, 2)) / size(presentations.rndctrl(2, rndctrl_p2_bs), 2);

            rndctrl_p3_as = datastruct.stim_info(rndctl_selected, 3, 2) == 45;
            rndctrl_p3_amus = squeeze(mean(presentations.rndctrl(3, rndctrl_p3_as), 2));
            rndctrl_p3_asems = squeeze(std(presentations.rndctrl(3, rndctrl_p3_as), 0, 2)) / size(presentations.rndctrl(3, rndctrl_p3_as), 2);
            rndctrl_p3_bs = datastruct.stim_info(rndctl_selected, 3, 2) == 135;
            rndctrl_p3_bmus = squeeze(mean(presentations.rndctrl(3, rndctrl_p3_bs), 2));
            rndctrl_p3_bsems = squeeze(std(presentations.rndctrl(3, rndctrl_p3_bs), 0, 2)) / size(presentations.rndctrl(3, rndctrl_p3_bs), 2);

            rndctrl_p4_as = datastruct.stim_info(rndctl_selected, 4, 2) == 45;
            rndctrl_p4_amus = squeeze(mean(presentations.rndctrl(4, rndctrl_p4_as), 2));
            rndctrl_p4_asems = squeeze(std(presentations.rndctrl(4, rndctrl_p4_as), 0, 2)) / size(presentations.rndctrl(4, rndctrl_p4_as), 2);
            rndctrl_p4_bs = datastruct.stim_info(rndctl_selected, 4, 2) == 135;
            rndctrl_p4_bmus = squeeze(mean(presentations.rndctrl(4, rndctrl_p4_bs), 2));
            rndctrl_p4_bsems = squeeze(std(presentations.rndctrl(4, rndctrl_p4_bs), 0, 2)) / size(presentations.rndctrl(4, rndctrl_p4_bs), 2);

            rndctrl_mus = cat(1, rndctrl_p1_amus, rndctrl_p1_bmus, rndctrl_p2_amus, rndctrl_p2_bmus, ...
                    rndctrl_p3_amus, rndctrl_p3_bmus, rndctrl_p4_amus, rndctrl_p4_bmus);
            rndctrl_sems = cat(1, rndctrl_p1_asems, rndctrl_p1_bsems, rndctrl_p2_asems, rndctrl_p2_bsems, ...
                rndctrl_p3_asems, rndctrl_p3_bsems, rndctrl_p4_asems, rndctrl_p4_bsems);
            b = bar(["P1 (A)", "P1 (B)", "P2 (A)", "P2 (B)", "P3 (A)", "P3 (B)", "P4 (A)", "P4 (B)"], ...
                rndctrl_mus, 'FaceColor','flat');
            b.CData(2:2:end, :) = repmat([1. 0. 0.], [4, 1]);
            hold on;
            er = errorbar(1:8, rndctrl_mus, -rndctrl_sems, rndctrl_sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([min(range_min * 1.25, 0), max(range_max * 1.25, 0)]);
            title(string([area, ', ', 'Random Control']));

            nexttile;
            seqctrl_as = datastruct.stim_info(seqctl_selected, 1, 2) == 45;
            seqctrl_amus = squeeze(mean(presentations.seqctrl(:, seqctrl_as), 2));
            seqctrl_bs = datastruct.stim_info(seqctl_selected, 1, 2) == 135;
            seqctrl_bmus = squeeze(mean(presentations.seqctrl(:, seqctrl_bs), 2));
            seqctrl_mus = cat(1, seqctrl_amus, seqctrl_bmus);
            asems = squeeze(std(presentations.seqctrl(:, seqctrl_as), 0, 2)) / size(presentations.seqctrl(:, seqctrl_as), 2);
            bsems = squeeze(std(presentations.seqctrl(:, seqctrl_bs), 0, 2)) / size(presentations.seqctrl(:, seqctrl_bs), 2);
            sems = cat(1, asems, bsems);
            b = bar(["P1 (A)", "P1 (B)", "P2 (A)", "P2 (B)", "P3 (A)", "P3 (B)", "P4 (A)", "P4 (B)"], ...
                seqctrl_mus, 'FaceColor','flat');
            b.CData(2:2:end, :) = repmat([1. 0. 0.], [4, 1]);
            hold on;
            er = errorbar(1:8, seqctrl_mus, -2 * sems, 2 * sems);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off;
            ylim([min(range_min * 1.25, 0), max(range_max * 1.25, 0)]);
            title(string([area, ', ', 'Sequence Control']));
        end
    end

    set(fig, 'Position', [885.75,90,1837.323150796894,1384.5])
    saveas(fig, [fs(sess).name, '.png']);
    clear nwb;
end
