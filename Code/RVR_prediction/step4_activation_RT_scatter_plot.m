clc
clear
rootdir='G:\fMRI_data\RVR_prediction\Result\TrainP_AAL_YCG_04f';
regressor={'con_0005_weak_strong_mask_cluatser_AAL_YCG'};
ROI={'IFG','dmPFC','pMTG','3ROI'};
TrainFeaP=[0.02,0.04,0.05,0.04];
i=1;% regressor naming
for j=1:4
% color
scatterColor = [[155,130,221]/255;[145,190,64]/255;[95,207,212]/255;[197,90,17]/255];
lineColor = [[155,130,221]/255;[155,196,81]/255;[95,207,212]/255;[197,90,17]/255];
textColor = [0 0 0];


% load Permutation parameter(r,p)
R_P_filename = sprintf('Permutation_R_p_%s_%s_FeatP_%.2f.mat', regressor{i}, ROI{j},TrainFeaP(j));
R_P_List=dir(fullfile(rootdir,R_P_filename));
R_P_Path=fullfile(rootdir,R_P_List.name);
load(R_P_Path);

% scater data(prediced,measure)
result_filename = sprintf('Predict_actualScore_%s_%s_FeatP_%.2f.mat', regressor{i}, ROI{j},TrainFeaP(j));
results_List=dir(fullfile(rootdir,result_filename));
results_Path=fullfile(rootdir,results_List.name);
load(results_Path);


%% scatter plot
xmin=min(results(:,2))*0.98;
xmax=max(results(:,2))*1.02;
ymin=min(results(:,1))*0.98;
ymax=max(results(:,1))*1.02;

figure(1);

performance = scatter(results(:,2), results(:,1),...
    'MarkerFaceColor', scatterColor(j,:),...  
    'MarkerEdgeColor', scatterColor(j,:),...  
    'Marker', 'o');

% Debugging prints to ensure correct values
disp(['R = ' num2str(R_p(1))]);
disp(['P = ' num2str(R_p(2))]);

% Adjust title for P-value
if R_p(2) < 0.001
    labtitle = sprintf('r = %.2f, {\\it p} < 0.001', R_p(1));
else
    labtitle = sprintf('r = %.2f, {\\it p} = %.3f', R_p(1), R_p(2));
end

% Additional plot settings
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'LineWidth', 2.5);
set(gcf, 'WindowStyle', 'normal');
set(gca, 'tickdir', 'in');
% set(gca, 'Box', 'on');
axis([xmin xmax * 1.1 ymin ymax * 1.1]);

% Set title and labels with the specified font size
title(labtitle,...
    'interpreter', 'tex',...  
    'FontSize', 28,...
    'Color', textColor);
xlabel('Measured ¦¤RT', 'FontSize', 24);
ylabel('Predicted ¦¤RT', 'FontSize', 24);
hold on;

% Fit and plot the regression line
p = polyfit(results(:, 2), results(:, 1), 1); % p returns 2 coefficients fitting r = a_1 * x + a_2
r = p(1) * results(:, 2) + p(2); % compute a new vector r that has matching datapoints in x
plot(results(:,2), r,...
    '-',...                
    'Color', lineColor(j,:),... 
    'LineWidth', 3);
hold on;

% Save the figure
picname=['Color_nobox_',regressor{i},'_',ROI{j},'_FeatP_',num2str(TrainFeaP(j)),'_scatter'];
picPath=fullfile(rootdir,[picname,'.tiff']);
print(1,picPath,'-dtiff','-r600');

close(1);

end