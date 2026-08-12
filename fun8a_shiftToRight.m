%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun8a_shiftToRight  function for repositioning to the RIGHT
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: repositions an object for positive delta in a given ranking
% Inputs : original ranking (1 x n), object to reposition (same as the 
%          column number), delta (positions to be repositioned; always a
%          +ve integer)
% Outputs: repositioned rankings (4 x n)
% Date   : July-2026
% 
% NOTE-1: The present function is a repositioning operator that can be expressed as a block.
%                                     _        _
%                                    |          |
%                                    |   > A >  |
%                                    |   ~ A >  |
%                                    |   > A ~  |
%                                    |   ~ A ~  |
%                                    |_        _|
% For example, the following shows an application of 2-obj A-repositioning operator over A > B > C ~ D ~ E 
%                           _     _              _                 _  
%                          |       |            |                   |                                           
%                          |   >>  |            | B > C > A > D ~ E |                                           
%      A > B > C ~ D ~ E   |   ~>  | (A, 2) =   | B > C ~ A > D ~ E |    
%                          |   >~  |            | B > C > A ~ D ~ E |                                      
%                          |   ~~  |            | B > C ~ A ~ D ~ E |                                      
%                          |_     _|            |_                 _|         
% 
% NOTE-2: Below is the analysis used for the development of above definition. Not necessary for writing/programing.
%  
% Following FOUR possibilities arise: 
%     2 kinds of obj distance                = {integer or fraction}
%     2 kinds of ranking-locality near Shift = {contains ties for the object movement or NOT}
% 
% (1) Moving an object by 0.5-obj distance = Shift so as to tie with the object to its right. 
%             A > B > C > D > E    ---->         A > C ~ B > D > E    
%       here, B was repositioned by 0.5-obj around a strict ranking.
% 
% (2) Moving an object by 1-obj distance = Shift to the right beyond 1 object. 
%             A > B > C > D > E    ---->         A > C > B > D > E    
%       here, B was repositioned by 1-obj around a strict ranking.
% 
% (3) Moving an object by 0.5-obj distance when there is a tie in the target ranking-locality. 
%             A > B > C ~ D > E    ---->         A > C ~ B ~ D > E (we call this operation Sticker)
%       here, B was repositioned by 0.5-obj around a tied ranking.
% 
%    Let us take another example (move B by 0.5-obj):
%             A > B > C ~ D ~ E    ---->         A > C ~ B ~ D ~ E (we call this operation Sticker)
% 
%    Let us take yet another example (move A by 1.5-obj):
%             A > B > C ~ D ~ E    ---->         B > C ~ A ~ D ~ E (we call this operation Sticker)
% 
% (4) Moving an object by 1-obj distance when there is a tie in the target ranking-locality (move B by 1-obj). We have two options:
%          I.   A > B > C ~ D > E    ---->         A > C ~ B ~ D > E (Sticker) (REDUNDANT. Since captured in 0.5-obj shift, see 3 above) 
%         II.   A > B > C ~ D > E    ---->         A > C > B > D > E (we call this operation UnSticker)  
%     here, B was repositioned by 1-obj around a tied ranking. 
% 
% Thus, we DEFINE 1-obj movement in ties as the UnStickier option, since first option is captured in 0.5-obj shift, see 3 above. 
% 
%    Let us take another example (move B by 1-obj):
%             A > B > C ~ D ~ E    ---->         A > C > B > D ~ E  
% 
%    Let us take yet another example (move A by 3-obj):
%             A > B > C ~ D ~ E    ---->         B > C ~ D > A > E (we call this operation Sticker)
% 
%    Let us take yet another example (move A by 4-obj):
%             A > B > C ~ D ~ E    ---->         B > C ~ D ~ E > A (we call this operation Sticker)
% 
% (5) Negative shift simply means shift to left (fun8b implements this).
% 
% Example: in ranking A > B > C ~ D ~ E, move A, when s = 3
%     (A -> 0.5)      A > B > C ~ D ~ E    ---->         B ~ A > C ~ D ~ E 
%     (A -> 1.0)      A > B > C ~ D ~ E    ---->         B > A > C ~ D ~ E 
%     (A -> 1.5)      A > B > C ~ D ~ E    ---->         B > C ~ A ~ D ~ E 
%     (A -> 2.0)      A > B > C ~ D ~ E    ---->         B > C > A > D ~ E 
%     (A -> 2.5)      A > B > C ~ D ~ E    ---->         B > C ~ D ~ A ~ E    
% 
%     (A -> 3.0)      A > B > C ~ D ~ E    ---->         B > C ~ D > A > E         I.   (proposed definition of 3-obj movement) 
%     (A -> 3.0)      A > B > C ~ D ~ E    ---->         B > C ~ D ~ A > E         II.  (NOT yet considered)  
%     (A -> 3.0)      A > B > C ~ D ~ E    ---->         B > C ~ D > A ~ E         III. (NOT yet considered)   
%     (A -> 3.0)      A > B > C ~ D ~ E    ---->         B > C ~ D ~ A ~ E         IV.  (already considered in 2.5).
% 
% LET US SIMPLIFY THE ABOVE ANALYSIS TO FOLLOWING:
% Example: in a ranking A > B > C ~ D ~ E, moving A by 1 objects is defined as 4 step process-process 
%     (A -> 1a)       A > B > C ~ D ~ E    ---->         B > A > C ~ D ~ E 
%     (A -> 1b)       A > B > C ~ D ~ E    ---->         B ~ A > C ~ D ~ E 
%     (A -> 1c)       A > B > C ~ D ~ E    ---->         B > A ~ C ~ D ~ E 
%     (A -> 1d)       A > B > C ~ D ~ E    ---->         B ~ A ~ C ~ D ~ E 
% 
%     (A -> 2a)       A > B > C ~ D ~ E    ---->         B > C > A > D ~ E 
%     (A -> 2b)       A > B > C ~ D ~ E    ---->         B > C ~ A > D ~ E 
%     (A -> 2c)       A > B > C ~ D ~ E    ---->         B > C > A ~ D ~ E 
%     (A -> 2d)       A > B > C ~ D ~ E    ---->         B > C ~ A ~ D ~ E 
% 
% NOTE-3: Thus, one can think of repositioning as the following operation,
%                                     _        _
%                                    |          |
%                                    |   > A >  |
%                                    |   ~ A >  |
%                                    |   > A ~  |
%                                    |   ~ A ~  |
%                                    |_        _|
% 
% NOTE-4: Example Inputs. Used for programing and debuging. 
% rankingBeforeShift     = [39	35	49	1	48	34	5	2	7	10	4	37	9	3	58	33	8	59	14	45	12	60	65	15	17	11	23	16	22	18	66	38	6	24.5000000000000	50	77	27	83	29	28	13	21	26	81	78.5000000000000	84.5000000000000	68	76	30.5000000000000	41	87.5000000000000	36	20	145	82	30.5000000000000	53	55	92	19	68	95	44	24.5000000000000	73	93	90.5000000000000	64	42.5000000000000	51	55	47	55	113	46	75	42.5000000000000	61	52	72	111	63	78.5000000000000	102	105	110	87.5000000000000	68	40	114	125	103	115	32	62	57	98.5000000000000	80	86	117	71	74	109	89	128.500000000000	162.500000000000	119	130	90.5000000000000	94	138.500000000000	120	137	84.5000000000000	96.5000000000000	134	96.5000000000000	100	133	101	135	98.5000000000000	183	154	176	107	106	104	70	147.500000000000	118	151	108	131.500000000000	122.500000000000	147.500000000000	121	116	169	188.500000000000	165.500000000000	153	126	159.500000000000	122.500000000000	177	167	127	141	157.500000000000	149.500000000000	124	128.500000000000	157.500000000000	146	164	161	142.500000000000	142.500000000000	131.500000000000	171.500000000000	136	144	138.500000000000	152	197	188.500000000000	170	190	175	184	159.500000000000	112	180	155.500000000000	149.500000000000	155.500000000000	191.500000000000	140	168	210	179	165.500000000000	162.500000000000	187	198	193	195	174	182	201	186	217	196	222	220.500000000000	206.500000000000	204	219	185	181	191.500000000000	220.500000000000	171.500000000000	202	227	233.500000000000	178	199	173	200	203	194	223	211	208	216	209	206.500000000000	239	213	214	218	215	224	238	226	228	225	240	229	232	230	212	233.500000000000	231	235.500000000000	235.500000000000	237	205];
% objNameToShift         = 35; % always an integer
% shiftDistInUnitsOfObj  = 5; % always an integer
% 
% We tested for (objNameToShift, shiftDistInUnitsOfObj) = (3, 2); (35, 4); (35, 5); (58, 1) on 240*4 data
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function shiftedRanking_fourInNum = fun8a_shiftToRight(rankingBeforeShift, objNameToShift, shiftDistInUnitsOfObj)
%
n = size(rankingBeforeShift, 2);
s = shiftDistInUnitsOfObj;

