%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script was originally generated via the SPM12 Batch Editor
% and require specific paths and data to be available locally.
%-----------------------------------------------------------------------

clear
clc
spm fmri


dcmdir='F:\fMRI_data\preproc\FunRaw';
drive='F:\fMRI_data\preproc';  

sublist=dir(fullfile(drive,'T1Img','sub*'));
subNum=length(sublist);


%% ********************realign:estimate & write***********************
for s=1:subNum
    
    for r=1:3
    N=1:304;
    FunImgA_sub_dir=fullfile(drive,'FunImgA',[sublist(s).name,dec2base(r,10,2)]);
    FunImgA_list = dir(fullfile(FunImgA_sub_dir,'asub*.nii'));
    FunImgA_Path{r}=arrayfun(@(n) sprintf('%s,%d', fullfile(FunImgA_sub_dir,FunImgA_list.name), n), N, 'UniformOutput', false).';   
    end
    
    matlabbatch{1}.spm.spatial.realign.estwrite.data = FunImgA_Path;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;% 1-mean;0-first
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    FunImgA_run1_dir = fullfile(drive,'FunImgA',[sublist(s).name,'01']);
    cd(FunImgA_run1_dir);
    fprintf(['Realign Setup: ',sublist(s).name,' OK...']);
    fprintf('\n');
    spm_jobman('run',matlabbatch);
    
end
clear matlabbatch;
clear s r

for s=1:subNum  
    for r=1:3
        
    FunImgA_sub_dir=fullfile(drive,'FunImgA',[sublist(s).name,dec2base(r,10,2)]);
    FunImgAR_sub_dir = fullfile(drive,'FunImgAR',[sublist(s).name,dec2base(r,10,2)]);
    mkdir(FunImgAR_sub_dir);
    movefile(fullfile(FunImgA_sub_dir,'ra*.nii'), FunImgAR_sub_dir);
    fprintf(['Moving slicetiming Files:',sublist(s).name,' OK\n'])
    end
end

  
%% ********************Coregist***********************


for s=1:subNum
    try
    FunImgA_run1_dir = fullfile(drive,'FunImgA',[sublist(s).name,'01']);
    mean_list=dir(fullfile(FunImgA_run1_dir ,'mean*.nii'));
    T1Img_sub_dir=fullfile(drive,'T1Img',sublist(s).name);
    T1Img_list=dir(fullfile(T1Img_sub_dir,'sub*.nii'));
   
    matlabbatch={};
    matlabbatch{1}.spm.spatial.coreg.estimate.ref(1) = {fullfile(FunImgA_run1_dir,mean_list.name)};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {fullfile(T1Img_sub_dir,T1Img_list.name)};
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    fprintf(['Normalize-Coregister Setup:',sublist(s).name,' OK\n']);
    cd(T1Img_sub_dir) 
    spm_jobman('run',matlabbatch);
    catch ME
        fprintf('Error with subject %s. Details: %s\n', sublist(s).name, ME.message);
    end
    
end
clear matlabbatch;


%% ********************Segment********************

for s=1:subNum
    
    clear T1Img_list
    T1Img_sub_dir=fullfile(drive,'T1Img',sublist(s).name);
    T1Img_list=dir(fullfile(T1Img_sub_dir,'sub*.nii'));
    
    matlabbatch={};
    matlabbatch{1}.spm.spatial.preproc.channel.vols(1) = {fullfile(T1Img_sub_dir,T1Img_list.name)};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'D:\software\spm12\tpm\TPM.nii,1'};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'D:\software\spm12\tpm\TPM.nii,2'};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'D:\software\spm12\tpm\TPM.nii,3'};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'D:\software\spm12\tpm\TPM.nii,4'};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'D:\software\spm12\tpm\TPM.nii,5'};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'D:\software\spm12\tpm\TPM.nii,6'};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];    
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN;NaN NaN NaN];

    fprintf(['Normalize-Segment Setup:',sublist(s).name,' OK\n']);
    
    spm_jobman('run',matlabbatch);

end
clear matlabbatch;
 
%% *********Normalize-Write: Using the segment information***************


