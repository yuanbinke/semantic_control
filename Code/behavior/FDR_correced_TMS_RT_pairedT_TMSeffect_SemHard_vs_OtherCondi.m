clc
clear

saveDir='F:\TMS\behavior\stats\SPSS_files\result_P_multiple_comparison';

filename='Results_RTms_pairedT_TMSeffect_SemHard_vs_OtherConditions_22';
p_values = [0.017, 0.00016, 0.0043, 0.0076, 0.0058, 0.0858, 0.0185, 0.00098, 0.0027];

fdr_corrected_p = mafdr(p_values, 'BHFDR', true);

disp('原始p值:');
disp(p_values);
disp('FDR校正后的p值:');
disp(fdr_corrected_p);

data = struct('p_values', p_values, 'fdr_corrected_p', fdr_corrected_p);

savePath=fullfile(saveDir,[filename,'_fdr_corrected_p.mat']);
save(savePath,'data')