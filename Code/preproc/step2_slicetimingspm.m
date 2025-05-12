%-----------------------------------------------------------------------
% Software dependencies: 
%   - MATLAB (revision 2017b)
%   - SPM12 (revision 7771): https://www.fil.ion.ucl.ac.uk/spm/
% Notes: This script was originally generated via the SPM12 Batch Editor
% and require specific paths and data to be available locally.
%-----------------------------------------------------------------------

clc
clear

drive='F:\fMRI_data\preproc';
dcmdir='F:\fMRI_data\preproc\FunRaw';
niidir='F:\fMRI_data\preproc\FunImg';
subrunlist=dir(fullfile(niidir,'sub*'));

poolobj = gcp('nocreate'); 
if ~isempty(poolobj)
    delete(poolobj); 
end
parpool; 

parfor s=1:length(subrunlist) 
    
    currentDcmDir=fullfile(dcmdir, subrunlist(s).name);
    dcm_list=dir(fullfile(currentDcmDir, '*'));
    if length(dcm_list) < 3
        error('dcm_list has fewer than 3 items.');
    end
    sorder=dicominfo(fullfile(currentDcmDir, dcm_list(3).name));
    
    currentNiiDir = fullfile(niidir, subrunlist(s).name);
    nii_list = dir(fullfile(currentNiiDir, 'sub*.nii'));
    if isempty(nii_list)
        error('nii_list is empty.');
    end
    
    N=(1:304)';
    Inputsubrun_Path=arrayfun(@(n) sprintf('%s,%d', fullfile(currentNiiDir, nii_list.name), n), N, 'UniformOutput', false);
    
    order=sorder.Private_0019_1029;
    order=typecast(uint8(order), 'double');
    
    TR=1.5;
    SliceNumber=46;
    
    referonce=find(order==0);
    rgap=referonce(2)-referonce(1);%
    refers=order(1:rgap);
    TA=TR-(TR/rgap);
    [~,Referencesort]=sort(refers);
    ReferenceSlice=Referencesort(round(rgap/2));


    jobs = struct(); 
    jobs.spm.temporal{1,1}.st.scans = {Inputsubrun_Path};
    jobs.spm.temporal{1,1}.st.nslices = SliceNumber;
    jobs.spm.temporal{1,1}.st.tr = TR;
    jobs.spm.temporal{1,1}.st.ta = TA;
    jobs.spm.temporal{1,1}.st.so = order;
    jobs.spm.temporal{1,1}.st.refslice = ReferenceSlice;
    jobs.spm.temporal{1,1}.st.prefix = 'a';
    spm_jobman('run', {jobs});

    
    FunImgAdir=fullfile(drive,'FunImgA',subrunlist(s).name);
    mkdir(FunImgAdir);
    movefile(fullfile(currentNiiDir, 'a*'), FunImgAdir);
    fprintf(['Moving slicetiming Files:',subrunlist(s).name,' OK\n']);
   

end

delete(gcp); % ¹Ø±Õ²¢ÐÐ³Ø
