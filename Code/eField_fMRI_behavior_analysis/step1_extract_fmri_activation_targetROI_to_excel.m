clc
clear

% Set paths and parameters
rootDir='F:\fMRI_data\regression\fMRI_eField_TMS';
conFilesDir=fullfile(rootDir,'conFiles','con_0005_weak_strong');
tFilesDir=fullfile(rootDir,'conFiles','spmT_0005_weak_strong');

OutputMaskDir=fullfile(rootDir,'ROIMaskResults');
if ~exist(OutputMaskDir,'dir'); mkdir(OutputMaskDir);end

ExtractROIDir=fullfile(rootDir,'Extract_meanROIfiles','fMRI_ROI_value');
if ~exist(ExtractROIDir,'dir'); mkdir(ExtractROIDir);end

maskFilePath='D:\software\DPABI_V7.0_230110\Templates\BrainMask_05_61x73x61.img';

ROI = {'IFG','dmPFC','pMTG'};
radius = 8; % radius of the ROI
topFrac = 0.10;   % Top-10%


conList=dir(fullfile(conFilesDir,'sub*.nii'));
sub_top10Mean  = NaN(length(conList),length(ROI));   % Top-10% by t


for R=1:numel(ROI)
    maskSubDir = fullfile(OutputMaskDir, sprintf('%s_Mask_%dmm',ROI{R},radius));
    if ~exist(maskSubDir, 'dir'); mkdir(maskSubDir); end

    CoorDataPath=fullfile(rootDir,['peaks_',ROI{R},'.txt']);
    CoorData=load(CoorDataPath);

    numROIs = size(CoorData, 1);
    if numROIs~=length(conList)
        error('Mismatch: numROIs = %d, con files = %d', numROIs, length(conList));
    end

    for i=1:length(conList)
        subID = regexp(conList(i).name, '(sub\d+)', 'match', 'once');

        % generate sphere ROI mask
        currCoor= [CoorData(i,1),CoorData(i,2),CoorData(i,3)];

        OutputMaskPath=fullfile(maskSubDir,sprintf('%s_roi_%s_%d_%d_%d_%dmm.nii', subID,ROI{R}, CoorData(i,1), CoorData(i,2), CoorData(i,3),radius));

        [maskData,~] = gretna_gen_roi(currCoor, 'Sphere', radius, maskFilePath, OutputMaskPath);

        % read conFiles
        confilePath=fullfile(conFilesDir,conList(i).name);
        [conData,conHDR]=y_Read(confilePath);

        % read corresponding spmT
        tfileStruct = dir(fullfile(tFilesDir, [subID,'*.nii']));
        if isempty(tfileStruct)
            warning('No matching spmT file for %s; set NaN', subID);
            continue
        end
        [tData,~] = y_Read(fullfile(tFilesDir, tfileStruct(1).name));

        if ~isequal(size(maskData), size(conData)) || ~isequal(size(maskData), size(tData))
            error('mask %s, con %s, t %s（sub：%s，ROI：%s）。', ...
                mat2str(size(maskData)), mat2str(size(conData)), mat2str(size(tData)), subID, ROI{R});
        end

        maskLogical = maskData ~= 0;

        if ~any(maskLogical(:))
            warning('%s %s mask is empty', subID, ROI{R});
            continue
        end

        beta_roi = conData(maskLogical);
        t_roi    = tData(maskLogical);

        keep_idx = isfinite(t_roi) & isfinite(beta_roi);
        if any(keep_idx)
            t_all    = t_roi(keep_idx);
            beta_all = beta_roi(keep_idx);
            nall = numel(t_all);
            kall = max(1, ceil(topFrac * nall));
            [~, order_all] = sort(t_all, 'descend');
            top_idx_all = order_all(1:kall);
            sub_top10Mean(i, R) = mean(beta_all(top_idx_all), 'omitnan');
        else
            sub_top10Mean(i, R) = NaN;
        end
    end
end

subIDs = cell(length(conList),1);
for ii = 1:length(conList)
    subIDs{ii} = regexp(conList(ii).name, '(sub\d+)', 'match', 'once');
end
T = table(subIDs, 'VariableNames', {'Subject'});

for jj = 1:numel(ROI)
    T.([ROI{jj} '_Top10_All']) = sub_top10Mean(:,jj);
end

outname = sprintf('TMS_Target_ROI_%dmm_con_0005_weak_strong.xlsx', radius);
writetable(T, fullfile(ExtractROIDir, outname), 'WriteVariableNames', true);