[looseOrderingBefShift, rankingIndexVector] = fun7_trueRanking2LooseOrdering(rankingBeforeShift);

ix = find(looseOrderingBefShift == objNameToShift, 1, 'first');

% edited on 23/Apr/2023
% when objects toward the edge are tied, the repositioning based on loose
% ordering can lead to the loose order of the tied object to be on the right of its equiranked neighbors
% and this, repositioning it may trigger spillover to (n+2)th rank or beyond
% solve this problem by searching if the object to shift is tied with other objects, if yes, then in loose ordering 
% move this object to the left most position among its equi-ranked neighbors

objsWithEqualRanksOldPlaces = find(rankingIndexVector == rankingIndexVector(ix)); % say, ix = 4 and [2 3 4] have equal ranks
if size(objsWithEqualRanksOldPlaces, 2) > 1 % if obj is tied with other objects move it to the left for ordering
    looseOrderingBefShiftNew = looseOrderingBefShift; % initialize and only move the objects with equal ranks as the object of interest
    objsWithEqualRanksNewPlace = objsWithEqualRanksOldPlaces; % [2 3 4]
    objsWithEqualRanksNewPlace(objsWithEqualRanksNewPlace==ix) = []; % [2 3]
    objsWithEqualRanksNewPlace = [ix objsWithEqualRanksNewPlace]; % [4 2 3] % move ix to left most, so right shift does not cause spill over and havoc
    looseOrderingBefShiftNew(objsWithEqualRanksOldPlaces) = looseOrderingBefShift(objsWithEqualRanksNewPlace);
    
    % update looser ordering and ix
    looseOrderingBefShift = looseOrderingBefShiftNew;
    ix = find(looseOrderingBefShift == objNameToShift, 1, 'first');
