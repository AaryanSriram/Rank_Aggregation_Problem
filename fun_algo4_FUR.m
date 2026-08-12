%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_algo4_FUR  function for FUR algorithm for tied ranking search space
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements FUR algorithm for tied ranking search space
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          subiteration length list, search radius, 
%          seed ranking (optional; default = mean seed ranking), maximum
%          iterations without improvement (optional; default = 5)
% Outputs: potential consensus ranking list, single consensus ranking, 
%          Kemeny distance, flag for the effective FUR branch (1: Fixed, 2:
%          Update, 3: Range)
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [potentialBestRankingLIST, bestRanking, minKemOfOutput, flag_FUR_branch] = fun_algo4_FUR(givenRankLIST, weights, etaList_FUR, searchRad , optionalSeedRanking, maxIterWithNoImprov)
%
doPrint = 1;
fullRankingsOrTied = 2;
subAlgoIndex = 0; % counter on sub-algorithm, results of which, in the end, are compared to get the best output
flag_FUR_branch = 0; % initialize
Kem_F = Inf; Kem_U = Inf; Kem_R = Inf; % initialize with Inf


if nargin == 4
    seedRankingFUR = fun4_meanSeed(givenRankLIST', weights);
    maxIterWithNoImprov = 5; % no. of times of O_BS-Oga loop with no improvement;
elseif nargin == 5
    seedRankingFUR = optionalSeedRanking;
    maxIterWithNoImprov = 5; % no. of times of O_BS-Oga loop with no improvement;
elseif nargin == 6
    seedRankingFUR = optionalSeedRanking;
else
    error("Check number of inputs to FUR.")
end


for currentMaxN1 = etaList_FUR

    %% n1-FIXED part
    seedRankingF = seedRankingFUR; % create a copy of seedRankingFUR
    n1 = currentMaxN1;
    count = 0;
    noImprovSinceIter = 0;
    while 0==0
        count = count + 1;
        % O_sc,t
        [outputRankingOfStepwise, ~, kemOfOutput] = fun_algo1_BridgeSubiteration(givenRankLIST, weights, seedRankingF, n1, fullRankingsOrTied);

        if doPrint == 1
            fprintf('(n1 FIXED) After O_BS no- %i (n1 = %i), Kemeny distance is %i \n', count, n1, kemOfOutput);
        end

        kemAfter_BridgeSubit = kemOfOutput;
        if count > 1 % kemAfterOga is not defined for count = 1
            if kemAfter_BridgeSubit < kemAfterOga % so O_BS of this turn improved over Oga of the previous
                noImprovSinceIter = 0; % reset the counter for inter-loop improvement
            end
        end

        % greedy
        [outputRankingOfGreedy, kemOfOutput] = fun_algo2_GreedyReposition(givenRankLIST, weights, outputRankingOfStepwise, searchRad);
        if doPrint == 1
            fprintf('(n1 FIXED) After Oga no- %i (searchRad = %i), Kemeny distance is %i \n', count, searchRad, kemOfOutput); fprintf('---------------------------------\n');
        end

        kemAfterOga = kemOfOutput;
        if kemAfter_BridgeSubit == kemAfterOga % no improvement intra-loop
            noImprovSinceIter = noImprovSinceIter + 1; % increase number of no-Imporvement loops
        elseif kemAfterOga < kemAfter_BridgeSubit % so Oga of this turn improved over O_BS of this turn
            noImprovSinceIter = 0; % reset the counter for no improvement iter's
        end

        if all(int32(seedRankingF*2) == int32(outputRankingOfGreedy*2)) || noImprovSinceIter > maxIterWithNoImprov % to rule out floating point error
            subAlgoIndex = subAlgoIndex + 1;
            potentialBestRankingLIST(subAlgoIndex, :) = outputRankingOfGreedy';
            kemOfOutputSubLIST(subAlgoIndex) = kemOfOutput;
            if kemOfOutput < Kem_F, Kem_F = kemOfOutput; end % store a copy of Kem from FIXED and update

            if noImprovSinceIter > maxIterWithNoImprov, fprintf(' <<<<<< No improvement for %i loops, breaking out. >>>>> \n', noImprovSinceIter); end

            break
        else
            seedRankingF = outputRankingOfGreedy;
        end
    end

    %% n1-RANGE part
    if currentMaxN1 > etaList_FUR(1) % do not run for the first eta value only b/c that is captured in FIXED case
        seedRankingR = seedRankingFUR; % create a copy of seedRankingFUR
        n1RangeSubstep = etaList_FUR(1):currentMaxN1;
        count = 0;
        noImprovSinceIter = 0;
        while 0==0
            count = count + 1;

            % stepwise (iterative convergence)
            index = 0;
            for n1 = n1RangeSubstep
                index = index + 1;
                [outputRankingOfStepWiseLIST(index, :), ~, kemOfOutput(index)] = fun_algo1_BridgeSubiteration(givenRankLIST, weights, seedRankingR, n1, fullRankingsOrTied);

                if doPrint == 1
                    fprintf('(n1 RANGE) After O_BS no- %i (n1 = %i), Kemeny distance is %i\n', count, n1, kemOfOutput(index));
                end
            end

            outputRankingOfStepwise = outputRankingOfStepWiseLIST(kemOfOutput == min(kemOfOutput), :);
            kemOfOutput = min(kemOfOutput);

            if size(outputRankingOfStepwise, 1) > 1
                outputRankingOfStepwise = outputRankingOfStepwise (1, :);
            end

            kemAfter_BridgeSubit = kemOfOutput;
            if count > 1 % kemAfterOga is not defined for count = 1
                if kemAfter_BridgeSubit < kemAfterOga % so O_BS of this turn improved over Oga of the previous
                    noImprovSinceIter = 0; % reset the counter for inter-loop improvement
                end
            end
            
            % greedy
            [outputRankingOfGreedy, kemOfOutput] = fun_algo2_GreedyReposition(givenRankLIST, weights, outputRankingOfStepwise, searchRad);
            if doPrint == 1
                fprintf('(n1 RANGE) After Oga no- %i (searchRad = %i), Kemeny distance is %i \n', count, searchRad, kemOfOutput); fprintf('---------------------------------\n');
            end

            kemAfterOga = kemOfOutput;
            if kemAfter_BridgeSubit == kemAfterOga % no improvement intra-loop
                noImprovSinceIter = noImprovSinceIter + 1; % increase number of no-Imporvement loops
            elseif kemAfterOga < kemAfter_BridgeSubit % so Oga of this turn improved over O_BS of this turn
                noImprovSinceIter = 0; % reset the counter for no improvement iter's
            end

            if all(int32(seedRankingR*2) == int32(outputRankingOfGreedy*2)) || noImprovSinceIter > maxIterWithNoImprov % to rule out floating point error
                subAlgoIndex = subAlgoIndex + 1;
                potentialBestRankingLIST(subAlgoIndex, :) = outputRankingOfGreedy';
                kemOfOutputSubLIST(subAlgoIndex) = kemOfOutput;
                if kemOfOutput < Kem_R, Kem_R = kemOfOutput; end % store a copy of Kem from RANGE and update

                if noImprovSinceIter > maxIterWithNoImprov, fprintf(' <<<<<< No improvement for %i loops, breaking out. >>>>> \n', noImprovSinceIter); end
    
                break
            else
                seedRankingR = outputRankingOfGreedy;
            end
        end
    end

    %% n1-UPDATE part
    if currentMaxN1 > etaList_FUR(1) % do not run for the first eta value only b/c that is captured in FIXED case
        seedRankingU = seedRankingFUR; % create a copy of seedRankingFUR
        n1RangeSubstep = etaList_FUR(1):currentMaxN1;
        count = 0;
        noImprovSinceIter = 0;
        while 0==0
            count = count + 1;

            % stepwise (iterative convergence)
            index = 0;
            inputRankingStepwise = seedRankingU;
            for n1 = n1RangeSubstep
                index = index + 1;
                [inputRankingStepwise, ~, kemOfOutput] = fun_algo1_BridgeSubiteration(givenRankLIST, weights, inputRankingStepwise, n1, fullRankingsOrTied);

                % basically updating the input each time. And assigning outputRankingOfStepwise after the loop.
                if doPrint == 1
                    fprintf('(n1 UPDATE) After O_BS no- %i (n1 = %i), Kemeny distance is %i \n', count, n1, kemOfOutput);
                end
            end
            outputRankingOfStepwise = inputRankingStepwise; % final inputRankingStepwise is updated output of stewise

            kemAfter_BridgeSubit = kemOfOutput;
            if count > 1 % kemAfterOga is not defined for count = 1
                if kemAfter_BridgeSubit < kemAfterOga % so O_BS of this turn improved over Oga of the previous
                    noImprovSinceIter = 0; % reset the counter for inter-loop improvement
                end
            end

            % greedy
            [outputRankingOfGreedy, kemOfOutput] = fun_algo2_GreedyReposition(givenRankLIST, weights, outputRankingOfStepwise, searchRad);
            if doPrint == 1
                fprintf('(n1 UPDATE) After Oga no- %i (searchRad = %i), Kemeny distance is %i \n', count, searchRad, kemOfOutput); fprintf('---------------------------------\n');
            end

            kemAfterOga = kemOfOutput;
            if kemAfter_BridgeSubit == kemAfterOga % no improvement intra-loop
                noImprovSinceIter = noImprovSinceIter + 1; % increase number of no-Imporvement loops
            elseif kemAfterOga < kemAfter_BridgeSubit % so Oga of this turn improved over O_BS of this turn
                noImprovSinceIter = 0; % reset the counter for no improvement iter's
            end

            if all(int32(seedRankingU*2) == int32(outputRankingOfGreedy*2)) || noImprovSinceIter > maxIterWithNoImprov % to rule out floating point error
                subAlgoIndex = subAlgoIndex + 1;
                potentialBestRankingLIST(subAlgoIndex, :) = outputRankingOfGreedy';
                kemOfOutputSubLIST(subAlgoIndex) = kemOfOutput;
                if kemOfOutput < Kem_U, Kem_U = kemOfOutput; end % store a copy of Kem from UPDATE and update

                if noImprovSinceIter > maxIterWithNoImprov, fprintf(' <<<<<< No improvement for %i loops, breaking out. >>>>> \n', noImprovSinceIter); end

                break
            else
                seedRankingU = outputRankingOfGreedy;
            end
        end
    end

    % End of three sub-algorithm steps, which were algorithm in themselves

end

[minKemOfOutput, subAlgoIndexForMinkem] = min(kemOfOutputSubLIST); % kemOfOutput;
bestRanking = potentialBestRankingLIST(subAlgoIndexForMinkem, :)';

% all rankings with min Kem
potentialBestRankingLIST = potentialBestRankingLIST(kemOfOutputSubLIST==minKemOfOutput, :);

if minKemOfOutput == Kem_F && minKemOfOutput == Kem_U && minKemOfOutput == Kem_R
    flag_FUR_branch = 123;
elseif minKemOfOutput == Kem_F && minKemOfOutput == Kem_U 
    flag_FUR_branch = 12;
elseif minKemOfOutput == Kem_U && minKemOfOutput == Kem_R 
    flag_FUR_branch = 23;
elseif minKemOfOutput == Kem_F && minKemOfOutput == Kem_R 
    flag_FUR_branch = 13;
elseif minKemOfOutput == Kem_F
    flag_FUR_branch = 1;
elseif minKemOfOutput == Kem_U
    flag_FUR_branch = 2;
elseif minKemOfOutput == Kem_R
    flag_FUR_branch = 3;
else
    fprintf('Something fishy here! Kem from FUR did not match with any of the branches.\n');
    keyboard % give control back to keyboard
end

fprintf('(FUR,t) After FUR-t, Kemeny distance is %i, flag_FUR = %i \n', minKemOfOutput, flag_FUR_branch);