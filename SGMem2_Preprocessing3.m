function SGMem2_Preprocessing3
% Calculates ICA decomposition and saves it as 'subjnr_allrej_binica.set',
% that will be later used by SGMem2_analysis1 to apply ICA correction

% Created 31/07/2019 by Nadia
% Check 09-10-2019 by Nadia
eeglab;
close;
clear;

%% Parameters that can be modified
SubArray = [26 27 28 29 30];% [4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]

%% Paths and codes
Exp_Code = '';
hd = '';
RawData_folder = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Raw_Data/MEEG';
Analysis_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG';
elecs_file = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Configuration/SGMEM2.asc';
anal_logfile = [Analysis_folder '/analysis_log.txt'];
Eeprobe_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/Eeprobe/SGMEM2';
addpath(genpath('/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/plugins'));
anal_logfile = [Analysis_folder '/analysis_log.txt'];


% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','SGMem2_Preprocessing3 - Run binica'); % Indicate which script is generating the output to the log
 
%% Load all subject

for iSub = 1:length(SubArray)
    
    % load files with rejections
    EEG = pop_loadset('filename',[num2str(SubArray(iSub), '%0.2d') '_allrej.set'], 'filepath', Analysis_folder);
    
   
    % configure electrode locations
     EEG = pop_chanedit(EEG, 'lookup',elecs_file);
      
    % Run main ICA analyses
    EEG = pop_runica(EEG,'icatype','binica'); 

    % Save megafile for subject
    EEG = pop_saveset(EEG, 'filename', [num2str(SubArray(iSub), '%0.2d') '_allrej_binica.set'], 'filepath', Analysis_folder);

end