end

%                                                        part1     part2        part3          part4
if ix+s == n+1 %     when we move an object to the right of the last object, ix+s = n+1, in that case we only want objects until n
    looseOrdering_shifted_gt_gt_a = [looseOrderingBefShift([1:ix-1, ix+1:ix+s-1]) objNameToShift];
else 
    looseOrdering_shifted_gt_gt_a = [looseOrderingBefShift([1:ix-1, ix+1:ix+s]) objNameToShift looseOrderingBefShift(ix+s+1:end)];
end
looseOrdering_shifted_eq_gt_b = looseOrdering_shifted_gt_gt_a;
looseOrdering_shifted_gt_eq_c = looseOrdering_shifted_gt_gt_a;
looseOrdering_shifted_eq_eq_d = looseOrdering_shifted_gt_gt_a;
                             
% rankingIndexVector_gt_gt_a = [rankingIndexVector_part1 rankingIndexVector_part2 rankingIndexVector_part3 rankingIndexVector_part4];


%% No Spillover % Four parts
% part-1 unhinged (OBJECTS UNTIL ix-1), 
% part-2 translated (OBJECTS ON ix+1 to ix+s-2); 
% part-3 during (OBJECTS ON -1, 0, 1), wrt ix
% part-4 after (OBJECTS on 2 to n), wrt ix

