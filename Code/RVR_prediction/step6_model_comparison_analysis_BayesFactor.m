clc
clear

rootdir='G:\SC_Data_backup\fMRI\fMRI_data\prediction\activation_RT';
LOOCVdir=fullfile(rootdir,'Result','TrainP_AAL_YCG_04f','LOOCV');

metricName={'LOOCV'};
e=1;

modelName={'combined','IFG','dmPFC','pMTG'};
model_list=dir(fullfile(LOOCVdir,'*.mat'));

data = [];

for i=1:length(model_list)
    metric_path=fullfile(LOOCVdir,model_list(i).name);
    load(metric_path);
    data = [data,LOOCV];% model order: combined,IFG,dmPFC,pMTG
end


%% Model comparison: combined vs. single model
comparison_result = struct();
for i = 2:size(data, 2)  
    disp(' ')
    disp(['比较联合模型与模型' modelName{i} '的' metricName{e} '差异：']);

    comparison_result.(['combined_vs_' modelName{i}]).logBF12 = data(1,i)-data(1,1);
    disp(['logBF = ' num2str(comparison_result.(['combined_vs_' modelName{i}]).logBF12)]);
end
    
    savedir=fullfile(LOOCVdir,'comparison_results');
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    savePath=fullfile(savedir,[metricName{e},'_comparison_results.mat']);
    save(savePath, 'comparison_result');
    disp('差异检验结果已保存到 comparison_results.mat');
    disp('')
    
    
    
    
    
    
    
