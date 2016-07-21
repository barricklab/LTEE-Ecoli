#=GENOME_DIFF 1.0
#=AUTHOR	Deatherage, Daniel
#=REFSEQ	BarrickLab-Private:genomes/reference/REL606.6.gbk
#=READSEQ	BarrickLab-Private:genomes/msu_rtsf/436AFAAXX/fastq_sanger/436AFAAXX_3_1_pf_REL2142.fastq.gz
#=TREATMENT	42C
#=TIME	2000
#=POPULATION	+1
SNP	1580	251	REL606	45361	C
SNP	1581	252	REL606	70867	C
SNP	1582	260	REL606	649601	G
SNP	1583	263	REL606	1329516	T
AMP	1579	1	REL606	1733290	8	2
SNP	1584	1126	REL606	2193779	T
MOB	1577	2,4	REL606	3015324	IS150	-1	3
SNP	1585	1261	REL606	3762741	T
INS	1586	1265	REL606	3875632	T
DEL	1576	1266,3	REL606	3894997	6934	mediated=IS150
MOB	1578	8,7	REL606	4524522	IS186	1	6
DEL	.	10001	REL606	2032219	23219
AMP	.	10003	REL606	474187	180	2
AMP	.	10006	REL606	2713428	60769	2	mediated=*IS186
AMP	.	10008	REL606	887915	46065	2
NOTE	10009	.	AMP10008 comes from JC10004. both oritinal junctions still exist, region between 2 junctions show an average coverage of 182.37 as compared to 96.54 and 99.93 for the 46kb on either flanking side of the region.
NOTE	10004	.	AMP10003 is based on jc10003. Region shows 1.5 to 2x coverage by bam2cov, and evidence of junction of the begining sequence with the end sequence
NOTE	10005	.	JC2 and JC4 show evidence of the new predicted junction as well as both old junctions. 
NOTE	10007	.	AMP10006 comes from JC10002. increased coverage of ~2x exists for the 60.5kb span listed. is186 element amplification at end of duplicated seq. After original apply run on 1-17-12, reevaluated to be 60769 bp. Unclear how 60595 was ever determined.
NOTE	10002	.	DEL10001 was based on MC10001 which shows deletion but possible cross contamination noise through the entire region. Suggested for additional sequencing. minimum deletion listed, but will likely need to be extended
#JC	10004		REL606	887915	1	REL606	933979	-1	0	alignment_overlap=2	coverage_minus=41	coverage_plus=43	flanking_left=35	flanking_right=35	key=REL606__887915__1__REL606__933981__-1__2____35__35__0__0	max_left=32	max_left_minus=32	max_left_plus=31	max_min_left=16	max_min_left_minus=15	max_min_left_plus=16	max_min_right=16	max_min_right_minus=15	max_min_right_plus=16	max_right=32	max_right_minus=32	max_right_plus=32	neg_log10_pos_hash_p_value=0.6	pos_hash_score=40	side_1_annotate_key=gene	side_1_overlap=2	side_1_redundant=0	side_2_annotate_key=gene	side_2_overlap=0	side_2_redundant=0	total_non_overlap_reads=84
#JC	10003		REL606	474187	1	REL606	474366	-1	0	alignment_overlap=1	coverage_minus=33	coverage_plus=26	flanking_left=35	flanking_right=35	key=REL606__474187__1__REL606__474367__-1__1____35__35__0__0	max_left=33	max_left_minus=29	max_left_plus=33	max_min_left=16	max_min_left_minus=15	max_min_left_plus=16	max_min_right=17	max_min_right_minus=12	max_min_right_plus=17	max_right=33	max_right_minus=33	max_right_plus=32	neg_log10_pos_hash_p_value=1.0	pos_hash_score=36	side_1_annotate_key=gene	side_1_overlap=1	side_1_redundant=0	side_2_annotate_key=gene	side_2_overlap=0	side_2_redundant=0	total_non_overlap_reads=59
#MC	10001	long deletion, possibly cross contamination to give noise in region	REL606	2032206	2055495	13	58	left_inside_cov=23	left_outside_cov=27	right_inside_cov=25	right_outside_cov=28
#JC	10002		REL606	16728	-1	REL606	2713428	1	0	alignment_overlap=5	coverage_minus=21	coverage_plus=32	flanking_left=35	flanking_right=35	key=REL606__16730__-1__REL606__2713425__1__5____35__35__1__0	max_left=28	max_left_minus=28	max_left_plus=28	max_min_left=14	max_min_left_minus=14	max_min_left_plus=13	max_min_right=15	max_min_right_minus=13	max_min_right_plus=15	max_right=29	max_right_minus=25	max_right_plus=29	neg_log10_pos_hash_p_value=0.9	pos_hash_score=33	side_1_annotate_key=repeat	side_1_overlap=3	side_1_redundant=1	side_2_annotate_key=gene	side_2_overlap=2	side_2_redundant=0	total_non_overlap_reads=53
