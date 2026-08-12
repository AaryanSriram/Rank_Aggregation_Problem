%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun10_flipNstack  function for flip and stack for seed-based iteration
%
% This function accompanies the manuscript:
% "Efficient Heuristics for Handling Ties in Kemeny Rank Aggregation"
% Authors: Badal, P. S., and Singh, R.
%
% Purpose: returns a flipped and stacked ranking for seed-based iteration
% Inputs : given ranking (1 x n), number of folds
% Outputs: flipped-and-stacked ranking (1 x n)
% Date   : July-2026
%
% NOTE-1: Example Inputs. Used for programing and debuging. 
% arrayBeforeFlipping     = [39	35	49	1	48	34	5	2	7	10	4	37	9	3	58	33	8	59	14	45	12	60	65	15	17	11	23	16	22	18	66	38	6	24.5	50	77	27	83	29	28	13	21	26	81	78.5	84.5	68	76	30.5	41	87.5	36	20	145	82	30.5	53	55	92	19	68	95	44	24.5	73	93	90.5	64	42.5	51	55	47	55	113	46	75	42.5	61	52	72	111	63	78.5	102	105	110	87.5	68	40	114	125	103	115	32	62	57	98.5	80	86	117	71	74	109	89	128.5	162.5	119	130	90.5	94	138.5	120	137	84.5	96.5	134	96.5	100	133	101	135	98.5	183	154	176	107	106	104	70	147.5	118	151	108	131.5	122.5	147.5	121	116	169	188.5	165.5	153	126	159.5	122.5	177	167	127	141	157.5	149.5	124	128.5	157.5	146	164	161	142.5	142.5	131.5	171.5	136	144	138.5	152	197	188.5	170	190	175	184	159.5	112	180	155.5	149.5	155.5	191.5	140	168	210	179	165.5	162.5	187	198	193	195	174	182	201	186	217	196	222	220.5	206.5	204	219	185	181	191.5	220.5	171.5	202	227	233.5	178	199	173	200	203	194	223	211	208	216	209	206.5	239	213	214	218	215	224	238	226	228	225	240	229	232	230	212	233.5	231	235.5	235.5	237	205];
% nfold = 7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function flipNstackedRanking = fun10_flipNstack(arrayBeforeFlipping, nfold)
%
n = size(arrayBeforeFlipping, 2);
foldPoints = floor(linspace(1, n, nfold+1)); % object ranks where we fold
foldPoints(1) = 0; % in order to include the first object

flipNstackedRanking = [];
for i = 1:nfold
    ranksOfThisFold = arrayBeforeFlipping(foldPoints(i)+1:foldPoints(i+1));
    flipRanksOfThisFold = fliplr(ranksOfThisFold);
    flipNstackedRanking = [flipNstackedRanking, flipRanksOfThisFold];
end
