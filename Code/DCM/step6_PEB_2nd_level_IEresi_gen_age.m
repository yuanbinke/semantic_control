%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script was originally generated via the SPM12 Batch Editor
% and require specific paths and data to be available locally.
%-----------------------------------------------------------------------

clc
clear
%% GCM.mat file 
rootdir='F:\fMRI_Data\2_processing\DCM_PEB\DCM_PEB_2nd_level\PEB_result_sem_we_Orb_dmPFC_pMTG\PEB_2nd_IEresi_gen_age_B';
% rootdir='F:\fMRI_Data\2_processing\DCM_PEB\DCM_PEB_2nd_level\PEB_result_sem_we_Orb_dmPFC_pMTG\PEB_2nd_IEresi_gen_age_A';
% rootdir='F:\fMRI_Data\2_processing\DCM_PEB\DCM_PEB_2nd_level\PEB_result_sem_we_Orb_dmPFC_pMTG\PEB_2nd_IEresi_gen_age_C';
gcmfiledir=[rootdir,'\GCM_full_model.mat'];
tmp1=strfind(gcmfiledir,'GCM_');
tmp2=strfind(gcmfiledir,'.');
outputname=[gcmfiledir(tmp1(1)+4:tmp2(1)-1)];


%% designmatrix.mat file
cd(rootdir)
DesignMatrixfile=dir('designmatrix*.mat');
load(DesignMatrixfile.name)

%%
matlabbatch{1}.spm.dcm.peb.specify.name = outputname;
matlabbatch{1}.spm.dcm.peb.specify.model_space_mat = {gcmfiledir};
matlabbatch{1}.spm.dcm.peb.specify.dcm.index = 1;
matlabbatch{1}.spm.dcm.peb.specify.cov.design_mtx.cov_design =designmatrix;
%%
matlabbatch{1}.spm.dcm.peb.specify.cov.design_mtx.name = labels;

matlabbatch{1}.spm.dcm.peb.specify.fields.custom = {'B'};
% matlabbatch{1}.spm.dcm.peb.specify.fields.custom = {'A'};
% matlabbatch{1}.spm.dcm.peb.specify.fields.custom = {'C'};
matlabbatch{1}.spm.dcm.peb.specify.priors_between.components = 'All';
matlabbatch{1}.spm.dcm.peb.specify.priors_between.ratio = 16;
matlabbatch{1}.spm.dcm.peb.specify.priors_between.expectation = 0;
matlabbatch{1}.spm.dcm.peb.specify.priors_between.var = 0.0625;
matlabbatch{1}.spm.dcm.peb.specify.priors_glm.group_ratio = 1;
matlabbatch{1}.spm.dcm.peb.specify.estimation.maxit = 256;
matlabbatch{1}.spm.dcm.peb.specify.show_review = 1;
matlabbatch{2}.spm.dcm.peb.reduce_all.peb_mat(1) = cfg_dep('Specify / Estimate PEB: PEB mat File(s)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','peb_mat'));
matlabbatch{2}.spm.dcm.peb.reduce_all.model_space_mat = {gcmfiledir};
matlabbatch{2}.spm.dcm.peb.reduce_all.nullpcov = 0.0625;
matlabbatch{2}.spm.dcm.peb.reduce_all.show_review = 1;


spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);