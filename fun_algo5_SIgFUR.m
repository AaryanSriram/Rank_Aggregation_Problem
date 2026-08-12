%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_algo5_SIgFUR  function for SIgFUR algorithm for tied ranking search space
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements SIgFUR algorithm for tied ranking search space
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          subiteration length list, search radius, 
%          parameters for SIgFUR with fields 
%               etaList_sbi (subiteration length list for O_sbi),
%               omega (no. of iteration for O_sbi), 
%               etaList_FUR (list of eta for FUR), 
%               searchRad (search radius for Oga)
% Outputs: potential consensus ranking list, single consensus ranking, 
%          Kemeny distance, flag for the effective SIgFUR branch (1: Fixed, 2:
%          Update, 3: Range)
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [potentialBestRankingLIST, bestRanking, kemOfOutput, flag_SIgFUR_branchLIST] = fun_algo5_SIgFUR(givenRankLIST, weights, SIgFURinputs)
%____________________________________________________________________________
% This function employs FUR_t for tied rankings
% 
% INPUTS:
% givenRankLIST                  nxk       input rankings by k judges for n objects
% weights                        1xk       weight vector for k judges
% SIgFURinputs                             structure with following field
%         etaList_sbi            vector    list of eta for seed-based iteration
%         omega                  scalar    no. of iteration for seed-based iter
%         etaList_FUR            vector    list of eta for FUR, used for Osc
%         searchRad              scalar    search radius for Oga
% 
% OUTPUTS:
% potentialBestRankingLIST      1xn                 potential rankings
% bestRanking                  vector               best output ranking
% minKemOfOutput               vector               smallest Kem achieved
% flag_SIgFUR_branchLIST  \in {1/2/3/12/13/23/123}  flag for which branch of FUR worked best (1- Fixed, 2- Update, 3- Range)
%                                                   1,2,3 indicate F, U, R, respectively
%____________________________________________________________________________
% Created 22/Apr/2023, by Prakash S Badal
% 

etaList_sbi = SIgFURinputs.etaList_sbi;
omega = SIgFURinputs.omega;
searchRad = SIgFURinputs.searchRad;
etaList_FUR = SIgFURinputs.etaList_FUR;
nfold = SIgFURinputs.nfold;

potentialBestRankingLIST = []; % initialize to contain values from different realizations of eta from etaList_sbi
KemOutputFURLIST = [];
flag_FUR_branchLIST = [];

index = 0; % index over n1
doPrint = 1;

for n1 = etaList_sbi
    index = index + 1;
    [outputRanking_O_sbi, kemOfOutput_BridgeSubit] = fun_algo3_seedBasedIteration(givenRankLIST, weights, n1, omega, nfold);
    if doPrint == 1
        fprintf('After SI (sbi) Bridge-Subiteration with %i iterations (n1 = %i), Kemeny distance is %i \n', omega, n1, kemOfOutput_BridgeSubit);
    end

    % greedy
    inputToGreedy = outputRanking_O_sbi;
    [outputRankingOfGreedy, kemOutputGreedy] = fun_algo2_GreedyReposition(givenRankLIST, weights, inputToGreedy, searchRad);
    if doPrint == 1
        fprintf('After SIg (sbi+Greedy) (searchRad = %i), Kemeny distance is %i \n', searchRad, kemOutputGreedy);
    end
    
    % FUR
    inputToFUR = outputRankingOfGreedy;
    [~, outputRankingOfFUR, KemOutputFUR, flag_FUR_branch] = fun_algo4_FUR(givenRankLIST, weights, etaList_FUR, searchRad, inputToFUR);
    
    fprintf('After SIgFUR (eta = %i, omega = %i, N2 = %i - %i), Kemeny distance is %i \n', n1, omega, etaList_FUR(1), etaList_FUR(end), KemOutputFUR);
    fprintf('---------------------------------\n');

    potentialBestRankingLIST = [potentialBestRankingLIST, outputRankingOfFUR];
    KemOutputFURLIST = [KemOutputFURLIST; KemOutputFUR];
    flag_FUR_branchLIST = [flag_FUR_branchLIST; flag_FUR_branch];
end
[kemOfOutput, minKemIndex] = min(KemOutputFURLIST); % update variable kemOfOutput (as scalar) by the minimum of array kemOfOutput
bestRanking = potentialBestRankingLIST(:, minKemIndex); % update bestRanking
flag_SIgFUR_branchLIST = flag_FUR_branchLIST(minKemIndex, 1); % pass on which branch of FUR worked best
fprintf('After SIgFUR with N1- %i to %i (%i iterations), searchRad = %i, N2- %i to %i, and nfold = %i, Kemeny distance is %i \n', etaList_sbi(1), ...
    etaList_sbi(end), omega, searchRad, etaList_FUR(1), etaList_FUR(end), nfold, kemOfOutput);
fprintf('---------------------------------\n');

