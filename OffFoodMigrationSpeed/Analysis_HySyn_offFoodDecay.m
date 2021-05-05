%% Analysis_HySyn_offFoodDecay
% Goal. Examine kinetics of HySyn effect based on movement of animals when
% off of food (expected to relieve presynaptic NSM activation).
cd('E:\HySyn_Github_scripts\GithubScripts\OffFoodMigrationSpeed')

%% Define data locations
dataDir=fullfile(pwd,'data'); % Assumes data location wrt working directory;
if ~exist(dataDir,'dir')
    dataDir= uigetdir(pwd, 'Where are the data?');
end
% cd(dataDir);
fileList=dir([dataDir, '/*.mat']);
grpNames=cell([length(fileList),1]);

%% add function folders to search path
funDir='C:\Users\jshha\Dropbox\ColonRamosLab\Matlab\thermotaxisAnalysis';
if ~exist(funDir,'dir')
    funDir=uigetdir(pwd, 'Where are the functions?');
end
addpath(genpath(funDir));
addpath(genpath(pwd));

%% Load data from each 'postclean' file produced by MAGAT
% load each member of 'fileList' as
for ii=1:length(fileList)
    if ~exist('exptSet','var')
        exptSet=load(fileList(ii).name);
    else
        exptSet(ii)=load(fileList(ii).name);
    end
    fbits=strsplit(fileList(ii).name,'_Tc20');
    grpNames{ii}=fbits{1};
end

%% Extract relevant values from experiments in eSets
% % target variables:  
% % stepTravs,  travel distance (initially in pixels) per step.
% % tSteps, sampling interval.
% % sampLens, total sample count.
[stepTravs, tSteps, sampLens] = pullTravelData(exptSet);

%% Convert step travs to distance
% Use mm/pixel conversion () to turn into useful distance travel & speed
% Measured in 'Analysis_FindPixelScale.m'
load('C:\Users\jshha\Documents\HySyn\OffFood-Dispersion\mmPixelConversionFactors_25-Jan-2021.mat');
for ii=1:length(stepTravs)
    stepTravs{ii}=stepTravs{ii}.*mmPerPixel; % Convert to mm rather than pixels
end

%% Smooth & downsample individual tracks (per worm smoothing)
% required due to memory issues, but helpful to reduce fits & starts of
% behavior.
yL=0.075; % y-axis limit

sWin=600; % 120 frames ~= 60sec; smooth each track as building variables...
sampMin=120*60; % prior static analysis showed 2hr sufficient to eliminate effect of HySyn
TSs=cell(size(tSteps)); % holder for new time series... put into a single if/after aligning time

% Make timeseries to downsample, smooth along the way
for ii=1:length(tSteps)
    sampWin=ceil(sampMin/tSteps(ii));
    timVect=(0:tSteps(ii):(tSteps(ii)*(sampWin-1)));
    datVect=stepTravs{ii};
    datVect=datVect(:,1:sampWin)'; % just sample time window of interest
    smoothDatVect=smoothdata(datVect,'sgolay',sWin);
    smoothDatVect(isnan(datVect))=nan; % compromise b/c can't use nanflag & window... smFact seems to change dramatically bw samples
    TSs{ii}=timeseries(smoothDatVect,timVect);
end

[ts1,ts2] = synchronize(TSs{1},TSs{2},'Uniform','Interval',1); % subsample to 1sec

% mean & std after smoothing individual tracks.
clrs={'k','r'};

spMn1=nanmean(ts1.data,2);
stdMn1=nanstd(ts1.data,[],2);
cntMn1=sum(~isnan(ts1.data)')';
CI95mn1=stdMn1./sqrt(cntMn1);

spMn2=nanmean(ts2.data,2);
stdMn2=nanstd(ts2.data,[],2);
cntMn2=sum(~isnan(ts2.data)')';
CI95mn2=stdMn2./sqrt(cntMn2);


yL=0.075;
figure(); hold on
figName=['SmoothInput-',num2str(sWin*.5),'sec with 95CI'];
plot(ts1.time/60, spMn1,'color',clrs{1},'LineWidth',2);
plot(ts1.time/60, spMn2,'color',clrs{2},'LineWidth',2);
legend({'N2','HySyn'})
plot(ts1.time/60,spMn1-CI95mn1,'color',clrs{1},'LineWidth',1);
plot(ts1.time/60, spMn1+CI95mn1,'color',clrs{1},'LineWidth',1);
plot(ts1.time/60,spMn2-CI95mn2,'color',clrs{2},'LineWidth',1);
plot(ts1.time/60, spMn2+CI95mn2,'color',clrs{2},'LineWidth',1);
set(gca,'ylim',[0,yL],'xlim',[0,7200/60])
title(figName)
ylabel('speed (mm/sec)')
xlabel('time (min)')
saveas(gcf, [figName,'_mmMin.png']);
vectorSave(gcf, [figName,'_mmMin.pdf']);

%% Binned analysis.
% clear difference in first 30min (1800 sec); none by last 30min (1800sec)
% get raw data. Average each track over within this period. Find mean &
% 95CI.

% intialize to same size for subsequent table & excel output
N2_first30=nan([1,120]);
HySyn_first30=nan([1,120]);
N2_last30=nan([1,120]);
HySyn_last30=nan([1,120]);

N2_first30(1:size(ts1.data,2))=nanmean(ts1.data(1:1800,:),1);
HySyn_first30(1:size(ts2.data,2))=nanmean(ts2.data(1:1800,:),1);
N2_last30(1:size(ts1.data,2))=nanmean(ts1.data(5401:7200,:),1);
HySyn_last30(1:size(ts2.data,2))=nanmean(ts2.data(5401:7200,:),1);
grps={N2_first30,HySyn_first30,N2_last30,HySyn_last30};
gNames={'N2(0-30m)','HySyn(0-30m)','N2(90-120m)','HySyn(90-120m)'};
dMat=combineGroups(grps);
[fh, ph, ebh] = plotEachPointMean( dMat,'groupLabels',gNames);
saveas(gcf, 'HySyn_BinnedSpeeds_mm.png')

% print dMat to excel for Eli...
outName='HySyn_RawSpeedMeans_FirstLast30_mm.xls';
T = table(N2_first30',HySyn_first30',N2_last30',HySyn_last30');
writetable(T,outName);
