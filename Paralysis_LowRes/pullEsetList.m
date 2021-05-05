function [fileList] = pullEsetList(dataDir,esetType)
%%pullEsetList. Collects information about where eset data are located.

% Input
% dataDir, parent folder with each subfolder containing esets as .mat files
% esetType, 'poststitch' or 'postclean'; 

% output: fileList is struct with fields fname & folder pointing to files


%% 
% Get a list of all files and folders in this folder.
dFiles = dir(dataDir);
% Get a logical vector that tells which is a directory.
dirFlags = [dFiles.isdir];
% Extract only those that are directories.
subFolders = dFiles(dirFlags);
%remove . and ..
subFolders(ismember( {subFolders.name}, {'.', '..'})) = [];  

% find .mat data, with final string matching filter
matFilter= 'poststitch_experiment_1.mat'; % all data end in this string
fileList=subFolders; % structure array pointing to data locations
fileList(:)=[]; % empty array of prior contents
for ii=1:length(subFolders)
    % Get a list of all files and folders in this folder.
    subList=dir(fullfile(subFolders(ii).folder,subFolders(ii).name));
    % Create logical to extract those matching filter
    slogic=logical([length(subList),1]);
    for jj=1:length(subList)
        slogic(jj)=contains(subList(jj).name,matFilter);
    end
    % add new files to list
    fileList=[fileList,subList(slogic)];
    % Could add recursion here on folders if ever needed.
end

end

