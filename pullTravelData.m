function [stepTravs, tSteps, sampLens] = pullTravelData(exptSet)
%pullTravelData Extract information for speed analysis from MAGAT-derived esets 

% Outputs:  
% % stepTravs,  travel distance per step.
% % tSteps, sampling interval time step.
% % sampLens, total sample count.

% Initialize variables
numSamp=length(exptSet);
stepTravs=cell([numSamp,1]); % travel distance per step.
tSteps=nan([numSamp,1]); % sampling interval.
sampLens=nan([numSamp,1]); % total sample count.
esets=cell([numSamp,1]);
yBins=cell([numSamp,1]);
xMats=cell([numSamp,1]);
yMats=cell([numSamp,1]);
tMats=cell([numSamp,1]);
speeds=cell([numSamp,1]);
maxLen=0;

% Optional figure of travel over time for each worm
figOpt=0;

p1={}; p2={}; p3={};
yDim1=[0,2]; yDim2=[0,22000]; xDim=[0,120];
posPlan=[0.2,0.2,0.5,0.75];
for ii=1:numSamp
    eSet=exptSet(ii).experiment_1;
    [ xMat,yMat,zMat,tMat ] = extractValues( eSet );
    stepTrav=hypot(diff(xMat,[],2), diff(yMat,[],2));
    timeVect=(0:tSteps(ii):(tSteps(ii)*(sampLens(ii)-2)))/60;
    if figOpt
        figure(); hold on;
        pl{ii}=plot(tMat(:,2:end)'/60,stepTrav','k');
        p2{ii}=plot(timeVect,nanmean(stepTrav,1),'r');
        set(gca,'ylim',yDim1,'xlim',xDim); %,'OuterPosition',posPlan);
        xlabel('time (min)');
        ylabel('speed');
        title(grpNames{ii})
        figure()
        p3{ii}=plot(tMat(:,2:end)'/60,cumsum(stepTrav','omitnan'),'k');
        set(gca,'ylim',yDim2,'xlim',xDim); %,'OuterPosition',posPlan);
        xlabel('time (min)');
        ylabel('Distance traveled');
        title(grpNames{ii});
    end
    
    % store for later.
    esets{ii}=eSet;
    xMats{ii}=xMat;
    yMats{ii}=yMat;
    tMats{ii}=tMat;
    stepTravs{ii}=stepTrav;
    tSteps(ii)=mode(nanmean(diff(tMat')));
    sampLens(ii)=size(tMat,2);
    maxLen=max(maxLen,sampLens(ii));
end
end

