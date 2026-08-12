%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% script1_Sec6p1_simulated  script file to reproduce Section 6.1, simulated data
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: simulates Mallows-phi data and executes FUR on those datasets
% Inputs : number of objects, number of judges, theta, number of repetitions
% Outputs: consensus ranking, Kemeny distance, runtime
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
n_LIST = [10, 25, 50, 100]; % list of number of objects
k = 50; % number of judges
thetaVal_LIST = [0.01, 0.1, 0.5,0.7]; % theta value for Mallows-phi model
numReps = 25; % number of repetitions

for ii = 1:size(n_LIST, 2)
    n = n_LIST(1, ii);
    for jj = 1:length(thetaVal_LIST)
        thetaVal = thetaVal_LIST(jj);
        % Call the function to simulate data and execute FUR
        fun_simData_FUR(n, k, thetaVal, numReps);
    end
end