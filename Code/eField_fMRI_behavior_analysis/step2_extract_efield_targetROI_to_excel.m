clc
clear

rootDir='F:\fMRI_data\regression\fMRI_eField_TMS';
TMS_naviDir='F:TMS_data\T1_Nifti';
subList=dir(fullfile(TMS_naviDir,'sub*'));

ROI = {'IFG','dmPFC','pMTG'};
r = 8;

subvalue = NaN(length(subList),length(ROI));

for R=1:numel(ROI)

    CoorDataPath=fullfile(rootDir,['peaks_',ROI{R},'.txt']);
    CoorData=load(CoorDataPath);

    numROIs = size(CoorData, 1);
    if numROIs~=length(subList)
        error('Mismatch: numROIs = %d, numSubList = %d', numROIs, length(subList));
    end

    MSO_Path = fullfile(rootDir,['actual_MSO_',ROI{R},'.txt']);
    MSO = load(MSO_Path);

    numMSOs = size(MSO, 1);
    if numMSOs~=length(subList)
        error('Mismatch: numMSOs = %d, numSubList = %d', numMSOs, length(subList));
    end


    for s=1:length(subList)
        %% Load Simulation Result

        % Read the simulation result
        subFolder = fullfile(TMS_naviDir,subList(s).name);
        optFolderList=dir(fullfile(subFolder,sprintf('tms_optimization_adm_%s*',ROI{R})));
        MshFileList = dir(fullfile(subFolder,optFolderList.name,'*_TMS_optimize_Magstim_70mm_Fig8.msh'));
        head_mesh = mesh_load_gmsh4(fullfile(MshFileList.folder,MshFileList.name));


        % Crop the mesh so we only have gray matter volume elements (tag 2 in the mesh)
        % labels：1=WM，2=GM，3=CSF
        gm = mesh_extract_regions(head_mesh, 'region_idx', 2);

        %% Define the ROI（MNI2sub）

        % Define M1 from MNI coordinates (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2034289/)
        % the first argument is the MNI coordinates
        % the second argument is the subject "m2m" folder
        peak_MNI= [CoorData(s,1),CoorData(s,2),CoorData(s,3)];
        headMeshDirList=dir(fullfile(subFolder,'m2m_sub*'));
        headMeshDir=fullfile(subFolder,headMeshDirList.name);
        sub_coord = mni2subject_coords(peak_MNI, headMeshDir);

        % Electric fields are defined in the center of the elements
        % get element centers
        elm_centers = mesh_get_tetrahedron_centers(gm);

        % determine the elements in the ROI
        in_roi  = sqrt(sum((elm_centers - sub_coord).^2, 2)) < r;
        if ~any(in_roi)
            warning('Empty ROI: %s - %s', subList(s).name, ROI{R});
            subvalue(s,R) = NaN;
            continue
        end

        % get element volumes, we will use those for averaging
        elm_vols = mesh_get_tetrahedron_sizes(gm);

        %% Get e-field and calculate the mean
        % Get the field of interest
        field_name = 'normE'; % 在head_mesh.element_data{2}.name中读取（1E; 2normE; 3J; 4normJ; 5Target)
        field_idx  = get_field_idx(gm, field_name, 'elements');  % 'E'是一个矢量(Ex,Ey,Ez)，'magnE' = |E|
        Efield = gm.element_data{field_idx}.tetdata;           % 单位场：V/m per (A/µs)

        % Calculate the mean
        E_mean_roi = sum(Efield(in_roi) .* elm_vols(in_roi)) / sum(elm_vols(in_roi));

        %% E_norm to V/m
        dIdt_max = 114.7;        %  Magstim Rapid2 Stimulator 70 mm figure-eight coil
        subMSO  = MSO(s)*0.01;

        E_mean_Vperm = E_mean_roi * dIdt_max * subMSO;

        subvalue(s, R) = E_mean_Vperm;
        fprintf('%s %s finished\n\n',ROI{R},subList(s).name);

    end
end
colNames = ROI;
T = array2table(subvalue, 'VariableNames', colNames);
filePath = fullfile(rootDir,'Extract_meanROIfiles','Efield_ROI_value', sprintf('TMS_Target_ROI_%dmm_Efield_subMeanValue.xlsx',r));
writetable(T, filePath, 'WriteVariableNames', true);
