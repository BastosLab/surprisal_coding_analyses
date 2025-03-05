clear all; close all

datadir = '/mnt/data/surprisal_coding'; 
cd(datadir) %main nwb data folder;
fs = dir('*.nwb');
load('/home/eli/Documents/MATLAB/surprisal_coding_analyses/info_with_manual_areas.mat');
ProbeInfo = info;
baseline_prestim = [4800:5000];
baseline_pretrial = [1500:1800];


for sess = 1:size(fs,1)
    %chansel times
    b_t1 = 1500;
    b_t2 = 1700;
    
    s_t1 = 1950;
    s_t2 = 2150;
    
    % epoch time
    cd(datadir)
    fs(sess).name
    nwb = nwbRead(fs(sess).name);
    %util.nwbTree(nwb);
    
    %get probe names and areas
    ProbeNames = unique(nwb.general_extracellular_ephys_electrodes.vectordata.get('probe').data(:));
    numProbes = length(ProbeNames);
    %get info
    start_times= nwb.intervals.get('passive_glo').start_time.data(:);
    gl_info=nwb.intervals.get('passive_glo');
    go_times = gl_info.vectordata.get('go_gloexp').data(:);
    lo_times = gl_info.vectordata.get('lo_gloexp').data(:);
    correct = gl_info.vectordata.get('correct').data(:);
    go_seqctl = gl_info.vectordata.get('go_seqctl').data(:);
    igo_seqctl = gl_info.vectordata.get('igo_seqctl').data(:);
    
    corrGo_seqctl = go_seqctl & correct;
    corrIgo_seqctl = igo_seqctl & correct;
    
    corrGoTime = go_times & correct;
    corrLoTime = lo_times & correct;
    
    for p = 1:numProbes
        curr_probe_indx = contains(ProbeInfo.session,fs(sess).name) & contains(ProbeInfo.probe,ProbeNames{p});
        ProbeNames{p}
        mua_name = ['probe_',num2str(p-1),'_muae'];
        
        mua = nwb.acquisition.get(mua_name).electricalseries.get([mua_name,'_data']);
        
        if contains(fs(sess).name,'C31')
            PO_offset = 25;
        else
            PO_offset = 18;
        end

        indx_lo = nearest_index(mua.timestamps(:),start_times(corrLoTime))+PO_offset;
        indx_go = nearest_index(mua.timestamps(:),start_times(corrGoTime))+PO_offset;
        
        indx_lo_ctrl = nearest_index(mua.timestamps(:),start_times(corrIgo_seqctl))+PO_offset;
        indx_go_ctrl = nearest_index(mua.timestamps(:),start_times(corrGo_seqctl))+PO_offset;
        
        mualo = epoch_data(mua.data(:,:),indx_lo,[5000,2000]);
        mualo_bs = baseline_correct(mualo,baseline_prestim);
        
        muago = epoch_data(mua.data(:,:),indx_go,[5000,2000]);
        muago_bs = baseline_correct(muago,baseline_prestim);
        
        mualo_ctrl = epoch_data(mua.data(:,:),indx_lo_ctrl,[5000,2000]);
        mualo_ctrl_bs = baseline_correct(mualo_ctrl,baseline_prestim);
        
        muago_ctrl = epoch_data(mua.data(:,:),indx_go_ctrl,[5000,2000]);
        muago_ctrl_bs = baseline_correct(muago_ctrl,baseline_prestim);
        
        % getting sem for entire dataset for z-scoring
        
        all_mua = cat(3,mualo_bs,muago_bs,mualo_ctrl_bs,muago_ctrl_bs);
        semTrial = std(all_mua,0,3)./sqrt(size(all_mua,3));
        
        mualo_bs = mualo_bs./repmat(semTrial, [1,1,size(mualo_bs,3)]);

        
% %         smoothing
%         mualo_bs = smoothdata(mualo_bs,2,'movmean',20);
%         muago_bs = smoothdata(muago_bs,2,'movmean',20);
%         mualo_ctrl_bs = smoothdata(mualo_ctrl_bs,2,'movmean',20);
%         muago_ctrl_bs = smoothdata(muago_ctrl_bs,2,'movmean',20);

        % epsp convol
        krnl = spks_kernel( 'psp', 10 );
        mualo_bs = convn(mualo_bs,krnl,'same');

        
        
        %chansel
        clearvars s
        chansel = zeros(1,size(mualo_bs,1));
        for chan = 1:length(chansel)
            [pval,chansel(chan),s(chan)] = ranksum(squeeze(mean(mualo_bs(chan,[b_t1:b_t2],:),2)),squeeze(mean(mualo_bs(chan,[s_t1:s_t2],:),2)));
        end
        chansel = logical(chansel)';
        info.chansel(curr_probe_indx) = chansel;
        chansel_pos = [s.zval]<0 & chansel';
        chansel_neg = [s.zval]>0 & chansel';
        info.chansel_pos(curr_probe_indx) = chansel_pos';
        info.chansel_neg(curr_probe_indx) = chansel_neg';
        


        
    end
    
    clearvars -except datastruct fs baseline_pretrial baseline_prestim info ProbeInfo savedir datadir sess
    
end




