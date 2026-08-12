%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun8b_shiftToLeft  function for repositioning to the LEFT
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: repositions an object for negative delta in a given ranking
% Inputs : original ranking (1 x n), object to reposition (same as the 
%          column number), delta (positions to be repositioned; always a
%          -ve integer)
% Outputs: repositioned rankings (4 x n)
% Date   : July-2026
% 
% NOTE: This function uses:
%       (a) fun8a_shiftToRight    for shifting to right without spill over
%       (b) fun9_flipTiedRankings for flipping tied rankings
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function shiftedRanking_fourInNum = fun8b_shiftToLeft(rankingBeforeShift, objNameToShift, shiftDistInUnitsOfObj)
%    
% flip the input ranking
flippedRankingBeforeShift = fun9_flipTiedRankings(rankingBeforeShift);
% shift objects as if to the right.

flippedShiftedRanking_fourInNum = fun8a_shiftToRight(flippedRankingBeforeShift, objNameToShift, shiftDistInUnitsOfObj);
% flip the four rankings obtained above
shiftedRanking_fourInNum = fun9_flipTiedRankings(flippedShiftedRanking_fourInNum);
