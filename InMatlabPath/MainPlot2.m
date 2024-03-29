function AxesHandles = MainPlot2(AxesHandles, Action, DataCustom, TaskParametersGUI, TrialStartTimestamp, varargin)
global nTrialsToShow %this is for convenience

switch Action
    case 'init'

        %% Outcome
        %initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display

        if nargin >=6  %custom number of trials
            nTrialsToShow = varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %plot in specified axes
        AxesHandles.Stim = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge',[.5,.5,.5],'MarkerFace',[.7,.7,.7], 'MarkerSize',8);
        AxesHandles.DV = line(1:numel(DataCustom.DV),DataCustom.DV, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        AxesHandles.CurrentTrialCircle = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        AxesHandles.CurrentTrialCross = line(1,0, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        AxesHandles.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        AxesHandles.Correct = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        AxesHandles.Incorrect = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        AxesHandles.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        AxesHandles.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
        AxesHandles.NoFeedback = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',5);
        AxesHandles.NoResponse = line(-1,[0 1], 'LineStyle','none','Marker','x','MarkerEdge','w','MarkerFace','none', 'MarkerSize',6);
        AxesHandles.Catch = line(-1,[0 1], 'LineStyle','none','Marker','o','MarkerEdge',[0,0,0],'MarkerFace',[0,0,0], 'MarkerSize',4);
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-1.25, 1.25], 'YTick', [-1, 1],'YTickLabel', {'Right','Left'}, 'FontSize', 13);
        set(AxesHandles.Stim,'xdata',1:numel(DataCustom.DV),'ydata',DataCustom.DV);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        hold(AxesHandles.HandleOutcome, 'on');
        %% Psyc Stimulus
        AxesHandles.PsycStim = line(AxesHandles.HandlePsycStim,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
        AxesHandles.PsycStimFit = line(AxesHandles.HandlePsycStim,[-1. 1.],[.5 .5],'color','k','Visible','off');
        AxesHandles.PsycStimForced = line(AxesHandles.HandlePsycStim,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6,'Visible','off');
        AxesHandles.PsycStimForcedFit = line(AxesHandles.HandlePsycStim,[-1. 1.],[.5 .5],'color','g','Visible','off');
        AxesHandles.HandlePsycStim.YLim = [-.05 1.05];
        AxesHandles.HandlePsycStim.XLim = [-1.05, 1.05];
        AxesHandles.HandlePsycStim.XLabel.String = 'DV'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycStim.YLabel.String = '% left';
        AxesHandles.HandlePsycStim.Title.String = 'Psychometric Stim';
        %% Vevaiometric curve
        hold(AxesHandles.HandleVevaiometric,'on')
        AxesHandles.VevaiometricCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','g','Visible','off','LineWidth',2);
        AxesHandles.VevaiometricErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','r','Visible','off','LineWidth',2);
        AxesHandles.VevaiometricPointsErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','r','Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','r');
        AxesHandles.VevaiometricPointsCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','g','Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','g');
        AxesHandles.HandleVevaiometric.YLim = [0 20];
        AxesHandles.HandleVevaiometric.XLim = [-1.05, 1.05];
        AxesHandles.HandleVevaiometric.XLabel.String = 'DV';
        AxesHandles.HandleVevaiometric.YLabel.String = 'WT (s)';
        AxesHandles.HandleVevaiometric.Title.String = 'Vevaiometric';
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        AxesHandles.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';
        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';
        %% ST histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Stim sampling time';
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'trial counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';
    case 'update'
        %% Reposition and hide/show axes
        ShowPlots = [TaskParametersGUI.ShowPsycStim,TaskParametersGUI.ShowVevaiometric,...
                     TaskParametersGUI.ShowTrialRate,TaskParametersGUI.ShowFix,TaskParametersGUI.ShowST,TaskParametersGUI.ShowFeedback];
        NoPlots = sum(ShowPlots);
        NPlot = cumsum(ShowPlots);
        if ShowPlots(1)
            AxesHandles.HandlePsycStim.Position =      [NPlot(1)*.05+0.005 + (NPlot(1)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandlePsycStim.Visible = 'on';
            set(get(AxesHandles.HandlePsycStim,'Children'),'Visible','on');
        else
            AxesHandles.HandlePsycStim.Visible = 'off';
            set(get(AxesHandles.HandlePsycStim,'Children'),'Visible','off');
        end
        if ShowPlots(2)
            AxesHandles.HandleVevaiometric.Position = [NPlot(2)*.05+0.005 + (NPlot(2)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandleVevaiometric.Visible = 'on';
            set(get(AxesHandles.HandleVevaiometric,'Children'),'Visible','on');
        else
            AxesHandles.HandleVevaiometric.Visible = 'off';
            set(get(AxesHandles.HandleVevaiometric,'Children'),'Visible','off');
        end
        if ShowPlots(3)
            AxesHandles.HandleTrialRate.Position =    [NPlot(3)*.05+0.005 + (NPlot(3)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandleTrialRate.Visible = 'on';
            set(get(AxesHandles.HandleTrialRate,'Children'),'Visible','on');
        else
            AxesHandles.HandleTrialRate.Visible = 'off';
            set(get(AxesHandles.HandleTrialRate,'Children'),'Visible','off');
        end
        if ShowPlots(4)
            AxesHandles.HandleFix.Position =          [NPlot(4)*.05+0.005 + (NPlot(4)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandleFix.Visible = 'on';
            set(get(AxesHandles.HandleFix,'Children'),'Visible','on');
        else
            AxesHandles.HandleFix.Visible = 'off';
            set(get(AxesHandles.HandleFix,'Children'),'Visible','off');
        end
        if ShowPlots(5)
            AxesHandles.HandleST.Position =           [NPlot(5)*.05+0.005 + (NPlot(5)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandleST.Visible = 'on';
            set(get(AxesHandles.HandleST,'Children'),'Visible','on');
        else
            AxesHandles.HandleST.Visible = 'off';
            set(get(AxesHandles.HandleST,'Children'),'Visible','off');
        end
        if ShowPlots(6)
            AxesHandles.HandleFeedback.Position =     [NPlot(6)*.05+0.005 + (NPlot(6)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            AxesHandles.HandleFeedback.Visible = 'on';
            set(get(AxesHandles.HandleFeedback,'Children'),'Visible','on');
        else
            AxesHandles.HandleFeedback.Visible = 'off';
            set(get(AxesHandles.HandleFeedback,'Children'),'Visible','off');
        end

        %% Outcome
        iTrial = varargin{1};
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim

        set(AxesHandles.CurrentTrialCircle, 'xdata', iTrial+1, 'ydata', 0);
        set(AxesHandles.CurrentTrialCross, 'xdata', iTrial+1, 'ydata', 0);

        %plot modality background
        set(AxesHandles.Stim,'xdata',1:numel(DataCustom.DV),'ydata',DataCustom.DV);
        %plot past&future trials
        set(AxesHandles.DV, 'xdata', mn:numel(DataCustom.DV), 'ydata',DataCustom.DV(mn:end));

        %Plot past trial outcomes
        indxToPlot = mn:iTrial;
        %Cumulative Reward Amount
        R = DataCustom.RewardMagnitude;
        RCP = sum(DataCustom.CenterPortRewAmount(DataCustom.RewardAfterMinSampling)); %ones(1,size(DataCustom.RewardMagnitude,1))*0.5;
        ndxRwd = DataCustom.Rewarded;
        C = zeros(size(R)); C(DataCustom.ChoiceLeft==1&ndxRwd,1) = 1; C(DataCustom.ChoiceLeft==0&ndxRwd,2) = 1;
        R = R.*C;
        RewardObtained = sum([sum(R(:)) sum(RCP)]) + sum(DataCustom.PreStimCntrReward);
        set(AxesHandles.CumRwd, 'position', [iTrial+1 1], 'string', ...
            [num2str(RewardObtained/1000) ' mL']);
        clear R C
        %Plot Rewarded
        ndxCor = DataCustom.ChoiceCorrect(indxToPlot)==1;
        Xdata = indxToPlot(ndxCor);
        Ydata = DataCustom.DV(indxToPlot); Ydata = Ydata(ndxCor);
        set(AxesHandles.Correct, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Incorrect
        ndxInc = DataCustom.ChoiceCorrect(indxToPlot)==0;
        Xdata = indxToPlot(ndxInc);
        Ydata = DataCustom.DV(indxToPlot); Ydata = Ydata(ndxInc);
        set(AxesHandles.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Broken Fixation
        ndxBroke = DataCustom.FixBroke(indxToPlot);
        Xdata = indxToPlot(ndxBroke); Ydata = zeros(1,sum(ndxBroke));
        set(AxesHandles.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Early Withdrawal
        ndxEarly = DataCustom.EarlyWithdrawal(indxToPlot);
        Xdata = indxToPlot(ndxEarly);
        Ydata = zeros(1,sum(ndxEarly));
        set(AxesHandles.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
        %Plot missed choice trials
        ndxMiss = isnan(DataCustom.ChoiceLeft(indxToPlot))&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxMiss);
        Ydata = DataCustom.DV(indxToPlot); Ydata = Ydata(ndxMiss);
        set(AxesHandles.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        %Plot NoFeedback trials
        ndxNoFeedback = ~DataCustom.Feedback(indxToPlot);
        Xdata = indxToPlot(ndxNoFeedback&~ndxMiss);
        Ydata = DataCustom.DV(indxToPlot); Ydata = Ydata(ndxNoFeedback&~ndxMiss);
        set(AxesHandles.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        %Plot catch trials
        ndxCatch = DataCustom.CatchTrial(indxToPlot);
        Xdata = indxToPlot(ndxCatch&~ndxMiss);
        Ydata = DataCustom.DV(indxToPlot); Ydata = Ydata(ndxCatch&~ndxMiss);
        set(AxesHandles.Catch, 'xdata', Xdata, 'ydata', Ydata);
        %% Psych Stim
        if TaskParametersGUI.ShowPsycStim
            ndxNan = isnan(DataCustom.ChoiceLeft);
            ndxChoice = DataCustom.ForcedLEDTrial(1:numel(DataCustom.ChoiceLeft))==0;
            ndxForced = DataCustom.ForcedLEDTrial(1:numel(DataCustom.ChoiceLeft))==1;
            StimDV = DataCustom.DV(1:numel(DataCustom.ChoiceLeft));
            StimBin = 8;
            BinIdx = discretize(StimDV,linspace(min(StimDV),max(StimDV),StimBin+1));

            % Choice trials
            PsycY = grpstats(DataCustom.ChoiceLeft(~ndxNan&ndxChoice),BinIdx(~ndxNan&ndxChoice),'mean');
            PsycX = unique(BinIdx(~ndxNan&ndxChoice))/StimBin*2-1-1/StimBin;
            AxesHandles.PsycStim.YData = PsycY;
            AxesHandles.PsycStim.XData = PsycX;
            if sum(~ndxNan&ndxChoice) > 1
                AxesHandles.PsycStimFit.XData = linspace(min(StimDV),max(StimDV),100);
                AxesHandles.PsycStimFit.YData = glmval(glmfit(StimDV(~ndxNan&ndxChoice),...
                    DataCustom.ChoiceLeft(~ndxNan&ndxChoice)','binomial'),linspace(min(StimDV),max(StimDV),100),'logit');
            end

            % Forced trials
            PsycY = grpstats(DataCustom.ChoiceLeft(~ndxNan&ndxForced),BinIdx(~ndxNan&ndxForced),'mean');
            PsycX = unique(BinIdx(~ndxNan&ndxForced))/StimBin*2-1-1/StimBin;
            AxesHandles.PsycStimForced.YData = PsycY;
            AxesHandles.PsycStimForced.XData = PsycX;
            if sum(~ndxNan&ndxForced) > 1
                AxesHandles.PsycStimForcedFit.XData = linspace(min(StimDV),max(StimDV),100);
                AxesHandles.PsycStimForcedFit.YData = glmval(glmfit(StimDV(~ndxNan&ndxForced),...
                    DataCustom.ChoiceLeft(~ndxNan&ndxForced)','binomial'),linspace(min(StimDV),max(StimDV),100),'logit');
            end
        end
        %% Vevaiometric
        if TaskParametersGUI.ShowVevaiometric
            AxesHandles.HandleVevaiometric.YLim = [0 TaskParametersGUI.VevaiometricYLim];
            set(AxesHandles.HandleVevaiometric,'YLim', [0 TaskParametersGUI.VevaiometricYLim]);
            ndxError = DataCustom.ChoiceCorrect(1:iTrial) == 0 ; %all (completed) error trials (including catch errors)
            ndxCorrectCatch = DataCustom.CatchTrial(1:iTrial) & DataCustom.ChoiceCorrect(1:iTrial) == 1; %only correct catch trials
            ndxMinWT = DataCustom.FeedbackTime > TaskParametersGUI.VevaiometricMinWT;
            DV = DataCustom.DV(1:iTrial);
            DVNBin = TaskParametersGUI.VevaiometricNBin;
            BinIdx = discretize(DV,linspace(min(StimDV),max(StimDV),DVNBin+1));
            WTerr = grpstats(DataCustom.FeedbackTime(ndxError&ndxMinWT),BinIdx(ndxError&ndxMinWT),'mean')';
            WTcatch = grpstats(DataCustom.FeedbackTime(ndxCorrectCatch&ndxMinWT),BinIdx(ndxCorrectCatch&ndxMinWT),'mean')';
            Xerr = unique(BinIdx(ndxError&ndxMinWT))/DVNBin*2-1-1/DVNBin;
            Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT))/DVNBin*2-1-1/DVNBin;
            AxesHandles.VevaiometricErr.YData = WTerr;
            AxesHandles.VevaiometricErr.XData = Xerr;
            AxesHandles.VevaiometricCatch.YData = WTcatch;
            AxesHandles.VevaiometricCatch.XData = Xcatch;
            if TaskParametersGUI.VevaiometricShowPoints
                AxesHandles.VevaiometricPointsErr.YData = DataCustom.FeedbackTime(ndxError&ndxMinWT);
                AxesHandles.VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT);
                AxesHandles.VevaiometricPointsCatch.YData = DataCustom.FeedbackTime(ndxCorrectCatch&ndxMinWT);
                AxesHandles.VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT);
            else
                AxesHandles.VevaiometricPointsErr.YData = -1;
                AxesHandles.VevaiometricPointsErr.XData = 0;
                AxesHandles.VevaiometricPointsCatch.YData = -1;
                AxesHandles.VevaiometricPointsCatch.XData = 0;
            end
        end
        %% Trial rate
        if TaskParametersGUI.ShowTrialRate
            AxesHandles.TrialRate.XData = (TrialStartTimestamp-min(TrialStartTimestamp))/60;
            AxesHandles.TrialRate.YData = 1:numel(DataCustom.ChoiceLeft);
        end
        if TaskParametersGUI.ShowFix
            %% Stimulus delay
            cla(AxesHandles.HandleFix)
            AxesHandles.HistBroke = histogram(AxesHandles.HandleFix,DataCustom.FixDur(DataCustom.FixBroke)*1000);
            AxesHandles.HistBroke.BinWidth = 50;
            AxesHandles.HistBroke.EdgeColor = 'none';
            AxesHandles.HistBroke.FaceColor = 'r';
            AxesHandles.HistFix = histogram(AxesHandles.HandleFix,DataCustom.FixDur(~DataCustom.FixBroke)*1000);
            AxesHandles.HistFix.BinWidth = 50;
            AxesHandles.HistFix.FaceColor = 'b';
            AxesHandles.HistFix.EdgeColor = 'none';
            BreakP = mean(DataCustom.FixBroke);
            cornertext(AxesHandles.HandleFix,sprintf('P=%1.2f',BreakP))
        end
        %% ST
        if TaskParametersGUI.ShowST
            cla(AxesHandles.HandleST)
            AxesHandles.HistSTEarly = histogram(AxesHandles.HandleST,DataCustom.ST(DataCustom.EarlyWithdrawal)*1000);
            AxesHandles.HistSTEarly.BinWidth = 50;
            AxesHandles.HistSTEarly.FaceColor = 'r';
            AxesHandles.HistSTEarly.EdgeColor = 'none';
            AxesHandles.HistST = histogram(AxesHandles.HandleST,DataCustom.ST(~DataCustom.EarlyWithdrawal)*1000);
            AxesHandles.HistST.BinWidth = 50;
            AxesHandles.HistST.FaceColor = 'b';
            AxesHandles.HistST.EdgeColor = 'none';
            EarlyP = sum(DataCustom.EarlyWithdrawal)/sum(~DataCustom.FixBroke);
            cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        end
        %% Feedback delay (exclude catch trials and error trials, if set on catch)
        if TaskParametersGUI.ShowFeedback
            cla(AxesHandles.HandleFeedback)
            if TaskParametersGUI.CatchError
                ndxExclude = DataCustom.ChoiceCorrect(1:iTrial) == 0; %exclude error trials if they are set on catch
            else
                ndxExclude = false(1,iTrial);
            end
            AxesHandles.HistNoFeed = histogram(AxesHandles.HandleFeedback,DataCustom.FeedbackTime(~DataCustom.Feedback(1:iTrial)&~DataCustom.CatchTrial(1:iTrial)&~ndxExclude)*1000);
            AxesHandles.HistNoFeed.BinWidth = 100;
            AxesHandles.HistNoFeed.EdgeColor = 'none';
            AxesHandles.HistNoFeed.FaceColor = 'r';
            %AxesHandles.HistNoFeed.Normalization = 'probability';
            AxesHandles.HistFeed = histogram(AxesHandles.HandleFeedback,DataCustom.FeedbackTime(DataCustom.Feedback(1:iTrial)&~DataCustom.CatchTrial(1:iTrial)&~ndxExclude)*1000);
            AxesHandles.HistFeed.BinWidth = 50;
            AxesHandles.HistFeed.EdgeColor = 'none';
            AxesHandles.HistFeed.FaceColor = 'b';
            %AxesHandles.HistFeed.Normalization = 'probability';
            LeftSkip = sum(~DataCustom.Feedback(1:iTrial)&~DataCustom.CatchTrial(1:iTrial)&~ndxExclude&DataCustom.ChoiceLeft(1:iTrial)==1)/sum(~DataCustom.CatchTrial(1:iTrial)&~ndxExclude&DataCustom.ChoiceLeft(1:iTrial)==1);
            RightSkip = sum(~DataCustom.Feedback(1:iTrial)&~DataCustom.CatchTrial(1:iTrial)&~ndxExclude&DataCustom.ChoiceLeft(1:iTrial)==0)/sum(~DataCustom.CatchTrial(1:iTrial)&~ndxExclude&DataCustom.ChoiceLeft(1:iTrial)==0);
            cornertext(AxesHandles.HandleFeedback,{sprintf('L=%1.2f',LeftSkip),sprintf('R=%1.2f',RightSkip)})
        end
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end

