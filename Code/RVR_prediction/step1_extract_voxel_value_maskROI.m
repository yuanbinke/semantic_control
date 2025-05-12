clc
clear

rootdir='F:\fMRI_data\RVR_prediction';
regressor='con_0005_weak_strong';
subfiledir=fullfile(rootdir,'glm_files',regressor);

maskdir=fullfile(rootdir,'glm_files','glm_cluster_mask_AAL_YCG');
resultdir=fullfile(rootdir,'ROIvalueExtraction',[regressor,'_mask_cluatser_AAL_YCG']);
if ~exist(resultdir)
    mkdir(resultdir);
end

maskList= dir(fullfile(maskdir,'*.nii'));
for m=5:size(maskList, 1)
    maskFile = maskList(m);
    maskPath=fullfile(maskdir,maskFile.name);
    
    [dMask, hMask] = y_Read(maskPath);
    s1 = size(dMask, 1);
    s2 = size(dMask, 2);
    s3 = size(dMask, 3);
    dmaskReshape=reshape(dMask,[61*73*61,1]);
    
    subList = dir(fullfile(subfiledir,'*.nii'));
    subvalue=zeros(length(subList),nnz(dmaskReshape));
    for s = 1:size(subList, 1)
        subfilePath=fullfile(subfiledir,subList(s).name);
        [d,h] = y_Read(subfilePath);
        d(~dMask) = NaN;
        dReshape = reshape(d, [s1 * s2 * s3, 1]);
        maskIndices = find(dmaskReshape);
        subvalue(s,:)=dReshape(maskIndices)';
    end
    
    % save as
    maskName = maskFile.name;
    [~,name,~] = fileparts(maskName);
    matName=[name,'_extraction_', regressor,'.mat'];
    matPath=fullfile(resultdir,matName);
    save(matPath,'subvalue');
end
    

