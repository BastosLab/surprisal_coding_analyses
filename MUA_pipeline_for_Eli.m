%%
clear all; close all
datadir = '/mnt/data/surprisal_coding';
cd(datadir) %main nwb data folder
fs = dir('*.nwb');

load('info_with_manual_areas.mat');
load('glo_stim_probs.mat', 'stim_probs');
PRESTIM_BASELINE = 1550:1700;

savedir = '/mnt/data/surprisal_coding/epoched';
mkdir(savedir);

ProbeInfo = info;
for sess = [1:size(fs, 1)]
    datastruct.areas = unique(ProbeInfo.area);
    datastruct.session = fs(sess).name;
    datastruct.muae = cell(1, length(datastruct.areas));
    datastruct.times_in_trial = cell(1, length(datastruct.areas));

    clearvars nwb;
 
    cd(datadir)
    fs(sess).name
    nwb = nwbRead(fs(sess).name);
    %util.nwbTree(nwb);

    [~,trial_intervals] = passiveglo_intervals(nwb);
    [trials] = passiveglo_trial_times(nwb, trial_intervals);

    if contains(fs(sess).name,'C31')
        PO_offset = 25;
    else
        PO_offset = 18;
    end

    [selected_trials,stim_times, datastruct.stim_info] = passiveglo_block_times(nwb, stim_probs);
    datastruct.stim_times = epoch_to_onset(stim_times, 5, 5.);

    if datastruct.stim_info(1, 1, 2) == 45
        session_type = 'AAAB';
        habituation_angles = [45, 45, 45, 135];
    else
        session_type = 'BBBA';
        habituation_angles = [135, 135, 135, 45];
    end
    habituation = datastruct.stim_info(1:50, :, 2) == repmat(habituation_angles, [50, 1]);
    if ~all(all(habituation))
        fprintf("Session %s has only %d habituation trials!\n", fs(sess).name, sum(all(habituation, 2)));
    end

    % stim_info(:, :, 3) is the block type (1 = main, 2 = rndctrl, 3 =
    % seqctrl)
    
    % do time-wise z-scoring via the baseline period (eg: mean and variance
    % of the baseline period)
    % Sophy also has a script for getting the task-modulated channels
    %get probe names and areas
    ProbeNames = unique(nwb.general_extracellular_ephys_electrodes.vectordata.get('probe').data(:));
    numProbes = length(ProbeNames);
    %get info
    
    for p = 1:numProbes
        curr_probe_indx = contains(ProbeInfo.session,fs(sess).name) & contains(ProbeInfo.probe,ProbeNames{p});
        ProbeNames{p}
        mua_name = ['probe_',num2str(p-1),'_muae'];
        
        mua = nwb.acquisition.get(mua_name).electricalseries.get([mua_name,'_data']);
        muae = epoch_from_offsetted_times(mua, PO_offset, stim_times(:, 5, 1));
        freq = mua.starting_time_rate;
        times = 0:(1/freq):(size(muae, 2) / freq);
        times = times(:, 1:size(muae, 2));

        baseline_starts = repmat(squeeze(PRESTIM_BASELINE(:, 1)), [size(muae, 3), 1]);
        baseline_ends = repmat(squeeze(PRESTIM_BASELINE(:, end)), [size(muae, 3), 1]);
        muae = baseline_normalize(muae, baseline_starts, baseline_ends);
        % Based on Sophy's exact script
        krnl = spks_kernel('psp', 10);
        muae = convn(muae, krnl, 'same');

        for a = 1:length(datastruct.areas)
            curr_area_indx = contains(ProbeInfo.area(curr_probe_indx), datastruct.areas{a});
            if sum(curr_area_indx) ~= 0
                chans = (curr_area_indx & ProbeInfo.chansel_pos(curr_probe_indx))';
                if sum(chans) > 0
                    datastruct.muae{a} = [datastruct.muae{a};muae(chans,:,:)];
                    datastruct.times_in_trial{a} = times;
                end
            end
        end
    end
    
    clearvars -except datastruct fs baseline info ProbeInfo savedir datadir sess stim_probs PRESTIM_BASELINE
    cd(savedir)
    save(sprintf('glo_mua_epoched_%d.mat', sess), 'datastruct', '-v7.3')
    clear datastruct;
end
