function [X, Y ] = pull_dqTime( eset, varargin )
%plotXt Pull value from MAGAT data structure to plot

%key parameters
%   eset.track.startFrame
%   eset.track.endFrame
%  -where i=worm/track over 7199 frames & j=frame within track
%   eset.track(i).pt(j).dq.eti %estimated time
%   eset.track(i).pt(j).loc % position of point: [x;y]

% Set defaults
field='pathlength'; % position of point [x,y]; other options include 'pathLength' &'speed'
dim=1; % x dimension or temperature in 'loc' field
duRun=3600;

varargin=assignApplicable(varargin);

for foo=1:numel(eset)
    trakCnt=length(eset(foo).track);
    trakLen=nan([trakCnt,1]); % longest list of derived quantities
    for ii=1:trakCnt
        trakLen(ii)=length(eset(foo).track(ii).dq.eti);
    end
    X=nan([trakCnt,max(trakLen)]);
    Y=nan([trakCnt,max(trakLen)]);
    % create two matrices with Y & X values
    % each column is a single track, X(j,i) & Y(j,i)
    for ii=1:trakCnt
        for jj=1:trakLen(ii)
            X(ii,1:trakLen(ii))=eset(foo).track(ii).dq.eti;
            Y(ii,1:trakLen(ii))=eset(foo).track(ii).dq.(field)(dim,:);
        end
    end
end
X=X';
Y=Y';

end