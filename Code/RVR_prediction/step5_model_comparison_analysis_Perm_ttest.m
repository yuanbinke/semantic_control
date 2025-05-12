clc
clear

rootdir='G:\fMRI_data\prediction\activation_RT';
Errordir=fullfile(rootdir,'Result','TrainP_AAL_YCG_04f','PredictionErrors');

ErrorName={'AE','SE'};
for e=1:2

modelName={'combined','IFG','dmPFC','pMTG'};
model_list=dir(fullfile(Errordir,'*.mat'));

data = [];
Perm=5000;

for i=1:length(model_list)
    Error_path=fullfile(Errordir,model_list(i).name);
    load(Error_path);
    %     safeModelName = [ErrorName{e},'_',modelName{i}];
    %     Errordata.(safeModelName) = Errors.(ErrorName{e});
    data = [data,Errors.(ErrorName{e})];% model order: combined,IFG,dmPFC,pMTG
end

%% Kolmogorov–Smirnov test for normality
disp('正态性检验结果（使用KS检验）：');
p_normal = [];  

for i = 1:size(data,2)
    [h, p] = kstest(data(:,i));  
    p_normal = [p_normal, p];  
    if h == 0
        disp(['模型' num2str(i) '的结果近似正态分布 (p值 = ' num2str(p) ')']);
    else
        disp(['模型' num2str(i) '的结果不符合正态分布 (p值 = ' num2str(p) ')']);
    end
end


%% Model comparison: combined vs. single model
comparison_stast = struct();
for i = 2:size(data, 2) 
    disp(' ')
    disp(['比较联合模型与模型' modelName{i} '的' ErrorName{e} '差异：']);
    
    % 保存均值
    mean_combined = mean(data(:, 1));
    mean_model_i = mean(data(:, i));
    comparison_stast.(['combined_vs_' modelName{i}]).mean_combined = mean_combined;
    comparison_stast.(['combined_vs_' modelName{i}]).(['mean_',modelName{i}]) = mean_model_i;
    
    
    if p_normal(1) > 0.05 && p_normal(i) > 0.05 
        disp('正态性满足，进行配对t检验：');
        
%         [~, p_ttest,ci,stats] = ttest(data(:, 1), data(:, i), 'Tail', 'left');  % 配对t检验('Tail', 'left' 表示右尾检验，即检验data(:, 1)是否显著小于data(:, i)。）
       [~, p_ttest,ci,stats] = ttest(data(:, 1), data(:, i));
        
       disp(['配对t检验的t= ' num2str(stats.tstat) ', p= ' num2str(p_ttest)]);
        
        comparison_stast.(['combined_vs_' modelName{i}]).p = p_ttest;
        comparison_stast.(['combined_vs_' modelName{i}]).t = stats.tstat;
        comparison_stast.(['combined_vs_' modelName{i}]).ci = ci;
        
     else  
        disp('正态性不满足，进行置换配对t检验：');
        
         [T, P_PermT] = gretna_permutation_ttest_RM(data(:, 1), data(:, i), Perm);

        disp(['置换配对t检验t= ' num2str(T.real) ', p= ' num2str(P_PermT)]);% 置换配对t检验
        
        comparison_stast.(['combined_vs_' modelName{i}]).Perm_p = P_PermT;
        comparison_stast.(['combined_vs_' modelName{i}]).Perm_t.real = T.real;
        comparison_stast.(['combined_vs_' modelName{i}]).Perm_t.rand = T.rand;
    end
end
    
    savedir=fullfile(Errordir,'stat_results');
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    savePath=fullfile(savedir,[ErrorName{e},'_comparison_results.mat']);
    save(savePath, 'comparison_stast');
    disp('差异检验结果已保存到 comparison_results.mat');
    disp('')
    
end
    
    
    
    
