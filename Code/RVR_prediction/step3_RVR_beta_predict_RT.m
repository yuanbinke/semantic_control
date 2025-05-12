clc
clear

rootdir='G:\SC_Data_backup\fMRI\fMRI_data\prediction\activation_RT';
regressor='con_0005_weak_strong_mask_cluatser_AAL_YCG';
Resultdir=fullfile(rootdir,'Result','TrainP_AAL_YCG_04f');%
if ~exist(Resultdir,'dir')
    mkdir(Resultdir)
end

ROIVal_dir=fullfile(rootdir,'ROIvalueExtraction',regressor);
ROIVal_list=dir(fullfile(ROIVal_dir,'*.mat'));

RTdir=fullfile(rootdir,'RT_files');
RTPath=fullfile(RTdir,'RT_we_st.mat');
load(RTPath);
RT=RT_we_st;

%%
ROI={'IFG','dmPFC','pMTG','3ROI'};
ROIFeatP=[0.02,0.04,0.05,0.04];
for j=1:4
    
ROIdata = struct();

for i=1:length(ROIVal_list)
    ROIVal_path=fullfile(ROIVal_dir,ROIVal_list(i).name);
    load(ROIVal_path);
    ROIdata.(ROI{i}) = subvalue; 
end


% Dynamically set Subjects_Data
if j == 1
    Subjects_Data = ROIdata.IFG;
elseif j == 2
    Subjects_Data = ROIdata.dmPFC;
elseif j == 3
    Subjects_Data = ROIdata.pMTG;
elseif j == 4
    Subjects_Data = [ROIdata.IFG, ROIdata.dmPFC, ROIdata.pMTG];
else
    error('Invalid j value');
end

% Define the RT matrix
Subjects_RTs=RT(:,1)';
ZSubjects_RTs=(Subjects_RTs-mean(Subjects_RTs))./std(Subjects_RTs);

%% Feature TrainP
Covariates = [];
Weight_Flag = 0;
Pre_Method = 'Normalize';
TrainFeaP=ROIFeatP(j);

[Prediction,FeaP,Errors] = RVR_LOOCV_FeatureSelection_FeaP(Subjects_Data, ZSubjects_RTs, Covariates, Pre_Method, Resultdir, TrainFeaP);

Errordir=fullfile(Resultdir,'PredictionErrors');
if ~exist(Errordir,'dir')
    mkdir(Errordir)
end

save(fullfile(Errordir, [ROI{j}, '_Errors.mat']), 'Errors');

% save LOOCV Error
LOOCV = Prediction.LOOCV;
 disp([ROI{j} ' LOOCV = ' num2str(LOOCV) ]);
LOOCVdir=fullfile(Resultdir,'LOOCV');
if ~exist(LOOCVdir,'dir')
    mkdir(LOOCVdir)
end

save(fullfile(LOOCVdir, [ROI{j}, '_LOOCV.mat']), 'LOOCV');



%% permutation test
messages = {};

PSN=4000;
Prediction_rCorr=zeros(PSN,1);
for ps=1:PSN
    try
        Subjects_RTs_r=ZSubjects_RTs(randperm(length(ZSubjects_RTs)));
        [Prediction_r(ps),~] = RVR_LOOCV_FeatureSelection_FeaP(Subjects_Data, Subjects_RTs_r, Covariates, Pre_Method, Resultdir, TrainFeaP);

        Prediction_rCorr(ps)=Prediction_r(ps).Corr;
    catch ME
        messages{end+1} = ME.message;
    end
   disp([num2str(ps),'  finished']);
end

Prediction_rCorr(Prediction_rCorr==0) = [];
Prediction_rCorr_ = Prediction_rCorr(1:1000);
Prediction_rCorrSort=sort(Prediction_rCorr_,'descend');
R_p=zeros(2,1);

R_p(2)=(1000-length(find(Prediction_rCorrSort<Prediction.Corr)))./1000;
R_p(1)=Prediction.Corr;

%% save files
results=[Prediction.Score',ZSubjects_RTs'];

resultsPath=fullfile(Resultdir,['Predict_actualScore_',regressor,'_',ROI{j},'_FeatP_',num2str(TrainFeaP),'.mat']);
save(resultsPath,'results')

r_p_Path=fullfile(Resultdir,['Permutation_R_p_',regressor,'_',ROI{j},'_FeatP_',num2str(TrainFeaP),'.mat']);
save (r_p_Path,'R_p'),


end



