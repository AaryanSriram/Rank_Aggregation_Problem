%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun2_modKem  function for modified Kemeny method in tied ranking space
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements modified Kemeney in tied ranking search space
% Inputs : judge ranking matrix (n x k), judge weight vector (1 x k), 
%          search space type (1: full, 2: tied)
% Outputs: consensus ranking
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bestRanking] = fun2_modKem(givenRankLIST, weights, fullRankingsOrTied)
%
n = size(givenRankLIST, 1);
k = size(givenRankLIST, 2);

%% Calculations

if nargin == 1
    fullRankingsOrTied = 1;
end

extraRunT = 0;
if fullRankingsOrTied == 1 % only full rankings
    allPossibleRankLIST = perms(1:n);
elseif fullRankingsOrTied == 2 % rankings including tied rankings
    fileName = sprintf('permsWithTies_%i.mat', n);

    if exist(fileName, 'file') % changed to this since lappy has MATLAB 2015a
        load(fileName);
        allPossibleRankLIST = permsWithTies; % permsWithTies is a variable in the loaded file containting all rankings with ties
    else
        warning(['The MATLAB data file for n = %i does not exist, the current ', ...
                 'run time may NOT be a good representation. \n Generating ', ...
                 'MATLAB data file for all rankings corresponding to n = %i...'], n, n);
        [allPossibleRankLIST, curRunT] = fun5_tiedRankingSpace(n);
        extraRunT = extraRunT + curRunT;
        warning('Total additional run-time taken in creating .mat file- %.2f sec.', extraRunT);
    end
end

numPossibleRank = size(allPossibleRankLIST, 1); % basically, n! or S^n = \Sigma_{r=0}{n} stirling2(n, r).

individualDist = zeros(numPossibleRank, k); % initialize individual distances
totalDist = zeros(numPossibleRank, 1); % initialize sum of individual distances

% find the distances of all possible rankings from each user-input Ranking
allCombinations = nchoosek(1:n, 2);
for i = 1:numPossibleRank % basically runs for n!
    currenTestRanking = allPossibleRankLIST(i, :);
    for rankingIndex = 1:k
%         X_current = givenRankLIST(1:n, rankingIndex); % incorporated this inside the testvalue. Saves quite some time. 
        for combIndex = 1:size(allCombinations, 1)

            firstPersonID = allCombinations(combIndex, 1); % doing this rather than using currentCombination reduces run time by a lot!
            secondPersonID = allCombinations(combIndex, 2);
            testValue = (currenTestRanking(firstPersonID) - currenTestRanking(secondPersonID)) * (givenRankLIST(firstPersonID, rankingIndex) - givenRankLIST(secondPersonID, rankingIndex));
            
%% v8 (when tied rankings are also included)
            if testValue == 0 
                testValue1 = (currenTestRanking(firstPersonID) - currenTestRanking(secondPersonID)) + (givenRankLIST(firstPersonID, rankingIndex) - givenRankLIST(secondPersonID, rankingIndex));
                if testValue1 ~= 0 % 2. (a - b) > 0, (c - d) = 0; 4. (a - b) = 0, (c - d) > 0; 6. (a - b) = 0, (c - d) < 0; 8. (a - b) < 0, (c - d) = 0;
                    individualDist(i, rankingIndex) = individualDist(i, rankingIndex) + 1; % Kemeny is twice of Kendall distance.
                    % else % 5. (a - b) = 0, (c - d) = 0; 
                end
            elseif testValue < 0 % 1. (a - b) > 0, (c - d) < 0; 9. (a - b) < 0, (c - d) > 0;
                individualDist(i, rankingIndex) = individualDist(i, rankingIndex) + 2; % Kemeny is twice of Kendall distance.
            % else % 3. (a - b) > 0, (c - d) > 0; 7. (a - b) < 0, (c - d) < 0;
            end
        end
    end
            totalDist(i) = dot(individualDist(i, :), weights);
end

% indicators of minimum total distance 
indicesOfMinTotDist = find(totalDist == min(totalDist(:)))';

minDistIndicator(indicesOfMinTotDist, 1) = 1;

if size(indicesOfMinTotDist, 2) > 1
    
    maxDist = cell(numPossibleRank, 1); % initiate, this is required;
    
    for i = 1:size(indicesOfMinTotDist, 2)
        currentIndex = indicesOfMinTotDist(i);
        maxDist{currentIndex} = max(individualDist(currentIndex, :) .* weights);
    end
    
% handling the equal MaxDist cases now
    maxDistLIST = cell2mat(maxDist);
    if size(maxDistLIST, 1) > 1
        varIndDist = var(individualDist .* weights, 0, 2);
        
        equalMinMaxDistLIST = find(maxDistLIST == min(maxDistLIST(:)))';
        equalMinMaxDistGivenRankIndex = indicesOfMinTotDist(equalMinMaxDistLIST);

        % calculate sigma now
        varEqualMinMaxDist = cell(numPossibleRank, 1); % initiate, this is required;
        for i = 1:length(equalMinMaxDistGivenRankIndex)
            currentTestRanking = equalMinMaxDistGivenRankIndex(i);
            varEqualMinMaxDist{currentTestRanking} = varIndDist(currentTestRanking);
        end
    end
    
    if length(equalMinMaxDistGivenRankIndex) > 1
        varEqualMinMaxDistLIST = cell2mat(varEqualMinMaxDist);
        minIndexEqualVarGivenRanking = equalMinMaxDistGivenRankIndex(varEqualMinMaxDistLIST == min(varEqualMinMaxDistLIST));
    end
end

%% Output
if exist('varEqualMinMaxDistLIST', 'var')
    bestRanking = allPossibleRankLIST(minIndexEqualVarGivenRanking, :);
elseif exist('maxDistLIST', 'var')
    bestRanking = allPossibleRankLIST(equalMinMaxDistGivenRankIndex, :);
elseif exist('minDistIndicator', 'var')
    bestRanking = allPossibleRankLIST(indicesOfMinTotDist, :);
else
     fprintf('%i \n', totalDist(i));
end

% toc
