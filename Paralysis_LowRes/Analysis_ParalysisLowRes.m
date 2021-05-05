%% %% Analysis of paralysis caused by muscle expression of HyCal receptor...
% & pan-neuronal HyPep

%% Pull data for analysis & sort for bar graph order.
% assumes 'data' folder in working directory
dataDir=fullfile(pwd,'data');
if ~exist(dataDir)
    dataDir=uigetdir('C:\', 'Where are data?');
end
[fileList] = pullEsetList(dataDir,'poststitch');

% Re-order for better illustration/comparison in bar graph
gList={'TG+','egl3-TG+','N2','egl3','NPalone','elt7'};
vOrd=[3,1,5,6,4,2];
fileList=fileList(vOrd);
gList=gList(vOrd);

%% Extract position & speed data.
speed=cell([length(fileList),1]); % speed estimates from fit of position data

xL=[0,1800]; % x limits based on time of assay
yL_PL=[0,3000]; % y-axis limits for path length

for ii=1:length(fileList)
    curData=fullfile(fileList(ii).folder,fileList(ii).name); % current data file
    % trim '_experiment_1.mat' from name (17char), needed for Samuel lab MAGAT code.
    curData=curData(1:end-17);
    % load eset
    eset=ExperimentSet.fromMatFiles(curData); % from MAGAT
    % Process to create 'derived quantities' such as speed and pathLength
    eset.expt(1).segmentTracks(); % from MAGAT
    
    % Extract pathlength data from experiment
    [tim,displacement]=pull_dqTime(eset.expt,'field','pathLength');
    
    % Take overall speed estimate for each as curve fit
    [speed{ii}] = fitEach(tim,displacement);
    
end

% Create nan-buffered matrix for speed values
[ speed] = combineGroups( speed );

% Unit conversion from pixels to mm: 
% Based on measurement of arena (22mm) imaged with 1800 pixels
mmtoPix=11/90;
speed=speed*mmtoPix;

%% Bar plot
[fh] = plotEachPointBar( speed);
sl=get(gca,'xlim');
sigLevel=10;
yMax=ceil(sigLevel*max(max(abs(speed))))/sigLevel; yMin=0;
yMax=0.22;
set(gca,'xlim',[0,sl(2)+sl(1)],'ylim',[yMin,yMax],'fontsize',15);
ylabel('Migration speed (mm/sec)');

workDir=pwd;
saveName='QuantBar_MigSpeed';
saveas(gcf, fullfile(workDir,[saveName,'.fig']));
vectorSave(gcf, fullfile(workDir,[saveName,'.pdf']));

%% Export data calls
outName='HySyn_MigrationData.xls';
T = table(speed);
writetable(T,outName);



