%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_algo3_seedBasedIteration  function for Seed-Based Iteration algorithm
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements seed-based iteration algorithm 
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          subiteration length, number of iterations, number of folds
% Outputs: consensus ranking, Kemeny distance
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outputRankingOfOsbi, kemOfOutput] = fun_algo3_seedBasedIteration(givenRankLIST, weights, eta, omega, nfold)
%
fullRankingsOrTied = 2; % tied (always 2), for strict, use different sets of functions.
n = size(givenRankLIST, 1);
k = size(givenRankLIST, 2);
% allCombinations = nchoosek(1:n, 2);

if nargin == 4
    nfold = 2; % we will generalize flip and stack subsequently into nfold flips; keeping it 2 to imitate Badal Das, 2018
elseif nargin > 5 || nargin < 4
    error("Check number of inputs to sbi.")
end


%% Perform Osc to find the converged cyclic or immediate ranks
if eta == n
    fprintf('eta is equal to n. \n');
    fprintf('If n is small enough, no point in running SIgFUR, use simple modKem module to obtain rankings.\n');
    fprintf('If n is large, reduce eta.\n'); return
elseif eta ~= n
    % uniqueBestRankLIST = [];
    countOnUpdateBestRankLIST = 0;
    iterIndex = 0;

    rankingInputArrayLIST = []; % \Gamma, per Badal Das, 2018
    rankingOutputArrayLIST = []; % \Psi, per Badal Das, 2018
    kemOfOutputLIST = [];

    % for seedIndex = 1:numPerms
    while (iterIndex < omega)
        %     rankingBeforeTheIteration = uniqueRandomPerm(seedIndex, :);
        iterIndex = iterIndex + 1;

        % find seed ranking for this value of r (r goes from 1 to omega)
        if iterIndex == 1 % mean rank
            rankingBeforeTheIteration = fun4_meanSeed(givenRankLIST', weights);
        elseif iterIndex == 2 % reversed output1
            arrayBeforeFlipping = rankingOutputArrayLIST(end,:); % <---- Here is the difference from the 8b file
%             rankingBeforeTheIteration = [fliplr(arrayBeforeFlipping(1, 1:round(n/2))), fliplr(arrayBeforeFlipping(1, round(n/2)+1:end))];
            rankingBeforeTheIteration = fun10_flipNstack(arrayBeforeFlipping, nfold);
            % limitation- In case of cyclic convergence, algo picks the last solution

        else
            ranksToAverage = [rankingOutputArrayLIST(1, :); rankingOutputArrayLIST(end, :)];
            % WRITE A FUNCTION FOR THIS (I think 8b should do the job)
            rankingBeforeTheIteration = fun4_meanSeed(ranksToAverage, [1 1]); % equal weights for averaging

            if any(ismember(rankingInputArrayLIST, rankingBeforeTheIteration, 'rows'))
                arrayBeforeFlipping = rankingOutputArrayLIST(end,:);  % <---- Here is the difference from the 8b file
%                 rankingBeforeTheIteration = [fliplr(arrayBeforeFlipping(1, 1:round(n/2))), fliplr(arrayBeforeFlipping(1, round(n/2)+1:end))];
                rankingBeforeTheIteration = fun10_flipNstack(arrayBeforeFlipping, nfold);
            end
        end

        % apply Osc,t
        rankingInputArrayLIST = [rankingInputArrayLIST; rankingBeforeTheIteration];
        [outRankingSingleOsc, convergedTrueRankingLIST, kemOfOutput] = fun_algo1_BridgeSubiteration(givenRankLIST, weights, rankingBeforeTheIteration, eta, fullRankingsOrTied);

        %% create a unique list of all potential permutations (rankingOutputArrayLIST)
        if isempty(rankingOutputArrayLIST) % step 3 of Sec 3.1.2 of Badal Das, 2018
            rankingOutputArrayLIST = [rankingOutputArrayLIST; outRankingSingleOsc];
            kemOfOutputLIST = [kemOfOutputLIST; kemOfOutput];
        else % step 5 of Sec 3.1.2 of Badal Das, 2018
            Lia = ismember(int32(outRankingSingleOsc*2),int32(rankingOutputArrayLIST*2),'rows'); % checks if potentialRankLIST is in rankingOutputArrayLIST
            if ~any(Lia) % i.e. if no matching row found
                countOnUpdateBestRankLIST = countOnUpdateBestRankLIST + 1;
                rankingOutputArrayLIST = [rankingOutputArrayLIST; outRankingSingleOsc];
                kemOfOutputLIST = [kemOfOutputLIST; kemOfOutput];
            end
        end
    end
    % end of all iterations here.

    %% sort all distances
    % this block prints SORTED Data
    [~, sortedIndex] = sort(kemOfOutputLIST);

    outputRankingOfOsbi = rankingOutputArrayLIST(sortedIndex(1), :);
    kemOfOutput = kemOfOutputLIST(sortedIndex(1));
end










