function [ xMat,yMat,zMat,tMat ] = extractValues( eset )
%extractValues pull values for position & time into matrices to ease figure
%making
runDur=length(eset.elapsedTime);
tMat=nan([length(eset.track),runDur]);
xMat=nan([length(eset.track),runDur]);
yMat=nan([length(eset.track),runDur]);
zMat=nan([length(eset.track),runDur]);


for j = 1:length(eset);
    for k = 1:length(eset(j).track);
        trk=eset(j).track(k);
        t=eset.track(k).dq.eti;
        fR=mean(diff(t));
        f=ceil(t./fR+1);
        x=(trk.dq.sloc(1,:));
        y=(trk.dq.sloc(2,:));
        z=(trk.dq.theta(:));
        try
            if f(end)>runDur 
                runName=eset.fname;
%                 warning('For track %i of %s, length of track was %i', k, runName,f(end));
                LV=runDur;
            else
                LV=f(end);
            end
            indTemp=f(1):LV;
            xMat(k,indTemp)=x(1:length(indTemp));
            yMat(k,indTemp)=y(1:length(indTemp));
            zMat(k,indTemp)=z(1:length(indTemp));
            tMat(k,indTemp)=t(1:length(indTemp));
        catch
            warning('WHAT?')
        end
    end
end

end

