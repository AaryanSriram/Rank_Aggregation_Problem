%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script4_Sec6p2_Ex6p2  script file to reproduce Section 6.2, Example 6.2 
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: executes FUR and SIgFUR on a dataset
% Inputs : teaching-centric University data (229 x 5), algorithm parameters
% Outputs: consensus ranking, Kemeny distance, runtime
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
fileName = 'inputData\uniDataTeaching_229x5.xlsx'; n = 229; k = 5;

[~, ~, weights, givenRankLIST, objectNameLIST] = fun1_readScore(fileName);

if n > size(givenRankLIST, 1) || k > size(givenRankLIST, 2)
    error('Input n (%i) or k (%i) exceeds variable dimensions (%ix%i).', n, k, size(givenRankLIST, 1), size(givenRankLIST, 2))
end

% generate mean seed ranking
inputRanking = fun4_meanSeed(givenRankLIST', weights);

% print initial Kemeny and tauX
initialKem = fun3_KemenyDist(givenRankLIST, weights, inputRanking, nchoosek(1:n, 2)); tauX = 1 - 2*initialKem/(n*(n-1)*sum(weights));
fprintf('For initial Ranking, Kemeny distance is %i, and tauX is %f \n', initialKem, tauX); fprintf('---------------------------------\n');
algoCount = 0;

%% FUR,t 
if 1 == 1 
    algoCount = algoCount + 1; tStart(algoCount) = tic; 
    etaList_FUR = 3; searchRad = 40;  % 229x5 Teaching-centric 

    [potentialBestRankingLIST, bestRanking, kemOfOutput, flag_FUR_branch] = fun_algo4_FUR(givenRankLIST, weights, etaList_FUR, searchRad);
    [numTies, longestChainOfTies] = fun11_count_ties(bestRanking);
    numTiesLIST(algoCount) = numTies; longestChainOfTiesLIST(algoCount) = longestChainOfTies;

    kemOfOutputLIST(algoCount) = kemOfOutput; tauXLIST(algoCount) = 1 - 2*kemOfOutput/(n*(n-1)*sum(weights)); tElapsed(algoCount) = toc(tStart(algoCount));
    algoName{algoCount, :} = 'FUR'; 
    paramVal{algoCount, :} = sprintf('N1_%i_to_%i_searchRad_%i', etaList_FUR(1), etaList_FUR(end), searchRad);

    bestRankingLIST(:, algoCount) = bestRanking;
end

%% Modifying Table properties to include all the details pertaining to Kemeny, tauX, and RunTime.
T = table(algoName, paramVal); T.Properties.VariableNames{1} = 'Algorithm'; T.Properties.VariableNames{2} = 'Parameters';
T(:, 3:7) = table(kemOfOutputLIST', tauXLIST', numTiesLIST', longestChainOfTiesLIST', (round(tElapsed*1000)/1000)');

T.Properties.VariableNames{3} = 'kemeny';    T.Properties.VariableNames{4} = 'tauX';
T.Properties.VariableNames{5} = 'numTies';   T.Properties.VariableNames{6} = 'longestChainTies';
T.Properties.VariableNames{7} = 'runT';

disp(T);

baseF= pwd;
matFileSuffix = 'r2';
fileName = sprintf('pa2_script5_n_%i_k_%i_%s', n, k, matFileSuffix);
cd('results'); save([fileName '.mat'], 'T', 'bestRankingLIST'); 
cd(baseF)