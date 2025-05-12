%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script was originally generated via the SPM12 Batch Editor
% and require specific paths and data to be available locally.
%-----------------------------------------------------------------------

clc
clear

%% Insert the subject's SPM .mat filename here
rootdir='F:\fMRI_data\processing\GLM_1st_level';
cd(rootdir)
sublist=dir('sub*');


%% regions group_level_coordinate

outputdir='F:\fMRI_data\processing\DCM_PEB\VOI_8_6mm';


VOI_name={'dmPFC_L_f13_6mm',...
    'IFG_Orb_L_f13_6mm',...
    'pMTG_L_f13_6mm'}';

peak_coordinates={[-9 39 42],...
    [-45 30 -6],...
    [-63 -45 0]}';

%% matlab batch

for i=1:length(sublist)
spm_mat_file = [rootdir filesep sublist(i).name filesep 'SPM.mat'];

for j=1:length(VOI_name)
% Start batch
clear matlabbatch;
matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);
matlabbatch{1}.spm.util.voi.adjust  = 13;                   % Effects of interest contrast number:13 F-contrast£¨strong£¬weak£¬same£¬r180£©
matlabbatch{1}.spm.util.voi.session = 1;                    % Session index
matlabbatch{1}.spm.util.voi.name    = VOI_name{j};        % VOI name

% Define thresholded SPM for finding the subject's local peak response
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat      = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast    = 5;     % Index of contrast for choosing voxels:5  T-contrast£¨weak-strong)
matlabbatch{1}.spm.util.voi.session = 1;                    % Session index
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc  = 'none';
% matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.05;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.1;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.2;
% matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.3;
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.4;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent      = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask        = struct('contrast', {}, 'thresh', {}, 'mtype', {});

% Define large fixed outer sphere
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre     = peak_coordinates{j}; % Set group coordinates here
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius     = 8;           % Radius (mm)
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;

% Define smaller inner sphere which jumps to the peak of the outer sphere
matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre           = [0 0 0]; % Leave this at zero(as it will move automatically)
matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius           = 6;       % Set radius here (mm)
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm  = 1;       % Index of SPM within the batch
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';    % Index of the outer sphere within the batch

% Include voxels in the thresholded SPM (i1) and the mobile inner sphere (i3)
matlabbatch{1}.spm.util.voi.expression = 'i1 & i3'; 

% Run the batch
spm_jobman('run',matlabbatch);

% movefile
sourcefiles=[sublist(i).folder filesep sublist(i).name];
pastedir=[outputdir filesep sublist(i).name];
if ~exist(pastedir)
    mkdir(pastedir);
end
movefile([sourcefiles filesep 'VOI*'],pastedir);

end
end
