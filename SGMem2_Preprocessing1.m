function SGMem2_Preprocessing1
% Loads neuroscan .cnt files

% % Creates:

% a) filtered set file for subject and block (i.e., 05_01f.set). Every
% file, will be then visually inspected for atypical artifacts. 
% b) one file per subject, appending all blocks with a 0.5Hz high
% pass, named subjnr_all.set

% Last update: 09-10-2019 by Nadia

eeglab;
close;
clear;

% PAths for my computer
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
fprintf(anal_logfile,'\r\n%s','SGMem2_Preprocessing1 - First filtering prior to visual artifact rejection'); % Indicate which script is generating the output to the log

% Subjects and conditions

SubArray = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24  25 26 27 28 29 30];
fprintf(anal_logfile,'\r\n%s',['Analyzing subjects ' num2str(SubArray)]); % update analysis log

% Filter settings before ICA
filterFreq = [0.5]; %[0.5]
filterWinBeta = 5.65326; % estimated with max deviation ripple 0.001
filterOrder = 1812; % Estimated with transition bandwith 1

%number of blocks per subject

nBlocks = 24 % in the case of subject 9. we only have 20 blocks

%% Main files loop

for iSub = 1:length(SubArray)
    
    fprintf(anal_logfile,'\r\n%s',['Analyzing subject ' num2str(SubArray(iSub),'%02d' )]);
    nFiles = sum(nBlocks);
    for iBlock = 1:nBlocks
               
        % Import block data file to EEGlab
        EEG = pop_loadcnt([RawData_folder '/' sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock) '.cnt'], 'dataformat', 'auto');
  
        % configure electrode locations (using .asc file exported from Neuroscan recording software)
        EEG = pop_chanedit(EEG, 'load',{elecs_file 'filetype' 'asc'});
        EEG = eeg_checkset(EEG);
        
        % save unprocessed setfile
        EEG = pop_saveset(EEG, 'filename', [sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock) '.set'], 'filepath', Analysis_folder);
        fprintf(anal_logfile,'\r\n%s',['Saving file ' [sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock)] '.set']);
        
        % High pass filter for each block 
        EEG = pop_firws(EEG, 'fcutoff', filterFreq, 'ftype', 'highpass', 'wtype', 'kaiser', 'warg', filterWinBeta, 'forder', filterOrder);
        fprintf(anal_logfile,'\r\n%s',['Filtering file ' sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock)]);
        
        EEG = eeg_checkset(EEG);
        
        % Store filtered block into ALLEEG
        if ~exist('ALLEEG')
            ALLEEG = EEG;
        elseif exist('ALLEEG')
            ALLEEG(end+1) = EEG;
        end
        % save filtered data for each block
        pop_saveset(EEG, 'filename', [sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock) 'f.set'], 'filepath',Analysis_folder);
        fprintf(anal_logfile,'\r\n%s',['Saving file ' [sprintf('%02d',SubArray(iSub)) '_' sprintf('%02d',iBlock)] 'f.set']);
        
    end
end

% Append all blocks in ALLEEG
EEG = pop_mergeset(ALLEEG, 1:nFiles, 0);

% Save megafile for subject
EEG = pop_saveset(EEG, 'filename', [num2str(SubArray(iSub), '%0.2d') '_all.set'], 'filepath', Analysis_folder);
clear('ALLEEG');

fclose(anal_logfile);

end