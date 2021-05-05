function [ fh] = plotEachPointBar( dMat, varargin )
%plotEachPoint Bar graph with each point overlayed
%   dMat, columns are groups; rows are samples

if iscell(dMat)
    [ dMat ] = combineGroups( dMat );
end

[gSize, gCnt]=size(dMat);
groupLabels={};
interbarFraction=.2; % 20% of width of 'bar' containing points (based on number of samples per condition)
pntColors={'r','g','k'};
barColors=rand([1,3]);
markC='.';
markS=10;

varargin=assignApplicable(varargin);

if isempty(groupLabels)
    for i=1:gCnt
        groupLabels{i}=num2str(i);
    end
end


if length(pntColors)<gCnt
    pntColors=cell([gCnt,1]);
    for i=1:gCnt
        pntColors{i}=rand([3,1]);
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
        'marker',markC,'markerSize',markS);
    p0=p0+gSize+interbarSize;
end


bar(pM',nanmean(dMat),'facecolor',barColors);
set(gca,'children',flipud(get(gca,'children')));
errorbar(pM',nanmean(dMat),nanstd(dMat)./sqrt(gSize-1),'linestyle','none');
ylabel('Response Frequency (Hz)');
set(gca,'xtick',pM','xticklabels',groupLabels)


end

