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

%% Kolmogorov�CSmirnov test for normality
disp('��̬�Լ�������ʹ��KS���飩��');
p_normal = [];  

for i = 1:size(data,2)
    [h, p] = kstest(data(:,i));  
    p_normal = [p_normal, p];  
    if h == 0
        disp(['ģ��' num2str(i) '�Ľ��������̬�ֲ� (pֵ = ' num2str(p) ')']);
    else
        disp(['ģ��' num2str(i) '�Ľ����������̬�ֲ� (pֵ = ' num2str(p) ')']);
    end
end


%% Model comparison: combined vs. single model
comparison_stast = struct();
for i = 2:size(data, 2) 
    disp(' ')
    disp(['�Ƚ�����ģ����ģ��' modelName{i} '��' ErrorName{e} '���죺']);
    
    % �����ֵ
    mean_combined = mean(data(:, 1));
    mean_model_i = mean(data(:, i));
    comparison_stast.(['combined_vs_' modelName{i}]).mean_combined = mean_combined;
    comparison_stast.(['combined_vs_' modelName{i}]).(['mean_',modelName{i}]) = mean_model_i;
    
    
    if p_normal(1) > 0.05 && p_normal(i) > 0.05 
        disp('��̬�����㣬�������t���飺');
        
%         [~, p_ttest,ci,stats] = ttest(data(:, 1), data(:, i), 'Tail', 'left');  % ���t����('Tail', 'left' ��ʾ��β���飬������data(:, 1)�Ƿ�����С��data(:, i)����
       [~, p_ttest,ci,stats] = ttest(data(:, 1), data(:, i));
        
       disp(['���t�����t= ' num2str(stats.tstat) ', p= ' num2str(p_ttest)]);
        
        comparison_stast.(['combined_vs_' modelName{i}]).p = p_ttest;
        comparison_stast.(['combined_vs_' modelName{i}]).t = stats.tstat;
        comparison_stast.(['combined_vs_' modelName{i}]).ci = ci;
        
     else  
        disp('��̬�Բ����㣬�����û����t���飺');
        
         [T, P_PermT] = gretna_permutation_ttest_RM(data(:, 1), data(:, i), Perm);

        disp(['�û����t����t= ' num2str(T.real) ', p= ' num2str(P_PermT)]);% �û����t����
        
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
    disp('����������ѱ��浽 comparison_results.mat');
    disp('')
    
end
    
    
    
    
