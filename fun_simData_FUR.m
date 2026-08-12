%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun_simData_FUR  function file to generate Mallows-phi data and execute FUR
%
% This script accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: simulates Mallows-phi data and executes FUR on those datasets
% Inputs : number of objects, number of judges, theta, number of repetitions
% Outputs: a matrix with n, k, theta, iterIndex, Kemeny distance
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function resultMatrix = fun_simData_FUR(n, k, thetaVal, numReps)
%
% seed for reproducibility and invoke rng
seedID = 1; rng(seedID,"twister"); 

% min number of ties in each ranking (30 percent of n)
nMinTied = floor(0.3*n);

% total rankings generated in a universe and number of reps
nloop = 10000; 

resultMatrix = [];

for iter = 1:numReps %number of times the simulation is repeated; fixed at 25; seems good enough

    % to adapt the appropriate value of theta
    switch n
        case 10;  divisor = 4;
        case 25;  divisor = 23;
        case 50;  divisor = 85;
        case 100; divisor = 307;
    end

    theta = thetaVal /divisor;

    iMax = floor(n - nMinTied/2); % e.g. if you want 4 tied objects out of 10, you max it on 8;
    [allRankings, ~]  = tiedrank(randi(iMax,n,nloop)); % lowerTheBetter
    allRankings = allRankings';

    consensus = allRankings(randi(size(allRankings,1),1),:);
    weights = 1;
    initialKem = zeros(size(allRankings,1),1);
    ProbKem = zeros(size(allRankings,1),1);
    for ii = 1:size(allRankings,1)
        initialKem(ii) = fun3_KemenyDist(allRankings(ii,:)', weights, consensus, nchoosek(1:n, 2));
        ProbKem(ii) = exp(-theta * initialKem(ii));
    end

    s = RandStream('mlfg6331_64');
    indx = datasample(s,1:size(allRankings,1),k,'Weights',ProbKem);
    outputMat = allRankings(indx,:);
    [givenRankLIST_initial0,ia,ic] = unique(outputMat,'rows', 'stable');
    h = accumarray(ic, 1);                              % Count Occurrences
    maph = h(ic);

    [givenRankLIST_plus_wts] = unique([outputMat maph],'rows', 'stable');
    givenRankLIST = givenRankLIST_plus_wts(:,1:end-1);
    givenRankLIST = givenRankLIST';
    weights = givenRankLIST_plus_wts(:,end)';

    %% INPUT FOR THE SUBSET DATA GENERATION AND SEED VALUES
    inputRanking = fun4_meanSeed(givenRankLIST', weights);     % generate mean seed ranking

    % print initial Kemeny and tauX
    initialKem = fun3_KemenyDist(givenRankLIST, weights, inputRanking, nchoosek(1:n, 2)); tauX = 1 - 2*initialKem/(n*(n-1)*sum(weights));
    fprintf('For initial Ranking, Kemeny distance is %i, and tauX is %f \n', initialKem, tauX); fprintf('---------------------------------\n');

    %% FUR,t
    etaList_FUR = [3, 4, 5]; searchRad =min(floor(n/2) - 1,10);
    [potentialBestRankingLIST, bestRanking, kemOfOutput, ~] = fun_algo4_FUR(givenRankLIST, weights, etaList_FUR, searchRad);

    resultMatrix =[resultMatrix; [n k thetaVal iter kemOfOutput]];

end

baseF= pwd;
matFileSuffix = 'r2';
fileName = sprintf('pa2_script1_n_%i_k_%i_theta_%0.2f_%s', n, k, thetaVal, matFileSuffix);
cd('results'); save([fileName '.mat'], 'resultMatrix');
cd(baseF)
