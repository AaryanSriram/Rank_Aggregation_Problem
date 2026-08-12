%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun8_repositioningOperator  function for repositioning operator 
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: repositions an object by a given delta in a given ranking
% Inputs : original ranking (1 x n), object to reposition (same as the 
%          column number), delta (positions to be repositioned; always a
%          +ve/-ve integer)
% Outputs: repositioned rankings (4 x n)
% Date   : July-2026
% 
% NOTE-1: The present function is a shifting operator that can be expressed as a block.
% For detailed development/reasoning behind above definition, see comments in fun8a.
%                                     _        _
%                                    |          |
%                                    |   > A >  |
%                                    |   ~ A >  |
%                                    |   > A ~  |
%                                    |   ~ A ~  |
%                                    |_        _|
% For example, the following shows an application of 2-obj A-shifting operator over A > B > C ~ D ~ E 
%                           _     _              _                 _  
%                          |       |            |                   |                                           
%                          |   >>  |            | B > C > A > D ~ E |                                           
%      A > B > C ~ D ~ E   |   ~>  | (A, 2) =   | B > C ~ A > D ~ E |    
%                          |   >~  |            | B > C > A ~ D ~ E |                                      
%                          |   ~~  |            | B > C ~ A ~ D ~ E |                                      
%                          |_     _|            |_                 _|         
% NOTE-2: This function takes care of 
%       (a) shift to left, i.e. negative shiftDist values and 
%       (b) Spill over or under when the object is moved over the edge of ranking 
%
% NOTE-3: This function uses:
%       (a) fun8a_shiftToRight    for shifting to right without spill over
%       (b) fun8b_shiftToLeft     for shifting to right without spill over
%       (c) fun9_flipTiedRankings for flipping tied rankings
% 
% NOTE-4: Example Inputs. Used for programing and debuging. 
% rankingBeforeShift     = [39	35	49	1	48	34	5	2	7	10	4	37	9	3	58	33	8	59	14	45	12	60	65	15	17	11	23	16	22	18	66	38	6	24.5	50	77	27	83	29	28	13	21	26	81	78.5	84.5	68	76	30.5	41	87.5	36	20	145	82	30.5	53	55	92	19	68	95	44	24.5	73	93	90.5	64	42.5	51	55	47	55	113	46	75	42.5	61	52	72	111	63	78.5	102	105	110	87.5	68	40	114	125	103	115	32	62	57	98.5	80	86	117	71	74	109	89	128.5	162.5	119	130	90.5	94	138.5	120	137	84.5	96.5	134	96.5	100	133	101	135	98.5	183	154	176	107	106	104	70	147.5	118	151	108	131.5	122.5	147.5	121	116	169	188.5	165.5	153	126	159.5	122.5	177	167	127	141	157.5	149.5	124	128.5	157.5	146	164	161	142.5	142.5	131.5	171.5	136	144	138.5	152	197	188.5	170	190	175	184	159.5	112	180	155.5	149.5	155.5	191.5	140	168	210	179	165.5	162.5	187	198	193	195	174	182	201	186	217	196	222	220.5	206.5	204	219	185	181	191.5	220.5	171.5	202	227	233.5	178	199	173	200	203	194	223	211	208	216	209	206.5	239	213	214	218	215	224	238	226	228	225	240	229	232	230	212	233.5	231	235.5	235.5	237	205];
% objNameToShift         = 14; % always an integer
% shiftDistInUnitsOfObj  = -6; % shiftDistInUnitsOfObj; always an integer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reposRanking_fourInNum = fun8_repositioningOperator(rankingBeforeShift, objNameToShift, shiftDistInUnitsOfObj)
% 
s = shiftDistInUnitsOfObj;

%% (3-18-23, psb/rs) after intense discussion and programing, we have come to the conclusion that we do not need the case for spillover.
% For the cases of spillover, e.g., for n = 240, ix = 237th object, s = 7,
% we move it to (n - s) to the left

n = size(rankingBeforeShift, 2);
[looseOrderingBefShift, rankingIndexVectorBefShift] = fun7_trueRanking2LooseOrdering(rankingBeforeShift); % useful for debugging
ix = find(looseOrderingBefShift == objNameToShift, 1, 'first');

% ix is always +ve

% 1. Without spillover 
if ix+s <= n && ix+s > 0
    if s  > 0 % 1.1 Move to right (s > 0)
        reposRanking_fourInNum = fun8a_shiftToRight(rankingBeforeShift, objNameToShift, s);
    else % 1.2 Move to left (s < 0)
        reposRanking_fourInNum = fun8b_shiftToLeft(rankingBeforeShift, objNameToShift, -s);
    end

elseif  ix+s > n  % 2. Spillover (we cannot ever have spillover with negative s; recall s < n)
    if s > 0     % This check is always true, IFF it is tested (i.e., if ix+s > n).
        % this is equivalent to left movement by (n - s)
        sToLeft = n - s;
        reposRanking_fourInNum = fun8b_shiftToLeft(rankingBeforeShift, objNameToShift, sToLeft);
    end
elseif   ix+s <= 0  % 3. Spillunder
    sToRight = n + s;
    reposRanking_fourInNum = fun8a_shiftToRight(rankingBeforeShift, objNameToShift, sToRight);
end
   
% for debugging. Helpful to see loose orderings before and after the shift 
verbose = 0; 
if verbose == 1
    [looseOrderingAfterLIST, rankingIndexVectorAfterLIST] = fun7_trueRanking2LooseOrdering(reposRanking_fourInNum);
end


