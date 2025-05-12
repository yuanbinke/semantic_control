%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - dcm2niix (accessed via MRIcroGL package): https://www.nitrc.org/projects/mricrogl/
% Notes: This script was manually written and uses the dcm2niix executable
% (included with MRIcroGL) for DICOM to NIfTI conversion. It requires 
% specific local file paths and input data to run properly.
%-----------------------------------------------------------------------


clear;
clc;
drive='F:\fMRI_data\preproc';

%% fMRI

cd(fullfile(drive,'FunRaw'))
sublist=dir('sub*');
for s=1:length(sublist)
    
    inputDir=fullfile(drive,'FunRaw',sublist(s).name);
    outputDir=fullfile(drive,'FunImg',sublist(s).name);
    mkdir(outputDir);
    
    DirDCM=dir([inputDir,'\*.*']);
    InputFilename=[inputDir,'\',DirDCM(3).name];
    eval(['!','D:\software\MRIcroGL_windows\MRIcroGL\Resources\dcm2niix.exe -g N -o ',outputDir,' ',InputFilename]);
  
end



clear;
clc;
drive='F:\fMRI_data\preproc';

%% T1

cd(fullfile(drive,'T1Raw'))
sublist=dir('sub*');
for s=1:length(sublist)
    
    inputDir=fullfile(drive,'T1Raw',sublist(s).name);
    outputDir=fullfile(drive,'T1Img',sublist(s).name);
    mkdir(outputDir);
    
    DirDCM=dir([inputDir,'\*.*']);
    InputFilename=[inputDir,'\',DirDCM(3).name];
    eval(['!','D:\software\MRIcroGL_windows\MRIcroGL\Resources\dcm2niix.exe -g N -o ',outputDir,' ',InputFilename]);
  
end

