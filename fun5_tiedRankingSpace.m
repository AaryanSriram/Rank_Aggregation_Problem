%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun5_tiedRankingSpace  function for storing a tied ranking search space
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: store all tied ranking search space of a given size 
% Inputs : size of the tied ranking space
% Outputs: permutations of objects including ties, run time
% Date   : July-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [permsWithTies, runT] = fun5_tiedRankingSpace(n)
%
%% this function essentially stores a .mat file with all permutations including the repeated objects for n
tStart = tic;  % TIC, pair

A = cell(1,n);
for i = 1:n
    A{i} = fun5a_SetPartition(n, i);
end
sz=0;
stir = cell(sum(cellfun('length',A)), n+1);
for j = 1:n
    sz = sz + fun5b_Stirling2nd(n, j-1);
    for i =1:fun5b_Stirling2nd(n, j)

        for k = 1:j
            stir{sz+i,k}= A{1,j}{i,1}{1,k};
            stir{sz+i,n+1}= k;
        end
    end
end

stir2{1,:} = stir(1, :);

sz2=1;
for i = 2: size(stir,1)
    NumberofPerms = stir{i,n+1};
    ActualPerms = perms(1:NumberofPerms);
    for j = 1:factorial(NumberofPerms)
        ActualPerms(j,NumberofPerms+1:n+1) =NumberofPerms+1:n+1;
        stir2{sz2+j,:} = stir(i,ActualPerms(j,:));
    end
    sz2 = sz2+factorial(NumberofPerms);
end

AllRankings2 = zeros(size(stir2,1),n);
AllRankings2(1, 1:n) = (n+1)/2;
for i = 2:size(stir2,1)
    a= stir2{i};
    tp=cellfun('length',a);
    tA= [0 cumsum(tp(1:end-1))];
    tB = tp.*(tp+1)./(2*tp);
    tC = tA+tB;
    a(end)=[];
    tC(end)=[];
    ra     = cellfun('prodofsize', a);
    aa    = cat(2, a{:});
    AllRankings2(i, aa)=cell2mat(arrayfun(@(a,r)repmat(a,1,r),tC,ra,'uni',0));
end

fileName = sprintf('permsWithTies_%i.mat', n);
permsWithTies = AllRankings2; % permutations including ties
save(fileName, 'permsWithTies');

% toc
runT = toc(tStart);  % TOC, pair