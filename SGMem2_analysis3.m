function SGMem2_analysis3

eeglab;
close;
clear;

%% Paths and codes
Exp_Code = '';
hd = '';
RawData_folder = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Raw_Data/MEEG';
Analysis_folder_LargerEpochs = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/LargerEpochs';
elecs_file = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Configuration/SGMEM2.asc';
anal_logfile = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/analysis_log.txt';
Eeprobe_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/Eeprobe/SGMEM2_LargerEpochs';
addpath(genpath('/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/plugins'));


% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','SGMem2_analysis3'); % Indicate which script is generating the output to the log


%% Subjects and conditions

% Participant 5 excluded due to bad data
% Participant 15 excluded due to missing data (problems with data
% collection)
% Participant 17 also excluded no pupil data
SubArray = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24 25 26 27 28 29 30]


%% GENERAL ANALYSIS
fprintf(anal_logfile,'\r\n%s',['Analyzing subjects ' num2str(SubArray)]); % update analysis log

% Motor correction 

% conditions to subtract (will subtract DW1-DW2, columnwise)
DW1 = {'eMA','eMA_2T'};
DW2 = {'eM','eM_2T'};


for iSub = 1:length(SubArray)
    
    for iDW = 1: length(DW1)
        
        % load file 1
        EEG1 = pop_loadset('filepath', Analysis_folder_LargerEpochs, 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '.set']);
        
        % load file 2
        EEG2 = pop_loadset('filepath', Analysis_folder_LargerEpochs, 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW2{iDW} '.set']);
        
        % subtract 1 - 2
        EEG = EEG1; % take structure fields for new EEG structure from EEG1
        EEG.data = (mean(EEG1.data,3)) - (mean(EEG2.data,3));% average over trials and do difference wave
        
        % Clear wrong fields inherited from EEG1
        EEG.trials = [];
        EEG.event = [];
        EEG.urevent = [];
        EEG.epoch = [];
        EEG.reject = [];
        EEG.stats = [];
        
        % save setfile
        EEG.setname = [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '-' DW2{iDW} '.set'];
        pop_saveset(EEG, EEG.setname, Analysis_folder_LargerEpochs);
        fprintf(anal_logfile,'\r\n%s',['Saving file ' EEG.setname]); % update analysis log
        
        % write avr file
        pop_writeeepavr(EEG, 'pathname', fullfile(Eeprobe_folder, ['S' sprintf('%02d',SubArray(iSub))]), 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '-' DW2{iDW} '.avr'], 'filevers', 4, 'condlabel', [DW1{iDW} '-' DW2{iDW}]);
        
    end
end

% Difference waves (a-ma)

% conditions to subtract (will subtract DW1-DW2, columnwise)
DW1 = {'eA','eA_2T'};
DW2 = {'eMA-eM','eMA_2T-eM_2T'};


for iSub = 1:length(SubArray)
    
    for iDW = 1: length(DW1)
        
        % load file 1
        EEG1 = pop_loadset('filepath', Analysis_folder_LargerEpochs, 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '.set']);
        
        % load file 2
        EEG2 = pop_loadset('filepath', Analysis_folder_LargerEpochs, 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW2{iDW} '.set']);
        
        % subtract 1 - 2
        EEG = EEG1; % take structure fields for new EEG structure from EEG1
        EEG.data = (mean(EEG1.data,3)) - (mean(EEG2.data,3));% average over trials and do difference wave
        
        % Clear wrong fields inherited from EEG1
        EEG.trials = [];
        EEG.event = [];
        EEG.urevent = [];
        EEG.epoch = [];
        EEG.reject = [];
        EEG.stats = [];
        
        % save setfile
        EEG.setname = [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '-' DW2{iDW} '.set'];
        pop_saveset(EEG, EEG.setname, Analysis_folder_LargerEpochs);
        fprintf(anal_logfile,'\r\n%s',['Saving file ' EEG.setname]); % update analysis log
        
        % write avr file
        pop_writeeepavr(EEG, 'pathname', fullfile(Eeprobe_folder, ['S' sprintf('%02d',SubArray(iSub))]), 'filename', [sprintf('%02d',SubArray(iSub)) '_' DW1{iDW} '-' DW2{iDW} '.avr'], 'filevers', 4, 'condlabel', [DW1{iDW} '-' DW2{iDW}]);
        
    end
end
% GRAND AVERAGES

% Conditions to average:
StimTypeArray = {
    'eA_2T', 'eMA_2T', 'eM_2T', 'eMA_2T-eM_2T',... % encoding events only for 2T seqs
    'eA','eMA','eM','eMA-eM',... % encoding events for both 2T and 1T seqs
    'tMAretr_R_2T','tMAretr_F_2T','tAretr_R_2T','tAretr_F_2T',...
    'eA-eMA-eM', 'eA_2T-eMA_2T-eM_2T'};


% Update analysis log
fprintf(anal_logfile,'\r\n%s',['Calculating GAVR for conditions ' StimTypeArray{1:end}]); % update analysis log
fprintf(anal_logfile,'\r\n%s',['Nsubjects =  ' num2str(length(SubArray))]); % update analysis log


% Do grand average per StimType
for iGAVR = 1:length(StimTypeArray)
    
    % load files of all subjects
    filenames = cell(1, length(SubArray));
    for iSubject = 1:length(SubArray)
        filenames{iSubject} = [sprintf('%02d',SubArray(iSubject)) '_' StimTypeArray{iGAVR} '.set'];
    end
    
    % do Grand Average
    EEG = pop_grandaverage(filenames, 'pathname', Analysis_folder_LargerEpochs);
    EEG.setname = ['GAVR ' StimTypeArray{iGAVR}];
    EEG.chanlocs = pop_chanedit(EEG.chanlocs, 'lookup', elecs_file);
    
    % save grand average as setfile
    pop_saveset(EEG, ['GAVR_' StimTypeArray{iGAVR}], Analysis_folder_LargerEpochs);
    
    % update analysis log
    fprintf(anal_logfile,'\r\n%s',['Saving file ' EEG.setname]); % update analysis log

    % write avr file
    pop_writeeepavr(EEG, 'pathname', fullfile(Eeprobe_folder, 'GAVR'), 'filename', ['GAVR_' StimTypeArray{iGAVR} '.avr'], 'filevers', 4, 'condlabel', [StimTypeArray{iGAVR}]);
    
end



end