function SGMem2_analysis2_encoding
% Loads the xxf.set files for each block and merges all blocks
% Interpolates specified bad channels on specified subjects
% Performs epoching, trial rejection, baseline correction 
% Saves rejection statistics information in Rejstats.txt and Rejstats.mat
% (one rejection stats file for all subjects, overwritten everytime the script runs)
% Saves individual subject ERP averages for the given StimTypes in both eeglab and eeprobe format

% Analyses only for the 2T sequences

% checked by Nadia 09-10-2019
eeglab;
close;
clear;

%% Paths and codes

Exp_Code = '';
hd = '';
RawData_folder = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Raw_Data/MEEG';
Analysis_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG';
Analysis_folder_LargerEpochs = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/LargerEpochs';

elecs_file = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Configuration/SGMEM2.asc';
anal_logfile = [Analysis_folder '/analysis_log.txt'];
Eeprobe_folder = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/Eeprobe/SGMEM2_LargerEpochs';

addpath(genpath('/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/plugins'));

% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','SGMem_analysis2_2T_only_Main'); % Indicate which script is generating the output to the log


%% Subjects and conditions


SubArray = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24 25 26 27 28 29 30]


fprintf(anal_logfile,'\r\n%s',['Analyzing subjects ' num2str(SubArray)]); % update analysis log

nBlocks = 24; 

%Mark 2T sequences only
RecodedStimTypeArray = {{{'66101','66102','66103','66104','66105','66106','66107','66108','66109','66112','66113','66114','66115', '66116', '66117','66123','66124','66125','66126', '66127', '66128'}, 'eA_2T';... % Encoding A sound (all)
    {'66001','66002','66003','66004','66005','66006','66007','66008','66009','66012','66013','66014','66015','66016','66017','66023','66024','66025','66026','66027','66028'}, 'eMA_2T';... % Encoding MA sound (all)
    {'66201','66202','66203','66204','66205','66206','66207','66208', '66209'}, 'eM_2T'}} % Encoding Motor (all)
  
%% Epoching and rejection parameters

epoch_window = [-0.1 0.5];
baseline_window = [-100 0];
rejdeltathresh = 75;% delta threshold for rejecting an epoch in uV
ChanRejThresh = 0.6; % threshold for considering a channel a "bad channel" (in % of trials that are rejected due to this channel)

fprintf(anal_logfile,'\r\n%s',['epoch window = ' num2str(epoch_window)]);
fprintf(anal_logfile,'\r\n%s',['Channel rejection threshold = ' num2str(ChanRejThresh)]);


%% Main analysis loop

