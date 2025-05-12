clc
clear

% Set the directory for saving results

resultdir='F:\TMS\behavior\stats\subregion_pairedt_Perm\result';
cd('F:\TMS\behavior\stats\subregion_pairedt_Perm\input_data')

% Define data file pairs for each region (IFG)
% data_pairs = {
%     'aIFG_RT.mat', 'Vertex_RT_aIFG.mat';
%     'pIFG_RT.mat', 'Vertex_RT_pIFG.mat';
%     'aIFG_ACC.mat', 'Vertex_ACC_aIFG.mat';
%     'pIFG_ACC.mat', 'Vertex_ACC_pIFG.mat'
% };

% Define data file pairs for each region (pMTG)
data_pairs = {
    'a_pMTG_RT.mat', 'Vertex_RT_a_pMTG.mat';
    'p_pMTG_RT.mat', 'Vertex_RT_p_pMTG.mat';
    'a_pMTG_ACC.mat', 'Vertex_ACC_a_pMTG.mat';
    'p_pMTG_ACC.mat', 'Vertex_ACC_p_pMTG.mat'
};


% Set the number of permutations for the permutation test
nPerm = 5000;

% Loop over each pair of data files
for pair_idx = 1:size(data_pairs, 1)
    
    % Load both data files in the current pair
    load(data_pairs{pair_idx, 1});
    load(data_pairs{pair_idx, 2});
    
    % Extract variable names and assign to a and b
    saveName = erase(data_pairs{pair_idx, 1}, '.mat'); 
    a = eval(saveName); 
    b = eval(erase(data_pairs{pair_idx, 2}, '.mat')); 
    
    % Initialize arrays to store results
    t_values = zeros(1, 2); 
    p_values_ttest = zeros(1, 2); 
    p_values_permutation = zeros(1, 2); 


% Loop over 4 conditions
for cond = 1:4
    
    % Extract data for the current condition
    data_A = a(:, cond); 
    data_B = b(:, cond); 
    
    % Paired t-test
    [h, p_value, ci, stats] = ttest(data_A, data_B);
    fprintf('%s Condition %d Paired T-Test:\n', saveName,cond);
    fprintf('t-statistic = %.4f, p-value = %.4f\n', stats.tstat, p_value);
    
    % Save t-value and p-value
    t_values(cond) = stats.tstat;
    p_values_ttest(cond) = p_value;

    % Perform permutation test
    permutation_p_value = permutation_test(data_A, data_B, nPerm);
    fprintf('%s Condition %d Permutation Test:\n', saveName,cond);
    fprintf('p-value = %.4f\n', permutation_p_value);
    fprintf('\n');
    
    % Save p-value from permutation test
    p_values_permutation(cond) = permutation_p_value;
end

% Construct filename and save the results
save_filename = sprintf('pairedT_Perm_results_%s.mat', saveName);
save_Path=fullfile(resultdir,save_filename);
save(save_Path, 't_values', 'p_values_ttest', 'p_values_permutation');
end

cd(resultdir)

% Permutation test function
function p_value = permutation_test(x, y, nPerm)
    observed_diff = mean(x - y);
    count = 1;

    for i = 1:nPerm
        % Randomly flip the signs of the differences
        signs = randi([0, 1], size(x)) * 2 - 1; % Generate random signs (1 or -1)
        permuted_diff = mean((x - y) .* signs);

        if abs(permuted_diff) >= abs(observed_diff)
            count = count + 1;
        end
    end

    p_value = count / (nPerm + 1);
end