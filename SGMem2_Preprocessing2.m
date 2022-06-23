function SGMem2_Preprocessing2
% This script needs to be run after doing visual artifact rejection.

% Loads rej files per subject and block (e.g., 05_01f_rej.set) 
% % Creates one file per subject, named subjnr_all_rej.set in order 
% to calculate the ICA decomposition

% Created 31/07/2019 by Nadia
% Checked again 9-10-2019 by Nadia

eeglab;
close;
clear;

% Paths
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
fprintf(anal_logfile,'\r\n%s','SGMem2_Preprocessing2 - Merge Blocks after visual artifact rejection'); % Indicate which script is generating the output to the log

% Subjects and conditions

SubArray = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24  25 26 27 28 29 30];
fprintf(anal_logfile,'\r\n%s',['Analyzing subjects ' num2str(SubArray)]); % update analysis log
%number of blocks per subjectt
nBlocks = 24

%% Main files loop

for iSub = 1:length(SubArray)
    if SubArray(iSub) == 9 % only 20 EEG blocks for subject 9
        nBlocks = 20;
    else
        nBlocks=24;
    end
    fprintf(anal_logfile,'\r\n%s',['Analyzing subject ' num2str(SubArray(iSub),'%02d' )]);
    nFiles = sum(nBlocks);
    for iBlock = 1:nBlocks
       % load the filtered & rejected files
       EEG = pop_loadset('filename',[num2str(SubArray(iSub), '%0.2d') '_' num2str(iBlock, '%0.2d') 'f_rej.set'],'filepath','/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/');
        
       % Store filtered block into ALLEEG
        if ~exist('ALLEEG')
            ALLEEG = EEG;
        elseif exist('ALLEEG')
            ALLEEG(end+1) = EEG;
        end
    end

% Append all blocks in ALLEEG
EEG = pop_mergeset(ALLEEG, 1:nFiles, 0);
% Save megafile for subject
EEG = pop_saveset(EEG, 'filename', [num2str(SubArray(iSub), '%0.2d') '_allrej.set'], 'filepath', Analysis_folder);

clear('ALLEEG');
end


         