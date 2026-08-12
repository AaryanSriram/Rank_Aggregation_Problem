%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun1_readScore  function for reading the raw data
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: reads the raw file to extract judge ranking 
% Inputs : raw file name 
% Outputs: number of objects, number of judges, 
%          judge ranking matrix (n x k), object names (if available)
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [n, k, weights, scoreDataMatrix, objectNameLIST] = fun1_readScore(fileName)
%
%% picks up the data from the first sheet of the excel file
    [numData, txtData, ~] = xlsread(fileName);
    n = numData(1, 1);
    k = numData(2, 1);
    try 
        if strcmp(txtData(3), 'weights')
            fprintf('Data contains weights. Exercise caution.\n');
            weights = numData(3,:);
            scoreDataMatrix = numData(5:4+n, 1:k);
            objectNameLIST = txtData(5:4+n);
        else
            weights = ones(1, k);
            scoreDataMatrix = numData(4:3+n, 1:k);
            objectNameLIST = txtData(4:3+n);
        end
    catch
        error('Please check the input file for correct values of n and k ');
    end

    if size(scoreDataMatrix, 1) ~= n || size(scoreDataMatrix, 2) ~= k || size(weights, 2) ~= k
        error('Ranking data size does not match with n x k.');
    end

    scoreDataMatrix = tiedrank(scoreDataMatrix);