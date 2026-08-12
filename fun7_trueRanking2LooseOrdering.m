%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun7_trueRanking2LooseOrdering  function for generating loose ranking and
%                                 rank index vector from ranking
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: finds loose ordering and rank index vector, given ranking 
% Inputs : ranking list (p x n)
% Outputs: loose ordering-list (p x n), rank index vector-list weight vector (p x n), 
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [looseOrderingLIST, rankIndexVecLIST] = fun7_trueRanking2LooseOrdering(trueRankingLIST)
%
n = size(trueRankingLIST, 2);
for i = 1:size(trueRankingLIST, 1)
    trueRanking= trueRankingLIST(i, :);
    [~, looseOrdering] = sort(trueRanking);
    looseOrderingLIST(i, :) = looseOrdering;
    
    rankIndexVec = [];
    proxyVal = 0;
    
    while (1==1)
        %     I = find(trueRanking == min(trueRanking));
        numRep = sum(trueRanking == min(trueRanking));
        proxyVal = proxyVal + 1;
        trueRanking(trueRanking == min(trueRanking)) = [];
        rankIndexVec = [rankIndexVec proxyVal*ones(1, numRep)];
        if isempty(trueRanking)
            break
        end
    end
        rankIndexVecLIST(i, :) = rankIndexVec;
end