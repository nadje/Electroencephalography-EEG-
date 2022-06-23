function EEG=Subfunction_SGMem2_analysis2_encoding(EEG)

% created by Nadia 29.07.2021
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

         
    % Get the encoding events only for T2 sequences
    if trialTS1 == 41 | trialTS1 == 141 
        sequence_type = 66000;% code for T2 sequences event
         
     else
         sequence_type=0;
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
    newtrigs = num2cell([EEG.event(trial_triggers_EEGindices).type] + sequence_type);
    [EEG.event(trial_triggers_EEGindices).type] = deal(newtrigs{:});
    
end % Trial loop

end