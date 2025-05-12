clc
clear

saveDir='F:\TMS\behavior\stats\SPSS_files\result_P_multiple_comparison';

filename='Results_RTms_pairedT_targets_vs_Vertex_22';
p_values = [0.024, 0.000001, 0.217, 0.199, 0.079, 0.00031, 0.202, 0.252, 0.028, 0.00021, 0.365, 0.851];

fdr_corrected_p = mafdr(p_values, 'BHFDR', true);

disp('原始p值:');
disp(p_values);
disp('FDR校正后的p值:');
disp(fdr_corrected_p);

data = struct('p_values', p_values, 'fdr_corrected_p', fdr_corrected_p);

savePath=fullfile(saveDir,[filename,'_fdr_corrected_p.mat']);
save(savePath,'data')