for iSub = 1:length(SubArray)
    % Subject 9 has only 20 blocks instead of 24
    if SubArray(iSub) == 9
            nBlocks = 20
    else 
        nBlocks = 24;
    end
   
    fprintf(anal_logfile,'\r\n%s',['Analyzing subject ' num2str(SubArray(iSub))]);
    mkdir([Eeprobe_folder '/S' num2str(sprintf('%02d',SubArray(iSub)))]);% make subject folder in EEPROBE
    
        %% Load filtered data from all blocks
        
        files = dir([Analysis_folder '/' num2str(sprintf('%02d',SubArray(iSub))) '*ICA.set']); % if ICA was applied load files with ICA weights
        ALLEEG = pop_loadset('filepath', Analysis_folder, 'filename', {files(1:end).name});
        
        
        for iBlock = 1:nBlocks
            fprintf(anal_logfile,'\r\n%s',['Analyzing Block ' num2str(iBlock)]);
            %% Remove block start and end triggers 
            if ~isempty(intersect([ALLEEG(iBlock).event.type], 253));
                [TMP, indices] = pop_selectevent(ALLEEG(iBlock),'type',253);
                ALLEEG(iBlock).event(indices) = [];
            end
            
            if ~isempty(intersect([ALLEEG(iBlock).event.type], 255));
                [TMP, indices] = pop_selectevent(ALLEEG(iBlock),'type',255);
                ALLEEG(iBlock).event(indices) = [];
            end
                         
            %% Recode triggers to get only the 2T encoding events (add 66000)
            ALLEEG(iBlock) = SGMem2_analysis2_2T_only(ALLEEG(iBlock));
        
            %% Epoch data
            ALLEEG(iBlock) = pop_epoch(ALLEEG(iBlock), [RecodedStimTypeArray{1}{:, 1}], epoch_window);
            
            %% Baseline correction if baseline_window specified
            if exist('baseline_window')
                ALLEEG(iBlock) = pop_rmbase(ALLEEG(iBlock), baseline_window);
            end
            
            %% Channel interpolation on predefined channels and subjects
            
            % interpolate channel 
       
            if SubArray(iSub) == 5
                if iBlock > 1 && iBlock < 24
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels P3.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [46], 'spherical');
                end
                if iBlock ==1 || iBlock ==5  || iBlock ==6  || iBlock ==7  || iBlock ==8  || iBlock ==9  || iBlock ==10 || iBlock ==11   || iBlock ==12
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels  P1 P8.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [47 52], 'spherical');
                end
                if iBlock ==1 || iBlock ==5  || iBlock ==6  || iBlock ==7  || iBlock ==8  || iBlock ==9  || iBlock ==10 || iBlock ==11   || iBlock ==12
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels P1(47) P8.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [47 52], 'spherical');
                end
                if iBlock <= 9
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels P04.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [57], 'spherical');
                end
                
                if iBlock <= 12
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels CP2.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [64], 'spherical');
                end
                if iBlock > 1 && iBlock <=7
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels P06.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [58], 'spherical');
                end
                if iBlock == 10 || iBlock ==11 || iBlock == 12
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels POZ.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [56], 'spherical');
                end
            end
            
            
            if SubArray(iSub) == 6
                if iBlock > 11 && iBlock < 23
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels 0Z.....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [62], 'spherical');
                end
            end
            
            if SubArray(iSub) == 9
                fprintf(anal_logfile,'\r\n%s','Interpolating channels CB1 (60).....');
                ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [60], 'spherical');
            end
            if SubArray(iSub) == 10
                fprintf(anal_logfile,'\r\n%s','Interpolating channels FC4.....');
                ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [21], 'spherical');
            end
            
            if SubArray(iSub) == 13
                fprintf(anal_logfile,'\r\n%s','Interpolating channels POZ (56).....');
                ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [56], 'spherical');
            end
            if SubArray(iSub) == 14
                fprintf(anal_logfile,'\r\n%s','Interpolating channels P3.....');
                ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [46], 'spherical');
            end
            
            if SubArray(iSub) == 16
                if iBlock > 6 && iBlock <= 24
                    fprintf(anal_logfile,'\r\n%s','Interpolating channels CB2....');
                    ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [64], 'spherical');
                end
            end
           
           if SubArray(iSub) == 17 
                fprintf(anal_logfile,'\r\n%s','Interpolating channelPO5 (54)....');
                ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [54], 'spherical');
           end
           
           if SubArray(iSub) == 18
               if iBlock > 3 && iBlock <= 24
                   fprintf(anal_logfile,'\r\n%s','Interpolating channels PO5 (54)....');
                   ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [2 54], 'spherical');
               end
           end
           
           if SubArray(iSub) == 22 
               fprintf(anal_logfile,'\r\n%s','Interpolating channels F8 (14)....');
               ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [14], 'spherical');
           end
           
           if SubArray(iSub) == 26
               fprintf(anal_logfile,'\r\n%s','Interpolating channels P0Z...');
               ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [56], 'spherical');
           end
           
           if SubArray(iSub) == 27
               fprintf(anal_logfile,'\r\n%s','Interpolating channels P06...');
               ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [58], 'spherical');
               if iBlock < 18
                   fprintf(anal_logfile,'\r\n%s','Interpolating channels P3...');
                   ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [46], 'spherical');
               end
           end
           
    
           if SubArray(iSub) == 28
               fprintf(anal_logfile,'\r\n%s','Interpolating channels P2 and CP5...');
               ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [49 35], 'spherical');
           end
           
        
           if SubArray(iSub) == 30
               if iBlock < 10
                   fprintf(anal_logfile,'\r\n%s','Interpolating channels P3...');
                   ALLEEG(iBlock) = pop_interp(ALLEEG(iBlock), [46], 'spherical');
               end
           end
            %% Detect channels with high rejection blockwise to consider interpolation
            
            % Mark trials for artifact rejection
            TMP = eeg_rejdelta(ALLEEG(iBlock), 'thresh', rejdeltathresh);
            TMP = eeg_rejsuperpose(TMP, 1, 1, 1, 1, 1, 1, 1, 1);
            
            % Display channels with high rejection
            disp(['rej stats for ' TMP.filename]);
            chanrej = zeros(size(TMP.reject.rejglobalE,2), TMP.nbchan);
            for i = 1:size(TMP.reject.rejglobalE,2)
                chanrej(i,1:size(find(TMP.reject.rejglobalE(:,i)),1))= find(TMP.reject.rejglobalE(:,i));
            end
            for ichan = 1:TMP.nbchan
                prej = sum(sum(chanrej==ichan))/size(chanrej,1);
                if prej>ChanRejThresh
                    disp (['rejection for ' TMP.chanlocs(ichan).labels '=' num2str(prej)]);
                    fprintf(anal_logfile,'\r\n%s',['High rejection found for channel ' TMP.chanlocs(ichan).labels ' (' num2str(prej) ')']);
                end
            end
            
            
        end
        
        %% Merge Blocks
        EEG = pop_mergeset(ALLEEG, 1:nBlocks, 0);
        
        % Make sure EEG.event.type is numerical, not string
        if ischar(EEG.event(1).type)
            eventtypes = cellfun(@str2double,{EEG.event.type});
            eventtypes = num2cell(eventtypes);
            [EEG.event(:).type] = deal(eventtypes{:});
        end
        
        %% Trial rejection
        
        % Mark trials for Artifact rejection
        EEG = eeg_rejdelta(EEG, 'thresh', rejdeltathresh);
        EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); % marked but not yet rejected
        
        % Calculate and write rejstats to anal_logfile for each Stimtype
        for iStimType = 1:size(RecodedStimTypeArray{1},1)
                        
            % check if any events of this type first
            if ~isempty(intersect([EEG.event.type], cellfun(@str2num,RecodedStimTypeArray{1}{iStimType, 1})))
                
                % if any events of this type are found then:
                [TMP event_indices] = pop_selectevent(EEG, 'type', str2double(RecodedStimTypeArray{1}{iStimType, 1}));
                epochs= [EEG.event(event_indices).epoch];
                trials_found = size(event_indices,2);
                trials_rejected = length(find(EEG.reject.rejglobal(epochs)));
                percent_rejected = (length(find(EEG.reject.rejglobal(epochs)))/size(event_indices,2))*100;
                trials_left = trials_found - trials_rejected;
                
                fprintf(anal_logfile,'\r\n%s',['Rejection stats for ' num2str(SubArray(iSub), '%0.2d') ' ' RecodedStimTypeArray{1}{iStimType, 2}]);
                fprintf(anal_logfile,'\r\n%s',['Ntrials found = ' num2str(trials_found)]);
                fprintf(anal_logfile,'\r\n%s',['Ntrials rejected = ' num2str(trials_rejected)]);
                fprintf(anal_logfile,'\r\n%s',['Rejection % = ' num2str(percent_rejected) '%']);
                fprintf(anal_logfile,'\r\n%s',['Ntrials left in avr = ' num2str(trials_left)]);
                
                % Save rejection stats
                iStimType2 = iStimType;
                
                Rejstats(iSub).StimType(iStimType2).Subject= SubArray(iSub);
                Rejstats(iSub).StimType(iStimType2).StimType = RecodedStimTypeArray{1}{iStimType, 2};
                Rejstats(iSub).StimType(iStimType2).nTrialsFound = trials_found;
                Rejstats(iSub).StimType(iStimType2).nTrialsRej = trials_rejected;
                Rejstats(iSub).StimType(iStimType2).RejRate = percent_rejected;
                Rejstats(iSub).StimType(iStimType2).nTrialsLeft = trials_left;
                save(fullfile(Analysis_folder_LargerEpochs,'Rejstats_2T_only'),'Rejstats');
                
            elseif isempty(intersect([EEG.event.type], cellfun(@str2num,RecodedStimTypeArray{1}{iStimType, 1})))
                
                % if no events of this type are found, then:
                disp(['*****WARNING: NO TRIALS FOUND for ' num2str(SubArray(iSub), '%0.2d') ' ' RecodedStimTypeArray{1}{iStimType, 2} '!!!']);
                trials_found = 0;
                trials_rejected = NaN;
                percent_rejected = NaN;
                trials_left = NaN;
                
                fprintf(anal_logfile,'\r\n%s',['Rejection stats for ' num2str(SubArray(iSub), '%0.2d') ' ' RecodedStimTypeArray{1}{iStimType, 2}]);
                fprintf(anal_logfile,'\r\n%s','WARNING: NO TRIALS FOUND!!!');
                
                % Save rejection stats
                iStimType2 = iStimType;
                
                Rejstats(iSub).StimType(iStimType2).Subject= SubArray(iSub);
                Rejstats(iSub).StimType(iStimType2).StimType = RecodedStimTypeArray{1}{iStimType, 2};
                Rejstats(iSub).StimType(iStimType2).nTrialsFound = trials_found;
                Rejstats(iSub).StimType(iStimType2).nTrialsRej = trials_rejected;
                Rejstats(iSub).StimType(iStimType2).RejRate = percent_rejected;
                Rejstats(iSub).StimType(iStimType2).nTrialsLeft = trials_left;
                save(fullfile(Analysis_folder_LargerEpochs,'Rejstats_2T_only'),'Rejstats');
            end
        end
        
        % Reject trials
        disp(['Rejecting trials for ' num2str(SubArray(iSub))]);
        EEG = pop_rejepoch(EEG, find(EEG.reject.rejglobal), 0);
        
        
        %% Save subject .set files (averages) by StimType
        iStimType2 = 1;
        for iStimType = 1:size(RecodedStimTypeArray{1},1)
            
            disp(['Saving average files for subject ' num2str(SubArray(iSub)) ' condition ' RecodedStimTypeArray{1}{iStimType, 2}]);
            
            % Check first if there are any trials left for this StimType
            if Rejstats(iSub).StimType(iStimType2).RejRate<100
                
                % If any events of this type are left, then:
                
                % Select events for Average
                TMP = pop_selectevent(EEG, 'type', str2double(RecodedStimTypeArray{1}{iStimType, 1}), 'deleteevents', 'on');
                
                % Save average as setfile
                TMP.setname = [num2str(SubArray(iSub), '%0.2d') ' ' RecodedStimTypeArray{1}{iStimType, 2}];
                pop_saveset(TMP, [num2str(SubArray(iSub), '%0.2d') '_' RecodedStimTypeArray{1}{iStimType, 2} '.set'], Analysis_folder_LargerEpochs);
                ALLEEG_StimTypes(iStimType)= TMP;
                
                % Save average as Eeprobe file
               pop_writeeepavr(TMP, 'pathname', [Eeprobe_folder '/S' num2str(sprintf('%02d',SubArray(iSub)))], 'filename', [num2str(SubArray(iSub), '%0.2d') '_' RecodedStimTypeArray{1}{iStimType, 2} '.avr'], 'filevers', 4, 'condlabel', RecodedStimTypeArray{1}{iStimType, 2});
                
                % Update analysis log
                fprintf(anal_logfile,'\r\n%s',['Saving setfile ' TMP.setname]);
                fprintf(anal_logfile,'\r\n%s',['Ntrials = ' num2str(size(TMP.event,2))]);
                
                % If all trials of this type were rejected), then:
            elseif Rejstats(iSub).StimType(iStimType2).RejRate == 100
                disp('********WARNING********');
                disp(['All trials have been rejected for Subj ' num2str(SubArray(iSub), '%0.2d') ' StimType ' RecodedStimTypeArray{1}{iStimType, 2}]);
                fprintf(anal_logfile,'\r\n%s','********WARNING********');
                fprintf(anal_logfile,'\r\n%s',['All trials have been rejected for Subj ' num2str(SubArray(iSub), '%0.2d') ' StimType ' RecodedStimTypeArray{1}{iStimType, 2}]);
                                
            end
            iStimType2 = iStimType2 + 1;
        end
                
        
    
    
end

% Write tables for rejstats for all subs

% Rejstats
T = struct2table(Rejstats(1).StimType);
for iSubj = 2:size(Rejstats,2)
    T2 = struct2table(Rejstats(iSubj).StimType);
    T(end+1:end+size(T2,1),:) = T2(1:end,:);
end
T.RejRate = round(T.RejRate,1);
writetable(T,[Analysis_folder_LargerEpochs '/Rejstats_2T_only'],'FileType','text','Delimiter','\t')


fclose(anal_logfile);
