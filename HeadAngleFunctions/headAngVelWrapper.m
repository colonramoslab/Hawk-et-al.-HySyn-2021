function [headAVs,groups] = headAngVelWrapper(dDir,varargin)
%headAngVelWrapper Find all data files (.csv) from DeepLabCut output within
%a directory, dDir, then calculate head angular velocity for each.
sampLabels={}; % Optional sample label
txtY=410;
saveDir='';
pFR=30; % video play frame rate, 30fps is real-time for our videos.
vQC=1; % Logical option to create video QC

varargin=assignApplicable(varargin);

if ~exist('dDir','var')||isempty(dDir)||~exist(dDir,'dir')
    [dDir]=uigetdir('C:\');
end

% Find subfolders to create groups
foldL=dir(dDir); % Group folders
foldL=foldL([foldL(:).isdir]);
foldL=foldL(~ismember({foldL(:).name},{'.','..'}));

headAVs=cell([length(foldL),1]); % outPut of parameter values for each group
groups=cell([length(foldL),1]); % Folder names, also group names
slN=1;

for ii=1:length(foldL) % for each group
    groups{ii}=foldL(ii).name; % make file list from fPath
    fileL=dir([fullfile(foldL(ii).folder,foldL(ii).name), '/*.csv']);
    headAV=nan(size(fileL));
    for jj=1:length(fileL) % For each sample/worm
        fName=fullfile(fileL(jj).folder,fileL(jj).name);
        if length(sampLabels)>=slN
            sL=sampLabels{slN};
        else
            sL='';
        end
        headAV(jj) = getHeadAngVel(fName,...
            'vidQC', vQC,'pFR',pFR,'sampLabel',sL,...
            'txtY',txtY,'saveDir',saveDir);
    end % Loop thru files in a subfolder
    if ~isempty(headAV)
        headAVs{ii}=headAV;
        slN=slN+1;
    end % Handles empty folders, don't count to use of name list
end % End Loop through subfolders

empInd=cellfun(@isempty,headAVs);
headAVs=headAVs(~empInd);
groups=groups(~empInd);
dMat=combineGroups(headAVs);
[fh, ph, ebh] = plotEachPointMean(dMat,'groupLabels',groups)
saveas(gcf, fullfile(dDir,'HeadAngleVelocity.png'))
saveas(gcf, fullfile(dDir,'HeadAngleVelocity.fig'))
% print dMat to excel for Eli...
outName=fullfile(dDir,'HeadAngleVelocity.xls');
vTs=repmat({'double'},size(groups))
T=table('size',size(dMat),'VariableTypes',vTs,'VariableNames',groups);
for ii=1:length(groups)
    T{:,ii}=dMat(:,ii);
end
writetable(T,outName);



