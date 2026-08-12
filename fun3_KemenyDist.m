%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun3_KemenyDist  function for finding total Kemeny Distance 
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: finds Kemeny distance for a given ranking 
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          given ranking, all combination of objects
% Outputs: Total Kemeny Distance
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [totKemDist] = fun3_KemenyDist(givenRankLIST, weights, currentRank, allCombinations)
%
n = size(givenRankLIST, 1);
k = size(givenRankLIST, 2);

%% Calculations
individualDist = zeros(1, k); % initialize individual distances
% find the distances of all possible rankings from each user-input Ranking
currenTestRanking = currentRank;
for rankingIndex = 1:k
    for combIndex = 1:size(allCombinations, 1)

        firstPersonID = allCombinations(combIndex, 1);
        secondPersonID = allCombinations(combIndex, 2);

        if isnan(givenRankLIST(firstPersonID, rankingIndex)) || isnan(givenRankLIST(secondPersonID, rankingIndex))
            individualDist(rankingIndex) = individualDist(rankingIndex) + 1; % when there is a
            continue
        end
        a = currenTestRanking(firstPersonID) - currenTestRanking(secondPersonID);
        b = givenRankLIST(firstPersonID, rankingIndex) - givenRankLIST(secondPersonID, rankingIndex);

        testValue = a * b;

        if testValue == 0 && a + b ~= 0 % 2. (a - b) > 0, (c - d) = 0; 4. (a - b) = 0, (c - d) > 0; 6. (a - b) = 0, (c - d) < 0; 8. (a - b) < 0, (c - d) = 0;
            individualDist(rankingIndex) = individualDist(rankingIndex) + 1; % Kemeny is twice of Kendall distance.
        elseif testValue < 0 % 1. (a - b) > 0, (c - d) < 0; 9. (a - b) < 0, (c - d) > 0;
            individualDist(rankingIndex) = individualDist(rankingIndex) + 2; % Kemeny is twice of Kendall distance.
            % else % 3. (a - b) > 0, (c - d) > 0; 7. (a - b) < 0, (c - d) < 0;
        end

    end
end
totKemDist = dot(individualDist, weights);