function [fh, ph, ebh] = plotEachPointMean( dMat, varargin )
%plotEachPoint Summary of this function goes here
%   dMat, columns are groups; rows are samples
% TO prepare data into dMat, use combineGroups, if a cell instead..


yLab='arbitrary units of something';
groupLabels={};
interbarFraction=.2; % 20% of width of 'bar' containing points (based on number of samples per condition)
pntColors={'r','g','k'};
mRkr='.';
mRkrSz=15;
errType = '95CI'; % options are '95CI','SEM',or 'STD'
mean_mRkr='.';
mean_mRkrSz=20;
varargin=assignApplicable(varargin);

if iscell(dMat)
    dMat=combineGroups(dMat);
end
[gSize, gCnt]=size(dMat);

while gCnt>length(pntColors)
    pntColors=[pntColors,pntColors];
end

if isempty(groupLabels)
    for i=1:gCnt
        groupLabels{i}=num2str(i);
    end
end



fh=figure(); hold on;


% interbarCount=gCnt+1;
interbarSize=gSize*interbarFraction;
% totalWidth=gCnt*gSize+interbarCount*interbarSize;

posMat=nan(size(dMat));

p0=interbarSize;
pM=nan([gCnt,1]);
for i=1:gCnt
    pM(i)=(p0+gSize/2);
    uMat=unique(dMat(:,i));
    uMat=uMat(~isnan(uMat));
    for j=1:length(uMat)
        matchVals=(dMat(:,i)==uMat(j));
        matchCnt=sum(matchVals);
        posMat(matchVals,i)=(pM(i)-matchCnt/2+0.5):(pM(i)+matchCnt/2-0.5);
    end
    plot(posMat(:,i), dMat(:,i),'color',pntColors{i},'linestyle', 'none',...
        'marker',mRkr,'markersize',mRkrSz);
    p0=p0+gSize+interbarSize;
    
end


ph= plot(pM',nanmean(dMat),'linestyle','none','marker',mean_mRkr,'markersize',mean_mRkrSz);
switch errType
    case 'SEM'
        ebh= errorbar(pM',nanmean(dMat),nanstd(dMat)./sqrt(gSize-1),'linestyle','none');
    case 'STD'
        ebh= errorbar(pM',nanmean(dMat),nanstd(dMat),'linestyle','none');
    case '95CI'
        ebh= errorbar(pM',nanmean(dMat),1.96*nanstd(dMat)./sqrt(gSize),'linestyle','none');
end
ylabel(yLab);
set(gca,'xtick',pM','xticklabels',groupLabels)


end

