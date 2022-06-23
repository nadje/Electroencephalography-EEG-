function EEG = Subfunction_SGMem2_analysis2_retrieval(EEG)
% Recodes the triggers based on memory performance
% For T1 sequences:
% (trialcorrect = 1000 if correct / trialcorrect = 2000 if incorrect,  trialcorrect == 3000 if miss--> added to the trigger code)
% For T2 sequences:
% (trialremembered == 4000 if Auditory / trialremembered == 5000 if MA,
% trialremembered === 3000 if miss) --> added to the trigger code
% Adds SOA information for each event to EEG.event
% Function called by SGMem_analysis2_byAccuracy
% RawData_folder = 'G:\SGMem2';
% Analysis_folder = RawData_folder
% anal_logfile = [Analysis_folder '\analysis_log.txt'];
% addpath('G:\SGMem2\AnalysisScripts\plugins');
% addpath('C:\Program Files\MATLAB\eeglab14_1_2b')
% eeglab;

% checked by Nadia 09-10-2019
% eeglab;
% close;
% clear;
% Initialize analysis logfile
%% Select all Relevant triggers (trial start, ALL encoding event triggers, TS and response triggers and extrapresses)
trial_start = [254];
% first line A, second line MA, third line M (no catch included)
encoding_events = [101   102   103   104   105   106   107   108   109    112   113   114   115    116    117    118   123   124   125   126    127    128 ...
     1   2   3   4   5   6   7   8   9     12   13   14   15   16   17   18   23   24   25   26   27   28 ...
     201   202   203   204   205   206   207   208    209];

% first line A, second line MA
encoding_sounds = [101   102   103   104   105   106   107   108   109    112   113   114   115    116    117    118   123   124   125   126    127    128 ...
     1   2   3   4   5   6   7   8   9   12   13   14   15   16   17   18   23   24   25   26   27   28];

% first line MA, second line M
encoding_presses = [ 1   2   3   4   5   6   7   8   9    12   13   14   15   16   17   18   23   24   25   26   27   28 ...
     201   202   203   204   205   206   207   208    209];

 % For 1T sequences
TS1 = [41   31  141   131   133 ]; % first test sound (both A and MA) 
% TS1 = [TS1 TS1+10 TS1+20 TS1+30]; % + 10 if it was remembered +20 if forgotten
% TS1 = [TS1 TS1+200];

TS2 = [42   32   142   132   134]
% TS2 =[TS2 TS2+10 TS2+20 TS2+30];
% TS2 = [TS2 TS2+200];
response = [88 89];

extrapress = [99];

rel_triggers = [trial_start encoding_events TS1 TS2 response extrapress];
rel_triggers = num2cell(rel_triggers);
rel_triggers = cellfun(@num2str,rel_triggers,'UniformOutput',0);


%% Cleanup

% EEG = ALLEEG
% clear boundary events
[TMP, indices] = pop_selectevent(EEG,'type',str2double(rel_triggers));
replace = [];
for ievent = 1:size(indices,2)
    if ischar(EEG.event(indices(ievent)).type) && strcmpi(EEG.event(indices(ievent)).type, 'boundary')
        replace = [replace indices(ievent)];
    end
end

if ~isempty(replace)
EEG.event(replace) = [];
end

% Make sure EEG.event.type is numerical, not string
if ischar(EEG.event(1).type)
    eventtypes = cellfun(@str2double,{EEG.event.type});
    eventtypes = num2cell(eventtypes);
    [EEG.event(:).type] = deal(eventtypes{:});
end

%% Get indices to relevant events
[TMP, indices] = pop_selectevent(EEG,'type',str2double(rel_triggers));

% Get event types
event_types = [EEG.event(indices).type];

% Find cues to identify trials
cues = ismember(event_types,trial_start);
cues_indices = find(cues);

