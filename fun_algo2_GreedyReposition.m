%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_algo2_GreedyReposition  function for Greedy Reposition algorithm
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements Greedy Reposition algorithm 
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          seed ranking (1 x n), search radius
% Outputs: consensus ranking, Kemeny distance
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outputRankingOfGreedy, kemOfOutput] = fun_algo2_GreedyReposition(givenRankLIST, weights, inputRanking, searchRad)
%
s = searchRad; 

n = size(givenRankLIST, 1);
k = size(givenRankLIST, 2);
allCombinations = nchoosek(1:n, 2);

initialTotKem = fun3_KemenyDist(givenRankLIST, weights, inputRanking, allCombinations);

updatedRanking = inputRanking; % initiate the ranking after the greedy algo with input ranking
updatedTotKem = initialTotKem;
currentPerm = zeros(1, n);

% here we are limiting the search radius to the input given to the function
if s < n/2
    positionRange = [1:s, n-s:n-1];
    candidateTotKemDist = zeros(1, 2*s);
    currRankingLIST = zeros(2*s, n);
else
    positionRange = 1:n-1;
    candidateTotKemDist = zeros(1, n-1);
    currRankingLIST = zeros(n-1, n);
end

%% GreedyReposition begins

% 1. (sweeping) Move each object one-by-one. Systematic sweeping.
% Get loose ordering (since we want to move objects)
% [~, looseOrderingBefIter] = sort(inputRanking);

[looseOrderingBefIter, rankingIndexVector] = fun7_trueRanking2LooseOrdering(inputRanking);
% outputRanking = fun6_looseOrdering2TrueRanking(looseOrderingBefIter, rankingIndexVector);

for objIndexInInitialRanking = 1:n % counter over the object to move
    count = 0; % index for list of kemeny distances for 4*s shifts of the object. 
    objNameToRepos = looseOrderingBefIter(objIndexInInitialRanking);
    
    candidateRankForCurrObjRepos = zeros(8*s, n); % 2s repositions * 4 rankings

    % 2. (repositioning) For each object, assess all possible moves and see if that results in improvement
    for reposDistance = [-s:-1, 1:s] % <= 2s repositions. s on each side. Each repositioning gives 4 rankings.
        count = count + 1;
        reposRanking_fourInNum = fun8_repositioningOperator(updatedRanking, objNameToRepos, reposDistance);
        candidateRankForCurrObjRepos(4*count-3:4*count, :) = reposRanking_fourInNum;
    end

    candidateRankForCurrObjRepos = unique(candidateRankForCurrObjRepos, 'rows');
    candidateTotKemDist = zeros(1, size(candidateRankForCurrObjRepos, 1)); 

    % 3. (updating) deal with ties in inputRanking here
    for i = 1:size(candidateRankForCurrObjRepos, 1)
        candidateTotKemDist(i) = fun3_KemenyDist(givenRankLIST, weights, candidateRankForCurrObjRepos(i, :), allCombinations);
    end

    [minKemAfterRepos, reposIdForMinKem] = min(candidateTotKemDist);

    if minKemAfterRepos < updatedTotKem
        updatedTotKem = minKemAfterRepos;
        updatedRanking = candidateRankForCurrObjRepos(reposIdForMinKem, :);
    end
end

%% calculate kemeny of output
outputRankingOfGreedy = updatedRanking;
kemOfOutput = updatedTotKem;
