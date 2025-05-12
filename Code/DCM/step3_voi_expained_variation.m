clc
clear

%% Insert the subject's SPM .mat filename here
rootdir='F:\fMRI_data\processing\DCM_PEB\VOI_8_6mm';
outputdir='F:\fMRI_data\processing\DCM_PEB\VOI_8_6mm';
cd(rootdir)
sublist=dir('sub*');

for i=1:length(sublist)
    headers(1,4*i-3) = {sublist(i).name};
    headers(1,4*i-2) = {'explain'};
    headers(1,4*i-1) = {'MNI'};
    headers(1,4*i) = {'voxels'};
    
    cd([rootdir filesep sublist(i).name])
    voilist=dir('VOI_*.mat');
    for j=1:length(voilist)
        voiname= [voilist(j).name(5:end-6)];
        explain(j,4*i-3)={voiname};

        load(voilist(j).name);
        explain(j,4*i-2)={100*xY.s(1)/sum(xY.s)};
        x = num2str(round(xY.xyz(1,1)));
        y= num2str(round(xY.xyz(2,1)));
        z= num2str(round(xY.xyz(3,1)));
        coordinate=[x,32,y,32,z];
        
        explain(j,4*i-1)={coordinate};
        voxel=length(xY.XYZmm);
        explain(j,4*i)={voxel};
        %         end
    end
end



outputfile = [outputdir filesep 'voi_explained_variation_6mm.xlsx'];

table1=table(headers);
writetable(table1,outputfile,'WriteVariableNames',false,'Sheet','Sheet1','Range','A1'); 
table2=table(explain);
writetable(table2,outputfile,'WriteVariableNames',false,'Sheet','Sheet1','Range','A2'); 
    

