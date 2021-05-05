function [myMovie] = headAngleQC(t,angX,angY,dTheta,inVid,outName, varargin)
%headAngleQC. QC video for head angle calls. 

% 'Required' Inputs
% t, time vector for frames
% angX, vector of x coordinates for [frame, part] where position is [nose tip, midhead]
% angY, vector of y coordinates for [frame, part] where position is [nose tip, midhead]
% dTheta, displayed change in angle from last frame.
% inVid, video file for overlay of head angle.
% outName, for save of QC video with file type defined by outType below

% defaults for modifiable parameters
outType='MPEG-4'; % output file type., prior '.avi', trial 'Motion JPEG AVI'
numberOfFrames=300; % 10sec. Leave empty for whole video
playFrameRate=10; % fps of playback from saved avi 
splColor={'y','w'}; % color of angle Markers
respOpt=0; % Chance to review video..
sampLabel='';
txtY=410;
pixelsPerMM= 4.697690242358822e+02; %Empirically measured for our setup.

varargin=assignApplicable(varargin);

% Check type of inVid in case we send wrong info...
if isstring(inVid)
    v = VideoReader(inVid);
    inVid=read(v);
elseif isobject(inVid)
    inVid=read(inVid);
elseif ~isnumeric(inVid)
    warning('I have concerns about inVid...');
end


hFigure = figure;
if isempty(numberOfFrames)
    numberOfFrames = length(t);
end
allTheFrames = cell(numberOfFrames,1);
vidHeight = 480;
vidWidth = 720;
allTheFrames(:) = {zeros(vidHeight, vidWidth, 1, 'uint8')};
% Next get a cell array with all the colormaps.
allTheColorMaps = cell(numberOfFrames,1);
allTheColorMaps(:) = {zeros(256, 3)};
% Now combine these to make the array of structures.
myMovie = struct('cdata', allTheFrames, 'colormap', allTheColorMaps);
% Create a VideoWriter object to write the video out to a new, different file.
% writerObj = VideoWriter([outName,outType]);
writerObj = VideoWriter(outName,outType);
writerObj.FrameRate = playFrameRate;
open(writerObj);
% Need to change from the default renderer to zbuffer to get it to work right.
% openGL doesn't work and Painters is way too slow.
set(gcf, 'renderer', 'zbuffer');

for frameIndex = 1 : numberOfFrames
    
    image(inVid(:,:,:,frameIndex))
    hold on;
    if ~isempty(angX)&&~isempty(angY)
        p1=plot(angX(frameIndex,:),angY(frameIndex,:),splColor{1});
        if frameIndex>1
            p2= plot(angX(frameIndex-1,:),angY(frameIndex-1,:),splColor{2});
        end
    end
    
    if ~isempty(dTheta)&&frameIndex>1
        text(20,20,['\Deltaangle in rad:', num2str(dTheta(frameIndex-1))],'color','w')
        text(20,40,['\Deltaangle in deg:', num2str(rad2deg(dTheta(frameIndex-1)))],'color','w')
    end
    
    timeCapt=sprintf('t = %.1f', t(frameIndex));
    text(600,460,timeCapt,'color','w', 'FontSize', 15);
    
    barLength=0.1*pixelsPerMM; % 100uM
    mmCapt='100\mum';
    text(round((20+barLength)/4),440,mmCapt,'color','k', 'FontSize', 15);
    line([20,20+barLength],[460,460],'LineWidth',5,'Color','k')
    
    if exist('p2','var')
        legend([p1,p2],{'current frame', 'last frame'})
    else
        legend([p1],{'current frame'})
    end
    legend boxoff
    legend 'TextColor' 'w'
    
    caption = sprintf('Frame #%d of %d, t = %.1f', frameIndex, numberOfFrames, t(frameIndex));
    title(caption, 'FontSize', 15);
    set(gca,'visible','off')
    
    if ~isempty(sampLabel)
        text(720/2,txtY,sampLabel,'color','y', 'FontSize', 20,'HorizontalAlignment', 'center');
    end
    
    
    drawnow;
    thisFrame = getframe(gca);
    % Write this frame out to a new video file.
    writeVideo(writerObj, thisFrame);
    myMovie(frameIndex) = thisFrame;
    hold off;
    
end

close(writerObj);

if respOpt
    message = sprintf('Done creating movie\nDo you want to play it?');
    button = questdlg(message, 'Continue?', 'Yes', 'No', 'Yes');
    drawnow;  % Refresh screen to get rid of dialog box remnants.
    close(hFigure);
    if strcmpi(button, 'No')
        return;
    end
    hFigure = figure;
    % % Enlarge figure to full screen.
    % set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
    title('Playing the movie we created', 'FontSize', 15);
    % Get rid of extra set of axes that it makes for some reason.
    axis off;
    % Play the movie.
    movie(myMovie);
    close(hFigure)
    close(writerObj)
else
    close(hFigure)
end

