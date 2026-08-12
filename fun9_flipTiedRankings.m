%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun9_flipTiedRankings  function for flipping tied ranking
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: returns a flipped ranking 
% Inputs : given ranking list (p x n)
% Outputs: flipped ranking list (p x n)
% Date   : July-2026
%
% NOTE-1: It can be proved that flippedRanking = n + 1 - inputRanking
%       And yet, I am keeping this function for its value for:
%           (a) It isn't costly and expresses a natural flow of ideas for what its purpose.
%           (b) it tests the validity of the flipping function (fun9)
% 
% NOTE-2: Example Inputs. Used for programing and debuging.
% inputRankingLIST     = [39	35	49	1	48	34	5	2	7	10	4	37	9	3	58	33	8	59	14	45	12	60	65	15	17	11	23	16	22	18	66	38	6	24.5000000000000	50	77	27	83	29	28	13	21	26	81	78.5000000000000	84.5000000000000	68	76	30.5000000000000	41	87.5000000000000	36	20	145	82	30.5000000000000	53	55	92	19	68	95	44	24.5000000000000	73	93	90.5000000000000	64	42.5000000000000	51	55	47	55	113	46	75	42.5000000000000	61	52	72	111	63	78.5000000000000	102	105	110	87.5000000000000	68	40	114	125	103	115	32	62	57	98.5000000000000	80	86	117	71	74	109	89	128.500000000000	162.500000000000	119	130	90.5000000000000	94	138.500000000000	120	137	84.5000000000000	96.5000000000000	134	96.5000000000000	100	133	101	135	98.5000000000000	183	154	176	107	106	104	70	147.500000000000	118	151	108	131.500000000000	122.500000000000	147.500000000000	121	116	169	188.500000000000	165.500000000000	153	126	159.500000000000	122.500000000000	177	167	127	141	157.500000000000	149.500000000000	124	128.500000000000	157.500000000000	146	164	161	142.500000000000	142.500000000000	131.500000000000	171.500000000000	136	144	138.500000000000	152	197	188.500000000000	170	190	175	184	159.500000000000	112	180	155.500000000000	149.500000000000	155.500000000000	191.500000000000	140	168	210	179	165.500000000000	162.500000000000	187	198	193	195	174	182	201	186	217	196	222	220.500000000000	206.500000000000	204	219	185	181	191.500000000000	220.500000000000	171.500000000000	202	227	233.500000000000	178	199	173	200	203	194	223	211	208	216	209	206.500000000000	239	213	214	218	215	224	238	226	228	225	240	229	232	230	212	233.500000000000	231	235.500000000000	235.500000000000	237	205];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function flippedRankingLIST = fun9_flipTiedRankings(inputRankingLIST)
%
flippedRankingLIST = zeros(size(inputRankingLIST)); % initialize

for i = 1:size(inputRankingLIST, 1)
    inputRanking = inputRankingLIST(i, :);
    % obtained loose ordering and ranking index
    [looseOrderingBefIter, rankingIndexVectorBef] = fun7_trueRanking2LooseOrdering(inputRanking);
    if 1 == 1
        looseOrderingAfterIter = fliplr(looseOrderingBefIter); % this is what possibly created havoc, so don't do this (Flash News: Actually, this did not create havoc! So, I killed my baby below!).
    else
        % flip rankingIndex in two steps, first flip and then renumber from 1
        % rename for easy calls
        A = looseOrderingBefIter;
        B = rankingIndexVectorBef;

        % Get repeated values and their indices in rankingIndexVectorBef
        uniqueRankValues = 1:B(end);
        uniqueRankCounts = histcounts(B, 'BinMethod', 'integers');
        repeatedRankVals = uniqueRankValues(uniqueRankCounts > 1);

        idx = B';
        repeated_idx = find(ismember(B, repeatedRankVals));

        % Loop over "repeated ranks" in rankingIndexVectorBef and flip corresponding elements in A
        for j = 1:length(repeatedRankVals)
            currRankVal = repeatedRankVals(j);
            idx = repeated_idx(B(repeated_idx) == currRankVal);
            A(idx) = flip(A(idx));
        end

        looseOrderingAfterIter = fliplr(A); % now that we have flipped subgroups of tied objects and stored a version of looseOrderingBefIter, where tied object appear in reverse object numbering, we can flip A to get loose ordering for objects in lines with our convention
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    % flip rankingIndex in two steps, first flip and then renumber from 1
    rankingIndexVectorAft = fliplr(rankingIndexVectorBef);
    rankingIndexVectorAft = max(rankingIndexVectorAft) + 1 - rankingIndexVectorAft;

    % combine loose ordering and rankingIndex to get flipped ranking
    flippedRanking = fun6_looseOrdering2TrueRanking(looseOrderingAfterIter, rankingIndexVectorAft);

    flippedRankingLIST(i, :) = flippedRanking;
end
