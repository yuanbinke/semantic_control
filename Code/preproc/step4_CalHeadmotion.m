clear
clc
drive='F:\fMRI_data\preproc\RealignParameter\rp';
sublist=dir(fullfile(drive,'sub*'));
mm=1;

for s=1:length(sublist)
   
    rp=load(fullfile(drive,sublist(s).name));
    rp(:,4:6)=rp(:,4:6)*180/pi;
    k=find(abs(rp)>=mm);
    kk=numel(k);
    headmotion(s,1)=kk;
    
end
%% save excel files
   exceloutputdir=drive;
   cd(exceloutputdir)
   filename=['CalHeadmotion_',num2str(mm),'mm.xlsx'];

for s=1:length(sublist)
    sub=sublist(s).name(1:5);
    subs{s,1}=sub;
end

headers= {'run1+2+3'};
table1=table(headers);
table2=table(subs);
table3=table(headmotion);
writetable(table1,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','B1'); 
writetable(table2,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','A2');
writetable(table3,filename,'WriteVariableNames',false,'Sheet','Sheet1','Range','B2');