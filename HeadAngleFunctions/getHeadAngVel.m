function [headAV] = getHeadAngVel(fName,varargin)
%getHeadAngVel. Find the change in head angle over time

vidQC=0; % set to 1 to create a QC video to show angular velocity vectors & calls for sample
fps=30; % Confirmed with Eli 210128 that our videos are 30 frames/sec
sampLabel='';
txtY=410;
saveDir='';
pFR=30; % frame rate for output play... at 30 same as vids by Eli, ie real-time
varargin=assignApplicable(varargin);

headAV=[]; % init output, median head angular velocity across sample video

%% Read data into matlab.
inData=readmatrix(fName);

%% Create indices for X & Y position information
% xInd & yInd will point to relevant columns
% X/Y pairs: {frame}, 2,3; 5,6; 8,9...
% 3xBodyParts(8)+frame(1)-2,3xBodyParts(8)+frame(1)-1,(25)
xInd=[];
yInd=[];
for ii=0:((size(inData,2)-1)/3-1)
    xInd(ii+1)=3*ii+2;
    yInd(ii+1)=3*ii+3;
end

%% Get Head Radial Velocity
% Extract x & y for head
indPnt1=1; % Nose
posX1=inData(:,xInd(indPnt1));
posY1=inData(:,yInd(indPnt1));
indPnt2=2; % Central head
posX2=inData(:,xInd(indPnt2));
posY2=inData(:,yInd(indPnt2));
% Angle b/w points, ang=...
% subtract second point to make all the same origin...
x=posX1-posX2; y=posY1-posY2;
% Calculate change in angle
cosTheta=zeros([length(x)-1,1]);
dTheta=zeros([length(x)-1,1]);
for ii=1:(length(x)-1)
    u=[x(ii),y(ii)]; % vector at frame ii
    v=[x(ii+1),y(ii+1)]; % vector at frame ii+1
    cosTheta(ii) = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1); % cos of theta
    dTheta(ii) = real(acos(cosTheta(ii))); % rad/frame
end
headAV=median(dTheta)*fps; % rad/f * f/s, Should be robust to substantial noise


%% QC Video. Illustrate each angle & animate into a movie...
if vidQC
    
    t=(1:length(x))./fps; % time vector for frames
    angX=[posX1,posX2]; angY=[posY1,posY2]; % vector of [head,neck] for each frame
    
    % Output naming, option for saveDir, else save to source file location
    
    fBase=strsplit(fName,'.');
    vidName=[fBase{1},'_labeled.mp4']; % requires base video to be in same directory
    if isempty(saveDir)
        outName=[fBase{1},'_headAngQC'];
    else
        if ~exist(saveDir,'dir')
            mkdir(saveDir)
        end
        [~,fN,~]=fileparts(fName);
        outName=fullfile(saveDir,[fN,'_headAngQC']);
    end
    
    % Input source video if it exist & create QC movie
    if exist(vidName,'file')
        v = VideoReader(vidName);
        inVid=read(v);
        [myMovie] = headAngleQC(t,angX,angY,dTheta,inVid,outName,...
            'txtY',txtY,'sampLabel',sampLabel,'playFrameRate',pFR);
    end
       
end