if ix == 1 % then part-1 is empty.
    rankingIndexVector_part1 = []; %before
    rankingIndexVector_part2 = rankingIndexVector(ix+1:ix+s-1)-1; %translated objects = shiftDistInUnitsOfObj - 1
    if ~isempty(rankingIndexVector_part2)
        % part 3 has 3 objects around the operator >>, >~, ~>, ~~
        rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_part2(end) + [1 2 3]; % during for gt_gt_a
        rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_part2(end) + [1 1 2]; % during for eq_gt_b
        rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_part2(end) + [1 2 2]; % during for gt_eq_c
        rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_part2(end) + [1 1 1]; % during for eq_eq_d
    
        % if the first object of part 3 is tied with the last object of part-2, keep them tied 
        if rankingIndexVector(ix+s) == rankingIndexVector(ix+s-1) 
            rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_gt_gt_a_part3-1;
            rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_eq_gt_b_part3-1;
            rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_gt_eq_c_part3-1;
            rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_eq_eq_d_part3-1;
        end
    else % for s = 1, part 2 is empty; (meaning, both part-1 and 2 are empty)
        rankingIndexVector_gt_gt_a_part3 = [1 2 3]; % during for gt_gt_a
        rankingIndexVector_eq_gt_b_part3 = [1 1 2]; % during for eq_gt_b
        rankingIndexVector_gt_eq_c_part3 = [1 2 2]; % during for gt_eq_c
        rankingIndexVector_eq_eq_d_part3 = [1 1 1]; % during for eq_eq_d
    end

