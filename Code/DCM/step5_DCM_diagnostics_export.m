clc
clear

rootdir='F:\fMRI_Data\2_processing\DCM_PEB\DCM_PEB_2nd_level\PEB_result_sem_we_Orb_dmPFC_pMTG';

%% subjects list
spm_dir='F:\fMRI_Data\2_processing\DCM_PEB\DCM_1st_level';
sublist=dir(fullfile(spm_dir,'sub*'));
subjects=cell(1);

%% Responses and Predictions_variance explained
GCMfile=dir(fullfile(rootdir,'GCM*'));
GCMpath=fullfile(GCMfile.folder,GCMfile.name);
load(GCMpath);



for s=1:length(sublist)
    subjects{s,1}=sublist(s).name;
   
    %% Responses and Predictions_variance explained
    PSS   = sum(sum(GCM{s,1}.y.^2));
    RSS   = sum(sum(GCM{s,1}.R.^2)); 
    D(1) = 100*PSS./(PSS + RSS);
    
    %% Intrinsic and Extrinsic connections_matrix A largest connection strength
    try
        A = GCM{s,1}.Ep.A;
    catch
        A = GCM{s,1}.A;
    end
    
    if isfield(GCM{s,1}.options,'two_state') && GCM{s,1}.options.two_state
        A = exp(A);
    end
    
    D(2)  = max(max(abs(A - diag(diag(A)))));
    
    %% Posterior Correlations_estimable parameters
    qE    = spm_vec(GCM{s,1}.Ep);
    pE    = spm_vec(GCM{s,1}.M.pE);
    qC    = GCM{s,1}.Cp;
    pC    = full(GCM{s,1}.M.pC);
    k     = rank(full(pC));
    pC    = pinv(pC);
    
    D(3)  = trace(pC*qC) + (pE - qE)'*pC*(pE - qE) - spm_logdet(qC*pC) - k;
    D(3)  = D(3)/log(GCM{s,1}.v);
    
    D     = full(D);
explain(s,1:3)=D;

end

filename=[rootdir filesep 'DCMs_diagnostics.xlsx'];

headers = {'variance explained','matrix A largest connection strength','Posterior Correlations'};

table1=table(headers);
    writetable(table1,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','B1'); 
    table2=table(subjects);
    writetable(table2,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','A2'); 
    table3=table(explain);
    writetable(table3,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','B2'); 

