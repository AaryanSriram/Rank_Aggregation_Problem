%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_algo1_BridgeSubiteration  function for Bridge Subiteration algorithm
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: implements BridgeSubiteration algorithm 
% Inputs : judge ranking matrix (n x k), judge weight vector (n x k), 
%          seed ranking (1 x n), subiteration length, 
%          search space type (1: full, 2: tied)
% Outputs: consensus ranking, all consensus rankings, Kemeny distance
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outputRanking, convergedTrueRankingLIST, convergedKemDist] = ...
    fun_algo1_BridgeSubiteration(givenRankLIST, weights, rankingBeforeIteration, eta, fullRankingsOrTied)
%
n = size(givenRankLIST, 1);
etaRunOffMax = 7; % this is the highest value of eta that we want to use when stickiness is encountered
verbose = 0; % prints intermediate rankings during each iteration
iterMax = 200; % break, when number of iterations exceed iterMax
nonImpIterMax = 20; % break, when Kemeny does not improve during several iterations

%% error check
%     fprintf('n1 = %i n= %i', n1, n);
if eta > n
    error('Size of step (= %i) is more than n (= %i). Breaking out...', eta, n);
end

allCombinations = nchoosek(1:n, 2);

%% FIRST ITERATION STARTS HERE
iterIndex = 1;
trueRankingLIST(1, :) = rankingBeforeIteration;
totKemDistLIST(1) = fun3_KemenyDist(givenRankLIST, weights, rankingBeforeIteration, allCombinations);

[~, looseOrderingBefIter] = sort(rankingBeforeIteration); % since O_sc involves moving objects out, we need to deal with ordering.
bridgingActivated = 0; % initialize
theBridge = 0; % initialize if we bump into stickiness == 1 in the first go

