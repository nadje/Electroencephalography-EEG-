function SGMem2_analysis1
% Applies ICA correction on the original data after having identified the
% components that need to be removed.

% Modified and checked 10-10-2019 by Nadia
eeglab;
close;
clear;

%% Paths and codes

Exp_Code = '';
hd = '';
RawData_folder = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Raw_Data/MEEG';
Analysis_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG';
elecs_file = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Configuration/SGMEM2.asc';
anal_logfile = [Analysis_folder '/analysis_log.txt'];


% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','SGMem2_analysis1 - Apply ICA correction'); % Indicate which script is generating the output to the log


% Subjects and conditions

SubArray = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24  25 26 27 28 29 30];
fprintf(anal_logfile,'\r\n%s',['Analyzing subjects ' num2str(SubArray)]); % update analysis log
nBlocks = 24; % subject 9 only 20 blocks - if statement added below

    
    %ICA components to remove for each subject
    % subjects x components
    components = {
        [1 2 3 4 5 6 7 9 10 17 18 24 30]; %subj 6
        [1 2 9 11 18 24 27]; %subj 7
       [1 2 9 17 19 22 25]; %subj 8
        [2 3 9 14 21];% subj 9
        [1 2 7 17 26];% subj 10
      [1 2 5 10 17 18];% subj 11
                [1 2 6 18 9 10];% subj 12
        [1 2 3 5 11 18 24];% subj 13
        
        [1 2 3 4 6 8 11 13 15 23 26];% subj 14
        % subj 15 is excluded
        [1 2 3 4 5 6 21 22 28];% subj 16
  % subj 17 is excluded
         [1 2 3 4 7 8 30];% subj 18 
               [1 6 12 13 21];% subj 19

        [1 8 17 19 20 22];% subj 20
        [1 5 10 11];% subj 21
        
        [1 2 3 4 6];% subj 22
        [1 2 3 8 19] % subj 23
        [1 5 15 23 26 28] % subject 24
       [1 5 9 12 14 18 20 28]% subject 25
        [1 2 3 8 16 17 18 23]% subject 26
        
        [1 2 4 5 6 13 16 27]% subject 27
        [1 2 3 4 5 8 10 14 17 20]% subject 28
        [1 4 9 22]% subject 29
        [1 2 3 5 7 8 24 25 26]}% subject 30
        
    fprintf(anal_logfile,'\r\n%s','ICA Components removed:');
    for iSubj = 1:length(SubArray);
        fprintf(anal_logfile,'\r\n%s',['Subj' num2str(SubArray(iSubj)) ' Comps: ' num2str(components{iSubj,:})]);
    end
    
    % Filter settings before ICA
    filterFreq_beforeICA = [0.5]; %[0.5 30]
    filterWinBeta_beforeICA = 5.65326; % estimated with max deviation ripple 0.001
    filterOrder_beforeICA = 1812; % 1812 estimated with transition bandwidth 1; 9056 Estimated with transition bandwith 0.2, 908 estimated with transition bandwitdth 2
    
    % Filter settings after ICA
    filterFreq_afterICA = [30]; %[0.5 30]
    filterWinBeta_afterICA = 5.65326; % estimated with max deviation ripple 0.001
    filterOrder_afterICA = 1812; % 1812 estimated with transition bandwidth 1; 9056 Estimated with transition bandwith 0.2, 908 estimated with transition bandwitdth 2
    
    fprintf(anal_logfile,'\r\n%s','Filter settings: '); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['FilterFreq_beforeICA: ' num2str(filterFreq_beforeICA)]); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['filterWinBeta_beforeICA: ' num2str(filterWinBeta_beforeICA)]); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['filterOrder_beforeICA: ' num2str(filterOrder_beforeICA)]); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['FilterFreq_afterICA: ' num2str(filterFreq_afterICA)]); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['filterWinBeta_afterICA: ' num2str(filterWinBeta_afterICA)]); % update analysis log
    fprintf(anal_logfile,'\r\n%s',['filterOrder_afterICA: ' num2str(filterOrder_afterICA)]); % update analysis log
    
%% Main files loop

for iSub = 1:length(SubArray)
    
    fprintf(anal_logfile,'\r\n%s',['Analyzing subject ' num2str(SubArray(iSub))]);
    % load the file with ICA weights for this subject
    EEG_ICA = pop_loadset('filename',[num2str(SubArray(iSub), '%0.2d') '_allrej_binica.set'], 'filepath', Analysis_folder);
    
    % Subject 9 has only 20 blocks instead of 24
    if SubArray(iSub) == 9
            nBlocks = 20
    else 
        nBlocks = 24;
    end
        
    for iBlock = 1:nBlocks
        
        %% Import files to EEGlab
        
        EEG = pop_loadcnt([RawData_folder '/' num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') '.cnt'], 'dataformat', 'auto');
        
        
        % configure electrode locations

        EEG = pop_chanedit(EEG, 'load',{elecs_file 'filetype' 'asc'});
        % checkset
        EEG = eeg_checkset(EEG);
        
        % save setfile
        EEG = pop_saveset(EEG, 'filename', [num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') '.set'], 'filepath', Analysis_folder);
        fprintf(anal_logfile,'\r\n%s',['Saving file ' num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') '.set']);
        
        %% high pass filter data before ICA
        
        EEG = pop_firws(EEG, 'fcutoff', filterFreq_beforeICA, 'ftype', 'highpass', 'wtype', 'kaiser', 'warg', filterWinBeta_beforeICA, 'forder', filterOrder_beforeICA);
        EEG = eeg_checkset(EEG);
        
        fprintf(anal_logfile,'\r\n%s',['Filtering file ' EEG.filename]);
        
        %% apply ICA correction
        
        EEG.icaact = EEG_ICA.icaact;
        EEG.icawinv = EEG_ICA.icawinv;
        EEG.icasphere = EEG_ICA.icasphere;
        EEG.icaweights = EEG_ICA.icaweights;
        EEG.icachansind = EEG_ICA.icachansind;
        
        EEG = pop_subcomp(EEG,components{iSub});
        
        fprintf(anal_logfile,'\r\n%s',['Applying ICA correction. Removing components: ' num2str(components{iSub,:})]);
        
        %% low pass filter after ICA correction
        EEG = pop_firws(EEG, 'fcutoff', filterFreq_afterICA, 'ftype', 'lowpass', 'wtype', 'kaiser', 'warg', filterWinBeta_afterICA, 'forder', filterOrder_afterICA);
        EEG = eeg_checkset(EEG);
        
        fprintf(anal_logfile,'\r\n%s',['Filtering file ' EEG.filename]);
        
        % save filtered and corrected data with ICA weights
        
        EEG = pop_saveset(EEG, 'filename', [num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') 'f_withICA.set'], 'filepath', Analysis_folder);
        
        fprintf(anal_logfile,'\r\n%s',['Saving file ' num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') 'f_withICA.set']);
        
        
    end
end

fclose(anal_logfile);
end
