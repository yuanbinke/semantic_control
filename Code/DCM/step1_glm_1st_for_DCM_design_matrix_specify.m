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

scansdir='F:\fMRI_data\preproc\FunNormalizedSmoothed';
T1Img_dir='F:\fMRI_data\preproc\T1Img';
sublist=dir(fullfile(T1Img_dir,'sub*'));
outputdir='F:\fMRI_data\processing\GLM_1st_level';
multicondir='F:\fMRI_data\onset_matfiles';
rpdir='F:\fMRI_data\preproc\RealignParameter\rpfiles';

for s=1:length(sublist)
    subfolerdir=fullfile(outputdir,sublist(s).name);mkdir(subfolerdir)
    
    %% input nii file
    
    N=(1:304)';
    for r=1:3
        rundir=fullfile(scansdir,[sublist(s).name,dec2base(r,10,2)]);
        runlist = dir(fullfile(rundir,'swrasub*.nii'));
        
        Inputrun_Path=arrayfun(@(n) sprintf('%s,%d', fullfile(rundir,runlist.name), n), N,'UniformOutput', false);
        InputPath_Total((r-1)*304 + 1 : r*304,1) = Inputrun_Path;
    end
    
    %% input multiple conditions
    
    multiconlist=dir(fullfile(multicondir,'sub*.mat'));
    curmulticon=fullfile(multicondir,multiconlist(s).name);
    
    %% input rp file
    
    rpsublist=dir(fullfile(rpdir,'sub*.txt'));
    currp=fullfile(rpdir,rpsublist(s).name);
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subfolerdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 46;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 23;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = [InputPath_Total];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {curmulticon};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).name = 'run1';
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).val = [ones(304,1);zeros(608,1)];
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).name = 'run2';
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).val = [zeros(304,1);ones(304,1);zeros(304,1)];
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {currp};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 192;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {'F:\fMRI_data\FieldMap\brainmask_i1_2.nii,1'};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch);
end