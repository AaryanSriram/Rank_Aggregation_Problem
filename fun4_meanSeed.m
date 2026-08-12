%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun4_meanSeed  function for finding mean ranking
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: finds mean ranking for a judge ranking matrix
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
% Outputs: mean ranking
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function averageRanking = fun4_meanSeed(ranksToAverage, weights)
%
    weightedRank = ranksToAverage .* weights';
    % averagedRank = mean(weightedRank, 1); % fails for NaN
    
    numerator = sum(weightedRank, 1, 'omitnan');
    denominator = sum((~isnan(ranksToAverage)) .* weights', 1); % divide by sum of surviving weights, i.e., non-NaN weights
    
    averagedRank = numerator ./ denominator;
    
    averageRanking = tiedrank(averagedRank); % by default, tiedrank returns the ranking in an increasing order;

