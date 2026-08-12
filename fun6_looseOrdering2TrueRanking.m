%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun6_looseOrdering2TrueRanking  function for generating true ranking from
%                                 loose ordering and rank index vector
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: finds ranking from loose ordering and rank index vector 
% Inputs : loose ordering-list (p x n), rank index vector-list weight vector (p x n), 
% Outputs: ranking list (p x n)
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trueRankingLIST = fun6_looseOrdering2TrueRanking(looseOrderingGlobalLIST, rankIndexVecLIST)
%
for i = 1:size(looseOrderingGlobalLIST, 1)
    looseOrderingCurr = looseOrderingGlobalLIST(i, :);
    proxyValCurr = rankIndexVecLIST(i, :);
    tiedRankingOfProxyVal = tiedrank(proxyValCurr, 1);
    trueRankingCurr(looseOrderingCurr) = tiedRankingOfProxyVal;
    trueRankingLIST(i, :) = trueRankingCurr;
end


