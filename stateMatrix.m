function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters

%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);
LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');
LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port',num2str(RightPort),'In');

LeftValve = 2^(LeftPort-1);
RightValve = 2^(RightPort-1);

LeftValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,1), LeftPort);
RightValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,2), RightPort);

if BpodSystem.Data.Custom.AuditoryTrial(iTrial) %auditory trial
    LeftRewarded = BpodSystem.Data.Custom.LeftRewarded(iTrial);
end

if LeftRewarded == 1
    LeftPokeAction = 'rewarded_Lin_start';
    RightPokeAction = 'unrewarded_Rin_start';
elseif LeftRewarded == 0
    LeftPokeAction = 'unrewarded_Lin_start';
    RightPokeAction = 'rewarded_Rin_start';
else
    error('Bpod:Olf2AFC:unknownStim','Undefined stimulus');
end

if BpodSystem.Data.Custom.CatchTrial(iTrial)
    FeedbackDelayCorrect = 20;
else
    FeedbackDelayCorrect = TaskParameters.GUI.FeedbackDelay;
end
if TaskParameters.GUI.CatchError
    FeedbackDelayError = 20;
else
    FeedbackDelayError = TaskParameters.GUI.FeedbackDelay;
end

%Wire1 settings
if TaskParameters.GUI.Wire1VideoTrigger
    Wire1OutError =	{'WireState', 1};
    if BpodSystem.Data.Custom.CatchTrial(iTrial)
    	Wire1OutCorrect =	{'WireState', 1};
    else
        Wire1OutCorrect =	{};
    end
else
    Wire1OutError = {};
    Wire1OutCorrect =	{};
end

%% Build state matrix
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,FeedbackDelayCorrect);
sma = SetGlobalTimer(sma,2,FeedbackDelayError);
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'stay_Cin'},...
    'OutputActions', {strcat('PWM',num2str(CenterPort)),255}); 
sma = AddState(sma, 'Name', 'broke_fixation',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','timeOut_BrokeFixation'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'stay_Cin',...
    'Timer', TaskParameters.GUI.StimDelay,...
    'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup', 'stimulus_delivery_min'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'stimulus_delivery_min',...
    'Timer', TaskParameters.GUI.MinSampleAud,...
    'StateChangeConditions', {CenterPortOut,'early_withdrawal','Tup','stimulus_delivery'},...
    'OutputActions', {'BNCState',1});
sma = AddState(sma, 'Name', 'early_withdrawal',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','timeOut_EarlyWithdrawal'},...
    'OutputActions',{'BNCState',0});
sma = AddState(sma, 'Name', 'stimulus_delivery',...
    'Timer', TaskParameters.GUI.AuditoryStimulusTime - TaskParameters.GUI.MinSampleAud,...
    'StateChangeConditions', {CenterPortOut,'wait_Sin','Tup','wait_Sin'},...
    'OutputActions', {'BNCState',1});
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer',TaskParameters.GUI.ChoiceDeadLine,...
    'StateChangeConditions', {LeftPortIn,'start_Lin',RightPortIn,'start_Rin','Tup','missed_choice'},...
    'OutputActions',{'BNCState',0,strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255});
sma = AddState(sma, 'Name','start_Lin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Lin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Lin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Lin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',LeftPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name','start_Rin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Rin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Rin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Rin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',RightPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'rewarded_Lin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {LeftPortOut,'rewarded_Lin_grace','Tup','rewarded_Lin'},...
    'OutputActions', Wire1OutCorrect);
sma = AddState(sma, 'Name', 'rewarded_Lin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {LeftPortOut,'rewarded_Lin_grace','Tup','water_L','GlobalTimer1_End','water_L'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'rewarded_Lin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'rewarded_Lin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'rewarded_Rin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {RightPortOut,'rewarded_Rin_grace','Tup','rewarded_Rin'},...
    'OutputActions', Wire1OutCorrect);
sma = AddState(sma, 'Name', 'rewarded_Rin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {RightPortOut,'rewarded_Rin_grace','Tup','water_R','GlobalTimer1_End','water_R'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'rewarded_Rin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'rewarded_Rin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Lin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {LeftPortOut,'unrewarded_Lin_grace','Tup','unrewarded_Lin'},...
    'OutputActions', Wire1OutError); 
sma = AddState(sma, 'Name', 'unrewarded_Lin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {LeftPortOut,'unrewarded_Lin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {}); 
sma = AddState(sma, 'Name', 'unrewarded_Lin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'unrewarded_Lin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Rin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {RightPortOut,'unrewarded_Rin_grace','Tup','unrewarded_Rin'},...
    'OutputActions', Wire1OutError);
sma = AddState(sma, 'Name', 'unrewarded_Rin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {RightPortOut,'unrewarded_Rin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Rin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'unrewarded_Rin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', LeftValve});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', RightValve});
sma = AddState(sma, 'Name', 'timeOut_BrokeFixation',...
    'Timer',TaskParameters.GUI.TimeOutBrokeFixation,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11});
sma = AddState(sma, 'Name', 'timeOut_EarlyWithdrawal',...
    'Timer',TaskParameters.GUI.TimeOutEarlyWithdrawal,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11});
if  TaskParameters.GUI.IncorrectChoiceFBType == 2 % IncorrectChoiceFBType == Tone
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'SoftCode',11});
elseif  TaskParameters.GUI.IncorrectChoiceFBType == 3 % IncorrectChoiceFBType == PortLED
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',0.1,...
        'StateChangeConditions',{'Tup','timeOut_IncorrectChoice2'},...
        'OutputActions',{strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(CenterPort)),255,strcat('PWM',num2str(RightPort)),255});
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice2',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,... 
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{});
else % IncorrectChoiceFBType == None
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{});
end
if  TaskParameters.GUI.SkippedFeedbackFBType == 2 % SkippedFeedbackFBType == Tone
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'SoftCode',12});
elseif  TaskParameters.GUI.SkippedFeedbackFBType == 3 % SkippedFeedbackFBType == PortLED
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',0.1,...
        'StateChangeConditions',{'Tup','timeOut_SkippedFeedback2'},...
        'OutputActions',{strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(CenterPort)),255,strcat('PWM',num2str(RightPort)),255});
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback2',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,... 
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{});
else % SkippedFeedbackFBType == None
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{});
end
sma = AddState(sma, 'Name', 'skipped_feedback',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','timeOut_SkippedFeedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'missed_choice',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'ITI',...
    'Timer',max(TaskParameters.GUI.ITI,0.5),...
    'StateChangeConditions',{'Tup','exit'},...
    'OutputActions',{}); % 'SoftCode',9 Sets flow rates for next trial
% sma = AddState(sma, 'Name', 'state_name',...
%     'Timer', 0,...
%     'StateChangeConditions', {},...
%     'OutputActions', {});
end
