clc
clear

saveDir='F:\TMS\behavior\stats\subregion_pairedt_Perm\result';

% % RT 
% filename='Multiple_Comparison_RT_pairedT_Perm_apIFG_apMTG_vs_Vertex_16';
% % order:aIFG,midIFG,aMTG,pMTG
% p_values = [0.7692,0.0152,0.0832,0.1520,0.0150,0.0006,0.5850,0.6160,0.3794,0.0020,0.0752,0.0058,0.1136,0.0644,0.8834,0.1160];

% ACC
filename='Multiple_Comparison_ACC_pairedT_Perm_apIFG_apMTG_vs_Vertex_16';
% order:aIFG,midIFG,aMTG,pMTG
p_values = [0.4388,0.0304,0.8490,1,0.0306,0.3828,0.1740,0.1078,0.6488,0.3882,0.6824,0.0340,0.5232,0.2096,0.0602,0.4536];


fdr_corrected_p = mafdr(p_values, 'BHFDR', true);


disp('原始p值:');
disp(p_values);
disp('FDR校正后的p值:');
disp(fdr_corrected_p);

data = struct('Perm_p', p_values, 'fdr_corrected_p', fdr_corrected_p);

savePath=fullfile(saveDir,[filename,'_fdr_p.mat']);
save(savePath,'data')