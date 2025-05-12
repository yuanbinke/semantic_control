clc;
clear

rootdir='F:\fMRI_data\GLM_1st_level';
outputdir='F:\fMRI_data\RVR_prediction\glm_files';
conName='con_0005_weak_strong';



sublist=dir(fullfile(rootdir,'sub*'));
for s=1:length(sublist)
copydir=fullfile(rootdir,sublist(s).name);

copypath=fullfile(copydir,[conName(1:9),'.nii']);
pastedir=fullfile(outputdir,conName);
if ~exist(pastedir,'dir')
    mkdir(pastedir)
end
pastepath=fullfile(pastedir,[sublist(s).name,'_',conName(1:9),'.nii']);
copyfile(copypath,pastepath)
end