%% For each trial:
for iTrial = 1:sum(cues)
    
    % Get all events for this trial
    if iTrial == sum(cues)
        trial_triggers_EEGindices = indices(cues_indices(iTrial):end);
        trial_triggers_types = event_types(cues_indices(iTrial):end);
    else
        trial_triggers_EEGindices = indices(cues_indices(iTrial):cues_indices(iTrial+1)-1);
        trial_triggers_types = event_types(cues_indices(iTrial):cues_indices(iTrial+1)-1);
    end
    
    %% Code correct/incorrect/miss
    
    % find TS1, TS2 and response
    trialTS1 = ismember(trial_triggers_types,TS1);
    trialTS1 = trial_triggers_types(trialTS1);
    
    trialTS2 = ismember(trial_triggers_types,TS2);
    trialTS2 = trial_triggers_types(trialTS2);
    trialresponse = ismember(trial_triggers_types,response);
    trialresponse = trial_triggers_types(trialresponse);
    
    %For T1 sequences, calculate trialcorrect
    % code correct A = 1000 / incorrect A = 2000 / miss = 3000
    % code correct MA = 6000 / incorrect MA = 7000
    if isempty(trialresponse)
        trialcorrect = 3000;
        
    %  TS1 31-MA   131-A   133 = No Sound
    %  TS2 32-MA   132-A   134=NO Sound
    
    % For correctly remembered A sounds : 1000
    elseif ( trialTS1==131 & trialresponse == 88) | (trialTS2==132 & trialresponse == 89)
        trialcorrect = 1000;
    % For correctly remembered MA sounds : 6000
    elseif ( trialTS1==31 & trialresponse == 88) | (trialTS2==32 & trialresponse == 89)
        trialcorrect = 6000;
    % For forgotten A sounds: 2000
    elseif (trialTS1==131 & trialresponse == 89) |(trialTS2 == 132 & trialresponse == 88)
        trialcorrect = 2000;
   % For forgotten MA sounds: 7000
    elseif (trialTS1==31 & trialresponse == 89) |(trialTS2 == 32 & trialresponse == 88)
        trialcorrect = 7000;
    else 
        trialcorrect = 0; % for trials with 2T sequences
    end
    
     %For T2 sequences, calculate trialremembered
     % A = 4000 / MA = 5000 / miss = 3000
     if isempty(trialresponse)
         trialremembered = 3000;
     elseif (trialTS1 == 41 & trialresponse == 88) | (trialTS2 == 42 & trialresponse == 89) % if MA was remembered
         trialremembered = 5000;
     elseif (trialTS1 == 141 & trialresponse == 88) | (trialTS2 == 142 & trialresponse == 89) % if A was remembered
         trialremembered = 4000;
         
     else
         trialremembered=0;
     end
         
    
    %% Get SOAs and set SOA fields in EEG.event
    
    % event2event
    trial_event_times = [EEG.event(trial_triggers_EEGindices).latency];
    trial_event_SOAs = (diff(trial_event_times(ismember(trial_triggers_types,[encoding_events TS1 TS2 extrapress]))))/EEG.srate;
    event_triggers_EEGindices = trial_triggers_EEGindices(ismember(trial_triggers_types,[encoding_events TS1 TS2 extrapress]));
    trial_event_SOAs = num2cell(trial_event_SOAs);
    [EEG.event(event_triggers_EEGindices(2:end)).e2eSOA] = deal(trial_event_SOAs{:});
    
    % sound2sound
    trial_s2s_SOAs = (diff(trial_event_times(ismember(trial_triggers_types,[encoding_sounds TS1 TS2]))))/EEG.srate;
    sound_triggers_EEGindices = trial_triggers_EEGindices(ismember(trial_triggers_types,[encoding_sounds TS1 TS2]));
    trial_s2s_SOAs = num2cell(trial_s2s_SOAs);
    [EEG.event(sound_triggers_EEGindices(2:end)).s2sSOA] = deal(trial_s2s_SOAs{:});
    
    % press2press
    trial_p2p_SOAs = (diff(trial_event_times(ismember(trial_triggers_types,[encoding_presses extrapress]))))/EEG.srate;
    press_triggers_EEGindices = trial_triggers_EEGindices(ismember(trial_triggers_types,[encoding_presses extrapress]));
    trial_p2p_SOAs = num2cell(trial_p2p_SOAs);
    [EEG.event(press_triggers_EEGindices(2:end)).p2pSOA] = deal(trial_p2p_SOAs{:});
    
    %% Recode triggers of all events in this trial
    newtrigs = num2cell([EEG.event(trial_triggers_EEGindices).type] + trialcorrect + trialremembered);
    [EEG.event(trial_triggers_EEGindices).type] = deal(newtrigs{:});
    
end % Trial loop

end % Function



