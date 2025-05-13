function [Prediction,FeaP,Errors,survival_voxel] = RVR_LOOCV_FeatureSelection_FeaP(Subjects_Data, Subjects_Scores, Covariates, Pre_Method, ResultantFolder,FeaPthre)
%
% Subject_Data:
%           m*n matrix
%           m is the number of subjects
%           n is the number of features
%
% Subject_Scores:
%           the continuous variable to be predicted, [1*m]
%
% Covariates:
%           m*n matrix
%           m is the number of subjects
%           n is the number of covariates
%
% Pre_Method:
%          'Normalize', 'Scale', 'None'
%
% Weight_Flag:
%           whether to compute the weight, 1 or 0
%
% ResultantFolder:
%           the path of folder storing resultant files
%
% FeaPthre:
%           threshold for feature selection (retain features with correlation p <= threshold p)

% if nargin >= 5
%     if ~exist(ResultantFolder, 'dir')
%         mkdir(ResultantFolder);
%     end
% end

[Subjects_Quantity, Feature_Quantity] = size(Subjects_Data);

%% Initialize error metrics
Predicted_Scores = zeros(1, Subjects_Quantity);
AE = zeros(Subjects_Quantity,1);
SE = zeros(Subjects_Quantity,1);
APE = zeros(Subjects_Quantity,1);
sAPE = zeros(Subjects_Quantity,1);
loss = zeros(Subjects_Quantity,1);

neg_logLikelihood  = zeros(Subjects_Quantity,1);

for i = 1:Subjects_Quantity
    
    %     disp(['The ' num2str(i) ' subject!']);
    
    Training_data = Subjects_Data;
    Training_scores = Subjects_Scores;
    
    %% Leave-one-out: separate test subject and training data
    test_data = Training_data(i, :);
    test_score = Training_scores(i);
    Training_data(i, :) = [];
    Training_scores(i) = [];
    
    %% Process training data:If covariates provided, regress them out from training data
    if ~isempty(Covariates)
        Covariates_test = Covariates(i, :);
        Covariates_training = Covariates;
        Covariates_training(i, :) = [];
        [Training_quantity, Covariates_quantity] = size(Covariates_training);
        
        % Build design matrix M using SurfStat functions
        M = 1;
        for j = 1:Covariates_quantity
            M = M + term(Covariates_training(:, j));
        end
        slm = SurfStatLinMod(Training_data, M);
        
        % Remove covariate effects from training data
        Training_data = Training_data - repmat(slm.coef(1, :), Training_quantity, 1);
        for j = 1:Covariates_quantity
            Training_data = Training_data - ...
                repmat(Covariates_training(:, j), 1, Feature_Quantity) .* repmat(slm.coef(j + 1, :), Training_quantity, 1);
        end
    end
    
    % Normalize or scale traning data
    
    if strcmp(Pre_Method, 'Normalize')
        MeanValue = mean(Training_data);
        StandardDeviation = std(Training_data);
        [~, columns_quantity] = size(Training_data);
        for j = 1:columns_quantity
            Training_data(:, j) = (Training_data(:, j) - MeanValue(j)) / StandardDeviation(j);
        end
    elseif strcmp(Pre_Method, 'Scale') % Scaling to [0 1]
        MinValue = min(Training_data);
        MaxValue = max(Training_data);
        [~, columns_quantity] = size(Training_data);
        for j = 1:columns_quantity
            Training_data(:, j) = (Training_data(:, j) - MinValue(j)) / (MaxValue(j) - MinValue(j));
        end
    end
    Training_data_final = double(Training_data);
    
    %% Process test data: regress covariates if provided and apply same preprocessing
    if ~isempty(Covariates)
        test_data = test_data - slm.coef(1, :);
        for j = 1:Covariates_quantity
            test_data = test_data - repmat(Covariates_test(j), 1, Feature_Quantity) .* slm.coef(j + 1, :);
        end
    end
    % Normalize or scale test data
    if strcmp(Pre_Method, 'Normalize')
        test_data = (test_data - MeanValue) ./ StandardDeviation;
    elseif strcmp(Pre_Method, 'Scale')
        test_data = (test_data - MinValue) ./ (MaxValue - MinValue);
    end
    test_data_final = double(test_data);
    
    %% Feature selection based on correlation between each feature and training scores
    [~,FeaP]=corr(Training_data,Training_scores');

    % Remove features with p-values above the threshold (i.e., retain significant features: p <= FeaPthre)
    Training_data_final(:,FeaP>FeaPthre)=[];
    test_data_final(:,FeaP>FeaPthre)=[];
    
    
    %% RVR training & predicting
    % RVR training & predicting(linear kernel£©
    d.train{1} = Training_data_final * Training_data_final';
    d.test{1} = test_data_final * Training_data_final';
    d.tr_targets = Training_scores';
    d.use_kernel = 1;
    d.pred_type = 'regression';
    output = prt_machine_rvr(d, []);
    

    Predicted_Scores(i) = output.predictions;
    neg_logLikelihood(i) = output.ll;
    %% Compute error metrics
    
    % Compute absolute error (AE) for the current left-out sample
    AE(i) = abs(Predicted_Scores(i) - Subjects_Scores(i));
    
    % Compute squared error (SE) for the current left-out sample
    SE(i) = (Predicted_Scores(i) - Subjects_Scores(i))^2;
    

    
end


%% Populate Prediction and Errors structures
Prediction.Score = Predicted_Scores;
[Prediction.Corr, ~] = corr(Predicted_Scores', Subjects_Scores');
Prediction.LOOCV = mean(neg_logLikelihood);

Prediction.MAE = mean(AE);
Prediction.MSE = mean(SE);


Errors.AE = AE;
Errors.SE = SE;

[~, feap_full] = corr(Subjects_Data, Subjects_Scores');  
Subjects_Data(:, feap_full > FeaPthre) = [];  
survival_voxel = size(Subjects_Data, 2);      



% if nargin >= 5
disp(['The correlation is ' num2str(Prediction.Corr)]);
disp(['The MAE is ' num2str(Prediction.MAE)]);
%     % Calculating w
%     if Weight_Flag
%         [~,FeaP]=corr(Subjects_Data,Subjects_Scores');
%         Subjects_Data(:,FeaP>TrainFeaP)=[];
% %         test_data_final(p>TrainFeaP,:)=[];
%         [w_Brain, ~]=W_Calculate_RVR(Subjects_Data, Subjects_Scores, Covariates, Pre_Method, ResultantFolder);
%     end
end