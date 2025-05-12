clc
clear

rootdir='F:fMRI_data\RVR_prediction';
regressor='con_0005_weak_strong_mask_cluatser_AAL_YCG';
Resultdir=fullfile(rootdir,'Result','TrainP_AAL_YCG_04f');
if ~exist(Resultdir,'dir')
    mkdir(Resultdir)
end



%% prediction label input
RTdir=fullfile(rootdir,'RT_files');
RTPath=fullfile(RTdir,'RT_we_st.mat');
load(RTPath);
RT=RT_we_st;

Subjects_RTs=RT(:,1)';

ZSubjects_RTs=(Subjects_RTs-mean(Subjects_RTs))./std(Subjects_RTs);

%% Feature label input
ROIvoxVal_dir=fullfile(rootdir,'ROIvalueExtraction',regressor);
ROIvoxVal_list=dir(fullfile(ROIvoxVal_dir,'*.mat'));

ROI={'IFG','dmPFC','pMTG'};
for i=1:3%length(ROIVal_list)
    ROIVal_path=fullfile(ROIvoxVal_dir,ROIvoxVal_list(i).name);
    load(ROIVal_path);
    eval( [ROI{i}, ' = ', 'subvalue;']);
end

Subjects_Data=[IFG dmPFC pMTG];
% Subjects_Data=[pMTG];

%% RVR para
TrainFeaP = [1:-0.01:0.01];
Weight_Flag = 0;
Pre_Method = 'Normalize';
ZCovariates = [];

%% RVR
results = cell(length(TrainFeaP), 1);
messages = {};
for k = 1:length(TrainFeaP)
    p = TrainFeaP(k);
     try
    [Prediction,FeaP,~,survival_voxel] = RVR_LOOCV_FeatureSelection_FeaP(Subjects_Data, ZSubjects_RTs, ZCovariates, Pre_Method, Resultdir, p);
    survival_Percent=survival_voxel./size(Subjects_Data,2);
    s = sprintf('%0.3f ,%0.3f ,%0.3f ,%0.3f ,%d ,%0.3f\n', p, Prediction.Corr, Prediction.MAE, Prediction.MSE,survival_voxel,survival_Percent);
    disp(s);
    results{k, 1} = s;
    catch ME
        messages{end+1} = ME.message;
     end
end

%% 
fileid = fopen(fullfile(Resultdir, 'TrainP_con0005_RT_we_st_3ROI_100.csv'), 'w');

for i = 1:length(results)
    fprintf(fileid, '%s', results{i, 1});
end
fclose(fileid);



