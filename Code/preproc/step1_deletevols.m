clc
clear
rootdir='F:\fMRI_data\FunImg';

cd(rootdir)
sublist=dir('sub*');

for s=1:length(sublist)
    
    cd([rootdir filesep sublist(s).name])
    
    filename=dir('*.nii');
    
    
    [d,h]=y_Read([rootdir filesep sublist(s).name filesep filename.name]);
    y_Write(d(:,:,:,11:end-10),h,[rootdir filesep sublist(s).name filesep filename.name]);
    fprintf(['delete volume:',sublist(s).name,' OK']);
        fprintf('\n');
end