for s=1:subNum

    BoundingBox=[-90 -126 -72;90 90 108];
    
    T1Img_sub_dir=fullfile(drive,'T1Img',sublist(s).name);
    y_list=dir(fullfile(T1Img_sub_dir,'y_*.nii'));
    Bias_T1Img=dir(fullfile(T1Img_sub_dir,'msub*.nii'));
    
    N=1:304;
   
    for r=1:3
        FunImgAR_sub_dir = fullfile(drive,'FunImgAR',[sublist(s).name,dec2base(r,10,2)]);
        FunImgAR_list = dir(fullfile(FunImgAR_sub_dir,'rasub*.nii'));
        FunImgAR_Path=arrayfun(@(n) sprintf('%s,%d', fullfile(FunImgAR_sub_dir,FunImgAR_list.name), n), N, 'UniformOutput', false).';
        FunImgAR_Path_Total((r-1)*304 + 1 : r*304,1) = FunImgAR_Path;
    end
    
    matlabbatch={};
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(T1Img_sub_dir,y_list.name)};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = FunImgAR_Path_Total;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = BoundingBox;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    matlabbatch{2}.spm.spatial.normalise.write.subj.def = {fullfile(T1Img_sub_dir,y_list.name)};
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample = {fullfile(T1Img_sub_dir,Bias_T1Img.name)};
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = BoundingBox;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    fprintf(['Normalize-Write Setup:',sublist(s).name,' OK\n']);
    spm_jobman('run',matlabbatch);
    
end
clear matlabbatch;

   



%% move/copy files
for s=1:subNum
    for r=1:3
%  normalized files to FunImgNormalized
        FunImgAR_sub_dir = fullfile(drive,'FunImgAR',[sublist(s).name,dec2base(r,10,2)]);
        FunNormalized_sub_dir = fullfile(drive,'FunNormalized',[sublist(s).name,dec2base(r,10,2)]);
        mkdir(FunNormalized_sub_dir)
        movefile(fullfile(FunImgAR_sub_dir,'wra*.nii'),FunNormalized_sub_dir)
        
        RealignParameter_dir=fullfile(drive,'RealignParameter',sublist(s).name);
        FunImgA_sub_dir=fullfile(drive,'FunImgA',[sublist(s).name,dec2base(r,10,2)]);
        copyfile(fullfile(FunImgA_sub_dir,'rp*.txt'),RealignParameter_dir);
    end
    
%  Realign Parameters to RealignParameter
    FunImgA_run1_dir = fullfile(drive,'FunImgA',[sublist(s).name,'01']);
    RealignParameter_dir=fullfile(drive,'RealignParameter',sublist(s).name);
    mkdir(RealignParameter_dir);
    copyfile(fullfile(FunImgA_run1_dir,'mean*.nii'),RealignParameter_dir);
    copyfile(fullfile(FunImgA_run1_dir,'*.ps'),RealignParameter_dir);

    fprintf(['Moving Normalized Files:',sublist(s).name,' OK']);
    fprintf('\n');
end

    

%% ******************** Smooth ********************

for s=1:subNum

    N=1:304;
    for r=1:3
        FunNormalized_sub_dir = fullfile(drive,'FunNormalized',[sublist(s).name,dec2base(r,10,2)]);
        FunNormalized_list = dir(fullfile(FunNormalized_sub_dir,'wrasub*.nii'));
        FunNormalized_Path=arrayfun(@(n) sprintf('%s,%d', fullfile(FunNormalized_sub_dir,FunNormalized_list.name), n), N, 'UniformOutput', false).';
        FunNormalized_Path_Total((r-1)*304 + 1 : r*304,1) = FunNormalized_Path;
    end
    
    matlabbatch={};
    matlabbatch{1}.spm.spatial.smooth.data = FunNormalized_Path_Total;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    
    fprintf(['Smooth Setup:',sublist(s).name,' OK\n']);
    spm_jobman('run',matlabbatch);
    
  
end
clear matlabbatch;

    %% Copy the smoothed files to DataProcessDir\FunImgNormalizedSmoothed
   
    for s=1:subNum
        for r=1:3
            FunNormalized_sub_dir = fullfile(drive,'FunNormalized',[sublist(s).name,dec2base(r,10,2)]);
            FunNormalizedSmoothed_sub_dir = fullfile(drive,'FunNormalizedSmoothed',[sublist(s).name,dec2base(r,10,2)]);
            mkdir(FunNormalizedSmoothed_sub_dir)
            movefile(fullfile(FunNormalized_sub_dir,'swra*.nii'),FunNormalizedSmoothed_sub_dir)
            
            fprintf(['Moving Smoothed Files:',sublist(s).name,' OK\n']);
        end
    end
    
    

disp ('Preprocessing done.')