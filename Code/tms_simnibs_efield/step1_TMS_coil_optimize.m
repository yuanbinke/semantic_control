% https://simnibs.github.io/simnibs/build/html/tutorial/tms_optimization.html
% Example script for TMS coil placement optimization.
% It generates a position grid, runs the optimization, and returns the coil
% position that produces the maximum electric field at the target.
% The output file "ernie_TMS_optimize_Magstim_70mm_Fig8_nii.msh"
% contains the optimized E-field and coil placement.
% Guilherme Saturnino, 2019

clc
clear
tic

%% ADM
subdir='F:TMS_data\T1_Nifti\sub05';
cd(subdir)
% Initialization
tms_opt = opt_struct('TMSoptimize');
% % Subject folder
% tms_opt.subpath = 'm2m_ernie';
% Select the head mesh
tms_opt.fnamehead = 'sub05.msh';
% Select output folder
tms_opt.pathfem = 'tms_optimization_adm_pMTG_smooth_test';
% Select the coil model
% The ADM method requires a '.ccd' coil model
tms_opt.fnamecoil = 'Magstim_70mm_Fig8.ccd';
% Select a target for the optimization£¨input MNI coordinate£©£¬ 'm2m_ernie' means subject segmentation directory
tms_opt.target = mni2subject_coords([-63,-45,0], 'm2m_sub05'); 
% Use the ADM method
tms_opt.method = 'ADM';
% to adjust the coil tangentiality to the scalp,and higher values may be needed
tms_opt.scalp_normals_smoothing_steps = 100;

%% Run optimization
run_simnibs(tms_opt);

