% This example wil go throgh simulations and calculate
% the average and the standard deviation of the normal component
% of the electric field in FsAverage space
%
% It is a follow-up to the "run_simulations" example
clc
clear

rootDir='F:TMS_data';
TMS_naviDir=fullfile(rootDir,'T1_Nifti');
results_folder = fullfile(rootDir,'simNIBS', 'Efield_group_average_GM_WM');
if ~exist(results_folder,'dir');mkdir(results_folder);end

MSO_Dir='E:\SC_Data_backup\fMRI\fMRI_data\prediction\fMRI_eField_TMS';

subList=dir(fullfile(TMS_naviDir,'sub*'));

template_image = nifti_load('F:TMS_data\T1_Nifti\sub05\tms_optimization_adm_IFG_smooth100\sub05_TMS_optimize_Magstim_70mm_Fig8_MNI_normE.nii.gz');
tmpl_size = size(template_image.vol);

field_name = 'normE';
ROI = {'IFG','dmPFC','pMTG'};
dIdt_max = 114.7;% Magstim Rapid2 Stimulator 70 mm figure-eight coil



for R=1:numel(ROI)

    %% load MSO
    MSO_Path = fullfile(MSO_Dir,['actual_MSO_',ROI{R},'.txt']);
    MSO = load(MSO_Path);

    numMSOs = size(MSO, 1);
    if numMSOs~=length(subList)
        error('Mismatch: numMSOs = %d, numSubList = %d', numMSOs, length(subList));
    end

    %% Load simulation results

    sumVol   = zeros(tmpl_size, 'single');
    sumSqVol = zeros(tmpl_size, 'single');

    n_ok = 0;
    for s = 1:length(subList)

        subFolder = fullfile(TMS_naviDir,subList(s).name);
        optFolderList = dir(fullfile(subFolder,sprintf('tms_optimization_adm_%s*',ROI{R})));

        MNI_normE_List = dir(fullfile(subFolder,optFolderList.name,'*_TMS_optimize_Magstim_70mm_Fig8_GM_WM_MNI_normE.nii.gz'));

        imgPath=fullfile(subFolder, optFolderList.name, MNI_normE_List.name);
        img = nifti_load(imgPath);
        img_size = size(img.vol);

        if ~isequal(img_size, tmpl_size)
            warning('Size mismatch for %s; skip', imgPath);
            continue
        end

        mso_frac = MSO(s,1) * 0.01;
        E_scaled = single(img.vol) * (dIdt_max * mso_frac);

        sumVol   = sumVol   + E_scaled; 
        sumSqVol = sumSqVol + E_scaled.^2;
        n_ok = n_ok + 1;
    end
        if n_ok == 0
            warning('No valid subjects for ROI %s; skip saving.', ROI{R});
            continue
        end
    
        % mean and std
        meanVol = sumVol / n_ok;
        stdVol  = sqrt( max(sumSqVol / n_ok - meanVol.^2, 0) );
    


    % save
    avg_image = template_image;
    avg_image.vol = meanVol;
    std_image = template_image;
    std_image.vol = stdVol;

    avg_Path = fullfile(results_folder,sprintf('group_%s_avg_%s_GM_WM.nii.gz', field_name, ROI{R}));
    std_Path = fullfile(results_folder,sprintf('group_%s_std_%s_GM_WM.nii.gz', field_name, ROI{R}));
    
    nifti_save(avg_image, avg_Path);
    nifti_save(std_image, std_Path);
end