else
    rankingIndexVector_part1 = rankingIndexVector(1:ix-1); %before
    rankingIndexVector_part2 = rankingIndexVector(ix+1:ix+s-1)-1; %translated objects = shiftDistInUnitsOfObj - 1
    if ~isempty(rankingIndexVector_part2)
        % when the first object of part 2 is tied with the last object of part-1
        if rankingIndexVector_part1(end) > rankingIndexVector_part2(1) 
            offsetAmount = rankingIndexVector_part1(end) - rankingIndexVector_part2(1);
            rankingIndexVector_part2 = rankingIndexVector_part2 + offsetAmount; % offsetAmount is always 1; we can club two cases, but keeping separate for clarity of thoughts
        elseif rankingIndexVector_part1(end) == rankingIndexVector_part2(1) 
            rankingIndexVector_part2 = rankingIndexVector_part2 + 1;
        end
        % part 3 has 3 objects around the operator >>, >~, ~>, ~~
        rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_part2(end) + [1 2 3]; % during for gt_gt_a
        rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_part2(end) + [1 1 2]; % during for eq_gt_b
        rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_part2(end) + [1 2 2]; % during for gt_eq_c
        rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_part2(end) + [1 1 1]; % during for eq_eq_d
    
        % if the first object of part 3 is tied with the last object of part-2, keep them tied 
        if ix+s <= n && rankingIndexVector(ix+s) == rankingIndexVector(ix+s-1) % if ix+s is more than n (n+1 basically, we do not have part-3, which is repalced below by empty vector
            rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_gt_gt_a_part3-1;
            rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_eq_gt_b_part3-1;
            rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_gt_eq_c_part3-1;
            rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_eq_eq_d_part3-1;
        end
    else % for s = 1, part 2 is empty;
        rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_part1(end) + [1 2 3]; % during for gt_gt_a
        rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_part1(end) + [1 1 2]; % during for eq_gt_b
        rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_part1(end) + [1 2 2]; % during for gt_eq_c
        rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_part1(end) + [1 1 1]; % during for eq_eq_d
        
        % when the first object of part 3 is tied with the last object of part-1, keep them tied
        if rankingIndexVector(ix-1) == rankingIndexVector(ix+1) 
            rankingIndexVector_gt_gt_a_part3 = rankingIndexVector_gt_gt_a_part3-1;
            rankingIndexVector_eq_gt_b_part3 = rankingIndexVector_eq_gt_b_part3-1;
            rankingIndexVector_gt_eq_c_part3 = rankingIndexVector_gt_eq_c_part3-1;
            rankingIndexVector_eq_eq_d_part3 = rankingIndexVector_eq_eq_d_part3-1;
        end
    end
end

% if the object is repositioned to the end, i.e. ix + s = n, then we have no object to the right of repositioned object
% in this case, objects in part-1, part-2, and first two objects in part-3 cover all n positions.
% So, delete the last element of part-3, and no need to calculated part 4. 
if ix + s == n+1
    rankingIndexVector_gt_gt_a_part3(2:3) = [];
    rankingIndexVector_eq_gt_b_part3(2:3) = [];
    rankingIndexVector_gt_eq_c_part3(2:3) = [];
    rankingIndexVector_eq_eq_d_part3(2:3) = [];

    rankingIndexVector_gt_gt_a_part4 = []; 
    rankingIndexVector_eq_gt_b_part4 = []; 
    rankingIndexVector_gt_eq_c_part4 = []; 
    rankingIndexVector_eq_eq_d_part4 = []; 
elseif ix + s == n 
    rankingIndexVector_gt_gt_a_part3(3) = [];
    rankingIndexVector_eq_gt_b_part3(3) = [];
    rankingIndexVector_gt_eq_c_part3(3) = [];
    rankingIndexVector_eq_eq_d_part3(3) = [];

    rankingIndexVector_gt_gt_a_part4 = []; 
    rankingIndexVector_eq_gt_b_part4 = []; 
    rankingIndexVector_gt_eq_c_part4 = []; 
    rankingIndexVector_eq_eq_d_part4 = []; 
elseif ix + s == n-1 
    rankingIndexVector_gt_gt_a_part4 = []; 
    rankingIndexVector_eq_gt_b_part4 = []; 
    rankingIndexVector_gt_eq_c_part4 = []; 
    rankingIndexVector_eq_eq_d_part4 = []; 
else
    offset = rankingIndexVector(ix+s+2)-rankingIndexVector(ix+s+1);
    rankingIndexVector_after = rankingIndexVector(ix+s+2:end);
    rankingIndexVector_after = rankingIndexVector_after-rankingIndexVector_after(1);
    afterGuy = offset+rankingIndexVector_after;
    
    rankingIndexVector_gt_gt_a_part4 = rankingIndexVector_gt_gt_a_part3(end)+afterGuy; %after
    rankingIndexVector_eq_gt_b_part4 = rankingIndexVector_eq_gt_b_part3(end)+afterGuy; %after
    rankingIndexVector_gt_eq_c_part4 = rankingIndexVector_gt_eq_c_part3(end)+afterGuy; %after
    rankingIndexVector_eq_eq_d_part4 = rankingIndexVector_eq_eq_d_part3(end)+afterGuy; %after
end
% collect four parts of ranking for each of the four repositioned vectors
rankingIndexVector_gt_gt_a = [rankingIndexVector_part1, rankingIndexVector_part2, rankingIndexVector_gt_gt_a_part3, rankingIndexVector_gt_gt_a_part4];
rankingIndexVector_eq_gt_b = [rankingIndexVector_part1, rankingIndexVector_part2, rankingIndexVector_eq_gt_b_part3, rankingIndexVector_eq_gt_b_part4];
rankingIndexVector_gt_eq_c = [rankingIndexVector_part1, rankingIndexVector_part2, rankingIndexVector_gt_eq_c_part3, rankingIndexVector_gt_eq_c_part4];
rankingIndexVector_eq_eq_d = [rankingIndexVector_part1, rankingIndexVector_part2, rankingIndexVector_eq_eq_d_part3, rankingIndexVector_eq_eq_d_part4];



% create lists for looseOrdering and rankingIndexVec to return shiftedRankings
looseOrdering_AllFour =       [ looseOrdering_shifted_gt_gt_a ;
                                looseOrdering_shifted_eq_gt_b ;
                                looseOrdering_shifted_gt_eq_c ;
                                looseOrdering_shifted_eq_eq_d ];

rankingIndexVectors_AllFour = [ rankingIndexVector_gt_gt_a ;
                                rankingIndexVector_eq_gt_b ;
                                rankingIndexVector_gt_eq_c ;
                                rankingIndexVector_eq_eq_d ];


shiftedRanking_fourInNum = fun6_looseOrdering2TrueRanking(looseOrdering_AllFour, rankingIndexVectors_AllFour);
