%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script was originally generated via the SPM12 Batch Editor
% and require specific paths and data to be available locally.
%-----------------------------------------------------------------------
clc
clear

%% section 1: environment setting, changes can be made here
inputdir='F:\fMRI_data\GLM_1st_level';
outputdir='F:\fMRI_data\GLM_2nd_level';

%% create contrast folder
   contrastNames = {'strong', 'weak', 'same', 'r180', ...
       'weak_strong','r180_same','strong-same','weak-r180','(w-s)-(r-s)',...
       'strong-weak','same-r180','effect of interest','effect of interest2',...
       'semantic','visual'};
subfolder = cell(length(contrastNames), 1);

  for i=1:length(contrastNames)
    subfolder{i} = fullfile(outputdir, [sprintf('%04d', i),'_',contrastNames{i}]);
    mkdir(subfolder{i})
  end  

%% Read contrasts files
   sublist=dir(fullfile(inputdir,'sub*'));
   
   conFiles=cell(length(contrastNames), length(sublist));
   
   for s = 1:length(sublist)
       subdir = fullfile(inputdir, sublist(s).name);
       for k = 1:length(contrastNames)
           conFiles{k, s} = fullfile(subdir, ['con_', sprintf('%04d', k), '.nii']);
       end
   end

 
%% create matlabbatch
matlabbatch={};
idx = 1; % Initialize index for matlabbatch

contrastNum=[1:11,14:15];
for k = contrastNum
    % Factorial Design
    matlabbatch{idx}.spm.stats.factorial_design.dir = subfolder(k);
    matlabbatch{idx}.spm.stats.factorial_design.des.t1.scans = conFiles(k, :)';
    matlabbatch{idx}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{idx}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{idx}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{idx}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{idx}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{idx}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{idx}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{idx}.spm.stats.factorial_design.globalm.glonorm = 1;
    idx = idx + 1; % Increment index
    
    % FMRI Estimation
    matlabbatch{idx}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', ...
        substruct('.','val', '{}',{idx-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{idx}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{idx}.spm.stats.fmri_est.method.Classical = 1;
    idx = idx + 1; % Increment index
    % Contrast Manager
    
    matlabbatch{idx}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', ...
        substruct('.','val', '{}',{idx-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{idx}.spm.stats.con.consess{1}.tcon.name = contrastNames{k};
    matlabbatch{idx}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{idx}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{idx}.spm.stats.con.delete = 0;
    idx = idx + 1; % Increment index

end

%% Run SPM job
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

