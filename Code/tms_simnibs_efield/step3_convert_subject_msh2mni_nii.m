clc
clear

rootDir='F:TMS_data';
T1_NiftiDir=fullfile(rootDir,'T1_Nifti');
rerultDir = fullfile(rootDir,'simNIBS');

subList=dir(fullfile(T1_NiftiDir,'sub*'));

for s = 1:numel(subList)
    subDir = fullfile(T1_NiftiDir, subList(s).name);

    m2mList = dir(fullfile(subDir, 'm2m_*'));
    if isempty(m2mList)
        warning('m2m_* folder not found: %s', subDir);  continue;
    end

    m2mDir = fullfile(subDir, m2mList.name);

    mshDirList = dir(fullfile(subDir, 'tms_optimization_adm_*'));
    if isempty(mshDirList)
        warning('m2m_* folder not found: %s', m2mDir);  continue;
    end

    for k = 1%:numel(mshDirList)
        mshDir=fullfile(subDir,mshDirList(k).name);
        mshFileList=dir(fullfile(mshDir,'*TMS_optimize_Magstim_70mm_Fig8.msh'));

        mshFilePath=fullfile(mshDir,mshFileList.name);

        [~,stem] = fileparts(mshFilePath);

        % outPrefix = fullfile(mshDir, stem);
        % cmd = sprintf('subject2mni -i "%s" -m "%s" -o "%s"', mshFilePath, m2mDir, outPrefix);

        % outPrefix = fullfile(mshDir, [stem,'_GM']);
        % cmd = sprintf('subject2mni -i "%s" -m "%s" -o "%s" -l 1,2', mshFilePath, m2mDir, outPrefix); % 1-WM,2-GM

        outPrefix = fullfile(mshDir, [stem,'_GM']);
        cmd = sprintf('subject2mni -i "%s" -m "%s" -o "%s" -l 2', mshFilePath, m2mDir, outPrefix);

        fprintf('\n>> %s\n', cmd);
        status = system(cmd);
        if status~=0
            warning('%s subject2mni failed for：%s', m2mList.name, mshDirList(k).name);
        end
        fprintf('%s: %s finished\n\n',m2mList.name,mshDirList(k).name);
    end
end
