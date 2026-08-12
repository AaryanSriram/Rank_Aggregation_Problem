%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun11_count_ties  function to count number of ties in a ranking 
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: counts number of ties in a ranking 
% Inputs : input Ranking (row or column, 1 x n or n x 1)
% Outputs: number of ties
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [numTies, longestChainOfTies] = fun11_count_ties(inputRanking)

if size(inputRanking, 2) == 1 % transpose, if ranking is a column vec
    inputRanking = inputRanking';
end

if size(inputRanking, 1) ~= 1
    warning('multiple rankings given as input.')
    inputRanking = inputRanking(1, :);
end

[~, rankIndexVec] = fun7_trueRanking2LooseOrdering(inputRanking);

% Count the number of times each element in vec occurs
[counts, ~] = groupcounts(rankIndexVec'); 

% Longest chain of ties
longestChainOfTies = max(counts); 

% Find the elements which occur more than once
repeats = counts > 1; 

% Count the number of repeats
numTies = sum(counts(repeats)); 

end