while (1==1)
    countOnBridgeContinuationInThisIter = 0; % reset for each iteration
    breakFromWhileAsWell = 0; % an indicator used to break out of the outer loop (i.e. this while loop) when ranking matches in a nested loop (given below)

    numObjsRemovedSoFar = 0; % initialize the length of top-ranked objects in previous iteration as 1
    bestOrderingGlobal = [];
    exitIter = 0; % identifier for exiting iteration when all objects have been considered
    
    remainingObjects = looseOrderingBefIter(iterIndex, :); % initialize
    proxyValForObj = []; % Assign fictitious values to the objects during a subiteration. After the iteration is complete, create a
    
    subiterIndex = 0 ; % now we change subiterIndex during Bridging

    while (1==1)
        subiterIndex = subiterIndex + 1; % 1:n-eta+1 % n - eta + 1 is the max limit of subIterIndex (when no ties for top-ranked objects is observed).
        if exitIter == 1; break; end % we break out of the FOR loop as soon as all objects are considered

        numRemObjects = n - numObjsRemovedSoFar;
        subIterLenActual = min(eta, numRemObjects); % equal to n1, unless a smaller value of subtieration length would be able to consider all remaining objects
        %         subIterLenActual = n1; % (8-31-21, psb), why even iterate if less than eta objects are left? Use orderings from previous subiteration
        objectSubIterationLIST = remainingObjects(1:subIterLenActual);
        if numRemObjects <= eta
            exitIter = 1; % when #remaining objects is less than or equal to n1;
            % equal included b/c in the current subiteration, we will remove at least one more object
        end

        % (4/30/23, psb) in BS,tied, we may have a single remaining object if n1-1 objects get promoted, in this case nchoosek will throw error
        if numRemObjects > 1 % run modKem
            givenRankLIST_subspace = givenRankLIST(objectSubIterationLIST, :);
            [bestRankingLocal] = fun2_modKem(givenRankLIST_subspace, weights, fullRankingsOrTied);
        elseif numRemObjects == 1 % do NOT run modKem, just assign
            [bestRankingLocal] = 1; % since this is a local ranking and we got only one object
        elseif numRemObjects == 0
            break; % no objects left over from the last subiteration, this can happend when all objects in the last run-off are promoted
        end

        if size(bestRankingLocal, 1) > 1
            %         fprintf('More than one best rank found. Picking the first one...\n');

            bestRankingLocal = bestRankingLocal(1, :);
        end
        bestRankLocal_2x = int32(2*bestRankingLocal); % doubling it to rule out for floating point errors when we compare the min with other elements in bestRankLocal
        I = find(bestRankLocal_2x == min(bestRankLocal_2x));

        stickiness = size(I, 2); % number of stuck objects (value of 1 means no sticking)
        stuckObjsGlobal = objectSubIterationLIST(I);

        if  stickiness > 1 && numRemObjects > eta % (1/2) perform run-off if stickiness is > 1 but there are more than eta objects remaining.
            % a. perform full mod kem with eta = stickiness
            etaRunOff = min(etaRunOffMax, numRemObjects);
            objectRunOffLIST = remainingObjects(1:etaRunOff);
            bridgingThresholdOverSa = eta; % some choices are "eta" "etaRunOff" "2"

            givenRankLIST_RunOff = givenRankLIST(objectRunOffLIST, :);
            [bestRankingRunOff] = fun2_modKem(givenRankLIST_RunOff, weights, fullRankingsOrTied);

            % if run-off throws multiple best rankings, pick the last one, it will have non-ties, if at all
            if size(bestRankingRunOff, 1) > 1
                bestRankingRunOff = bestRankingRunOff(end, :);
            end

            % find top-ranked objects in run-off
            bestRankingRunOff_2x = int32(2*bestRankingRunOff); % doubling it to rule out for floating point errors when we compare the min with other elements in bestRankLocal
            I_runOff = find(bestRankingRunOff_2x == min(bestRankingRunOff_2x)); % index of top-ranked in run-off
            topRankedObjsGlobalInRunOff = objectRunOffLIST(I_runOff);

            % b. check if the tie broke or at least # of promotable objects reduced?
            stickinessAfterRunOff = size(I_runOff, 2); % number of stuck objects (value of 1 means no sticking)

            % c. update revised ordering, if answer to b is yes (But wait! This now involves bridging)
            %  (5-13-23, psb) start of program for bridging
            if stickinessAfterRunOff == 1 % (1.1) promote one object; check if it was theBridge, if yes, give it same rank as the last subiterIndex
                topRankedObjsGlobal = objectRunOffLIST(I_runOff);
                remainingObjects(I_runOff) = []; % remove the topRankedObj from the list of remaining objects
                % Assign equal value of subIterIndex to all the objects removed during this subiteration. After the iteration is complete,
                % we assign tied ranks using Matlab native function tiedrank (excel equivalent RANK.EQ formula)

                if topRankedObjsGlobal == theBridge
                    subiterIndex = subiterIndex - 1; % THE BRIDGE IS NOT CONTINUED but assigning same rank as the last promotion
                end

                proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff)];
                % To update the bestRankingGlobal variable for 2nd subiteration onwards, need to write some lines of code here.
                bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobal]; % storing it in a list for later use;
                numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff;

                bridgingActivated = 0; % RESET THE BRIDGE
                theBridge = 0;
            elseif stickinessAfterRunOff < bridgingThresholdOverSa % (1.2) this piece promotes all promotable objects in run-off (unless A BRIDGE IS CONTINUING)

                if bridgingActivated == 1 % (1.2.1) a2. if bridging is active, check for bridge continuity (c1-c2)
                    if any(objectRunOffLIST(I_runOff) == theBridge) % (1.2.1.1) no need to initialize theBridge, it exists if we are here (i.e., if bridging is activated)
                        % c1. theBridge is up for promotion again; continue the bridge
                        I_bridge = I_runOff(end);     % local index for Bridge
                        I_nonBrg = I_runOff(1:end-1); % local indexes for non-Bridge
                        theBridge = objectRunOffLIST(I_bridge); % global object ID of the Bridge

                        subiterIndex = subiterIndex - 1; % CONTINUE THE BRIDGE by assigning same rank as the last promotion
                        topRankedObjsGlobalInBridging = objectRunOffLIST(I_nonBrg);

                        if stickinessAfterRunOff > 2; countOnBridgeContinuationInThisIter = countOnBridgeContinuationInThisIter + 1; end

                        remainingObjects(I_nonBrg) = []; % promoting non-Bridge objects
                        remainingObjects(remainingObjects == theBridge) = []; remainingObjects = [theBridge, remainingObjects]; % shift theBridge to top

                        proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff-1)]; % one less # of obj due to bridging
                        bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInBridging];
                        numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff - 1;
                    else  % (1.2.1.2)
                        % c2. theBridge is NOT up for promotion; the bridge is broken
                        bridgingActivated = 0; % RESET THE BRIDGE
                        theBridge = 0;

                        remainingObjects(I_runOff) = []; % remove the topRankedObj from the list of remaining objects
                        proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff)];
                        bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInRunOff]; % storing it in a list for later use;
                        numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff;
                    end
                else % (1.2.2)
                    remainingObjects(I_runOff) = [];
                    proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff)];
                    bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInRunOff];
                    numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff;
                    I = I_runOff; bestRankingLocal = bestRankingRunOff;
                end
            elseif stickinessAfterRunOff >= bridgingThresholdOverSa % (1.3) this piece implements bridging
                if bridgingActivated == 1 % (1.3.1) a2. if bridging is active, check for bridge continuity (c1-c2)
                    % c. check if theBridge is up for promotion again
                    if any(objectRunOffLIST(I_runOff) == theBridge) % (1.3.1.1)
                        % c1. theBridge is up for promotion again; CONTINUE THE BRIDGE
                        I_bridge = I_runOff(end);     % local index for Bridge
                        I_nonBrg = I_runOff(1:end-1); % local indexes for non-Bridge
                        theBridge = objectRunOffLIST(I_bridge); % global object ID of the Bridge

                        subiterIndex = subiterIndex - 1; % CONTINUE THE BRIDGE by assigning same rank as the last promotion
                        topRankedObjsGlobalInBridging = objectRunOffLIST(I_nonBrg);
                        countOnBridgeContinuationInThisIter = countOnBridgeContinuationInThisIter + 1;

                        remainingObjects(I_nonBrg) = []; % promoting non-Bridge objects
                        remainingObjects(remainingObjects == theBridge) = []; remainingObjects = [theBridge, remainingObjects]; % shift theBridge to top

                        proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff-1)]; % one less # of obj due to bridging
                        bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInBridging];
                        numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff - 1;
                    else  % (1.3.1.2)
                        % c2. theBridge is NOT up for promotion; reset the bridge
                        bridgingActivated = 0;        % RESET THE BRIDGE (symbolic resetting to highlight the end of the last bridge)
                        theBridge = 0;

                        bridgingActivated = 1;        % INITATE A NEW BRIDGE
                        I_bridge = I_runOff(end);     % local index for Bridge
                        I_nonBrg = I_runOff(1:end-1); % local indexes for non-Bridge
                        theBridge = objectRunOffLIST(I_bridge); % global object ID of the Bridge
                        % bridgeRankValue = subiterIndex; % store the bridge's rank (just use subiterIndex here and reduce it by 1, if the bridge continues)
                        topRankedObjsGlobalInBridging = objectRunOffLIST(I_nonBrg);

                        remainingObjects(I_nonBrg) = []; % promoting non-Bridge objects
                        remainingObjects(remainingObjects == theBridge) = []; remainingObjects = [theBridge, remainingObjects]; % shift theBridge to top

                        proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff-1)]; % one less # of obj due to bridging
                        bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInBridging];
                        numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff - 1;
                    end
                else % (1.3.2) a1. if bridging is inactive, initiate it
                    % b1. mark one stuck object as the Bridge (i.e., promotable-but-unpromoted object)
                    % b2. promote all other promotable objects which are not the Bridge
                    bridgingActivated = 1;        % INITATE THE BRIDGE
                    I_bridge = I_runOff(end);     % local index for Bridge
                    I_nonBrg = I_runOff(1:end-1); % local indexes for non-Bridge
                    theBridge = objectRunOffLIST(I_bridge); % global object ID of the Bridge
                    % bridgeRankValue = subiterIndex; % store the bridge's rank (just use subiterIndex here and reduce it by 1, if the bridge continues)
                    topRankedObjsGlobalInBridging = objectRunOffLIST(I_nonBrg);

                    remainingObjects(I_nonBrg) = []; % promoting non-Bridge objects
                    remainingObjects(remainingObjects == theBridge) = []; remainingObjects = [theBridge, remainingObjects]; % shift theBridge to top

                    proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickinessAfterRunOff-1)]; % one less # of obj due to bridging
                    bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobalInBridging];
                    numObjsRemovedSoFar = numObjsRemovedSoFar + stickinessAfterRunOff - 1;
                end
                %  end of program for bridging
            else % (1.4) keeping this for legacy. We will not reach here as per the current logic. % this piece purges run-off (promotes objects before run-off)
                error('No reason to be here!');
            end
        else % (2/2) Either if stickiness = 1 or numRemObjects <= eta
            % promoting all top-ranked obects (1, if stickiness is 1 or all, if this is the last subiteration)
            topRankedObjsGlobal = objectSubIterationLIST(I);
            remainingObjects(I) = []; % remove the topRankedObj from the list of remaining objects
            % Assign equal value of subIterIndex to all the objects removed during this subiteration. After the iteration is complete,
            % we assign tied ranks using Matlab native function tiedrank (excel equivalent RANK.EQ formula)

            if any(topRankedObjsGlobal == theBridge)
                % for stickiness = 1, topRankedObjsGlobal is singleton; for the last subiter with potentially 1+ stickiness,
                % it may have multiple objects. Regardless, we check if any of topRankedObjsGlobal is theBridge
                subiterIndex = subiterIndex - 1; % THE BRIDGE IS NOT CONTINUED but assigning same rank as the last promotion
            end

            proxyValForObj = [proxyValForObj subiterIndex*ones(1, stickiness)];
            % To update the bestRankingGlobal variable for 2nd subiteration onwards, need to write some lines of code here.
            bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobal]; % storing it in a list for later use;
            numObjsRemovedSoFar = numObjsRemovedSoFar + stickiness;

            bridgingActivated = 0; % RESET THE BRIDGE
            theBridge = 0;
        end
    end

    %% non-top-ranked objects from last subiteration are still not part of the bestRankingGlobal.
    bestRankingLocal(I) = []; % remove currently top-ranked objects, since they are already appended to the bestRankingGlobal
    objectSubIterationLIST(I) = [];
    while (1==1)
        if numRemObjects == 0; break; end % no objects left over from the last subiteration, this can happend when all objects in the last run-off are promoted
        I = find(bestRankingLocal == min(bestRankingLocal)); % next top-ranked object
        topRankedObjsGlobal = objectSubIterationLIST(I); % top-ranked in the remaining objects
        bestRankingLocal(I) = [];
        objectSubIterationLIST(I) = [];
        proxyValForObj = [proxyValForObj (max(proxyValForObj)+1)*ones(1, size(topRankedObjsGlobal, 2))];

        subiterIndex = subiterIndex + 1;
        bestOrderingGlobal = [bestOrderingGlobal topRankedObjsGlobal];
        if size(objectSubIterationLIST, 2) == 0
            break;
        end
    end

    % if the last object is bridge, it is not included in the best ordering, update ordering and ranking index vector

    if theBridge ~= 0
        bestOrderingGlobal = [bestOrderingGlobal theBridge];
        proxyValForObj = [proxyValForObj proxyValForObj(end)];
    end

    bestTrueRankingGlobal = fun6_looseOrdering2TrueRanking(bestOrderingGlobal, proxyValForObj);
    looseOrderingBefIter(iterIndex + 1, :) = bestOrderingGlobal;

    trueRankingLIST(iterIndex + 1, :) = bestTrueRankingGlobal;

    %% commented out conversion from rank to permutation in pa2_v5
    totKemDistLIST(iterIndex + 1) = fun3_KemenyDist(givenRankLIST, weights, bestTrueRankingGlobal, allCombinations);


    %% this checks for the cyclic convergence as well (for repetition of up to 25 rank block), if any
    trueRankingLIST_2x = int32(2*trueRankingLIST);
    for i = 1:min(200, iterIndex)
        %         if isequal(2*trueRankingLIST(iterIndex + 1, :), 2*trueRankingLIST(iterIndex + 1 - i, :)) % (6-1-19, PSB) this is equivalent to comparison over (looseOrdering && proxyVal)
        if isequal(trueRankingLIST_2x(iterIndex + 1, :), trueRankingLIST_2x(iterIndex + 1 - i, :)) % (6-1-19, PSB) this is equivalent to comparison over (looseOrdering && proxyVal)

            % (6-1-19, PSB) the following line alone can replace the following if...else condition.
            %  Note that for i = 1, convergedTrueRankingLIST has just a single row
            convergedTrueRankingLIST = trueRankingLIST(iterIndex - i + 2: iterIndex + 1, :);

            breakFromWhileAsWell = 1;
            break;
        end
    end
    if (breakFromWhileAsWell == 1)
        break;
    end

    % Two ways to break the loop here
    % 1. If iterations with min Kemeny repeat across all iterations (Since Kemeny in Osc_ties is not monotonic, we check for number of times)
    nonImpIterCount = sum(totKemDistLIST == min(totKemDistLIST));
    % 2. If iterations are stuck with a bad Kemeny in the last few iterations
    badContIterCount = sum(totKemDistLIST == totKemDistLIST(end));

    if iterIndex >= iterMax
        fprintf(' <<<<< (exit flag-1) No immediate or cyclic convergence found even after 200 iterations. Terminating Osc ... \n Here are Kemeny so far ... >>>>> \n');
        disp(totKemDistLIST);
        break;
    elseif nonImpIterCount >= nonImpIterMax
        fprintf(' <<<<< (exit flag-2) Non-improving iterations with minimum Kemeny repeated for %i iterations. Terminating Osc ... \n Here are Kemeny so far >>>>> \n', nonImpIterCount);
        disp(totKemDistLIST);
        break;
    elseif badContIterCount >= nonImpIterMax
        fprintf(' <<<<< (exit flag-3) Rankings stuck with a bad Kemeny for the last %i iterations. Terminating Osc ... \n Here are Kemeny so far >>>>> \n', badContIterCount);
        disp(totKemDistLIST);
        break;
    end

    %% increase the iteration Index
    iterIndex = iterIndex + 1;
    if verbose == 1; fprintf('iter-%i, countOnBridgeContinuationInThisIter = %i\n', iterIndex, countOnBridgeContinuationInThisIter); end
end

[~, sortedIndex] = sort(totKemDistLIST);
convergedKemDist = totKemDistLIST(sortedIndex(1));
outputRanking = trueRankingLIST(sortedIndex(1), :); % just a single ranking

convergedTrueRankingLIST = trueRankingLIST(totKemDistLIST == convergedKemDist);
