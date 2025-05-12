%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script is based on core SPM12 functions and require 
% specific paths and data to be available locally.
%-----------------------------------------------------------------------

clc
clear

%% Settings
% MRI scanner settings
TR = 0.7075;   
TE = 0.03;  

% Experiment settings
nsubjects   = 35;
nregions    = 3; 
nconditions = 2;

% Index of each condition in the DCM
semantic =1; weak=2; 

% Index of each region in the DCM
IFG_Orb=1; dmPFC=2;  pMTG=3;

% spm.mat to tell the onset time
spm_dir = 'F:\fMRI_data\processing\DCM_PEB\DCM_1st_level';
VOI_dir='F:\fMRI_data\processing\DCM_PEB\VOI_8_6mm';


peb_2nd_folder='PEB_result_sem_we_Orb_dmPFC_pMTG';
DCM_name='full_model_sem_we_Orb_dmPFC_pMTG';
GCM_name='GCM_full_model.mat';

%% Specify DCMs (one per subject)

% A-matrix (on / off)
a = ones(nregions,nregions);

% B-matrix
b(:,:,semantic) = zeros(nregions); % semantic
b(:,:,weak) = ones(nregions);   % weak

% C-matrix
c = zeros(nregions,nconditions);
c(:,semantic) = 1;

% D-matrix (disabled)
d = zeros(nregions,nregions,0);

cd(spm_dir)
sublist=dir('sub*');
for s = 1:length(sublist)
       
    % Load SPM.mat
    SPM = load(fullfile(spm_dir,sublist(s).name,'SPM.mat'));
    SPM = SPM.SPM;
    
    % Load ROIs
    f = {fullfile(VOI_dir,sublist(s).name,'VOI_IFG_Orb_L_f13_6mm_1.mat');
         fullfile(VOI_dir,sublist(s).name,'VOI_dmPFC_L_f13_6mm_1.mat');
          fullfile(VOI_dir,sublist(s).name,'VOI_pMTG_L_f13_6mm_1.mat')};
        
    for r = 1:length(f)
        XY = load(f{r});
        xY(r) = XY.xY;
    end
    
    % Move to output directory
    cd(fullfile(spm_dir,sublist(s).name));
    
    % Select whether to include each condition from the design matrix
    % (all,semantic,visual,strong,weak,same,r180)
    include = [0 1 0 0 1 0 0]';    
    
    % Specify. Corresponds to the series of questions in the GUI.
    s = struct();
    s.name       = DCM_name;
    s.u          = include;                 % Conditions
    s.delays     = repmat(TR,1,nregions);   % Slice timing for each region
    s.TE         = TE;
    s.nonlinear  = false;
    s.two_state  = false;
    s.stochastic = false;
    s.centre     = true;
    s.induced    = 0;
    s.a          = a;
    s.b          = b;
    s.c          = c;
    s.d          = d;
    DCM = spm_dcm_specify(SPM,xY,s);
    
end

%% Collate into a GCM file and estimate

% Find all DCM files
dcms = spm_select('FPListRec',spm_dir,DCM_name);

% Prepare output directory
out_dir = 'F:\fMRI_Data\2_processing\DCM_PEB\DCM_PEB_2nd_level';
if ~exist(fullfile(out_dir,peb_2nd_folder))
    mkdir(fullfile(out_dir,peb_2nd_folder));
end

% Check if it exists
if exist(fullfile(out_dir,peb_2nd_folder,GCM_name),'file')
    opts.Default = 'No';
    opts.Interpreter = 'none';
    f = questdlg('Overwrite existing GCM?','Overwrite?','Yes','No',opts);
    tf = strcmp(f,'Yes');
else
    tf = true;
end

% Collate & estimate
if tf
    % Character array -> cell array
    GCM = cellstr(dcms);
    
    % Filenames -> DCM structures
    GCM = spm_dcm_load(GCM);

    % Estimate DCMs (this won't effect original DCM files)
    use_parfor = true ;% Enabling parallel DCM estimation
    GCM = spm_dcm_peb_fit(GCM);
    
    % Save estimated GCM
    GCM_path=fullfile(out_dir,peb_2nd_folder,GCM_name);
    save(GCM_path,'GCM');
end

%% Run diagnostics
load(GCM_path);
spm_dcm_fmri_check(GCM);