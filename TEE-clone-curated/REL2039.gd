#=GENOME_DIFF 1.0
#=AUTHOR	Deatherage, Daniel
#=REFSEQ	BarrickLab-Private:genomes/reference/REL606.6.gbk
#=READSEQ	BarrickLab-Private:genomes/msu_rtsf/43033AAXX/fastq_sanger/43033AAXX_4_1_pf_REL2039.fastq.gz
#=TREATMENT	32C
#=TIME	2000
#=POPULATION	-2
DEL	677	215,10	REL606	429505	1350
SNP	682	221	REL606	651290	A
SNP	683	222	REL606	1329516	T
AMP	681	2	REL606	1733290	8	2
MOB	679	8,9	REL606	1803859	IS1	1	8
SNP	684	256	REL606	2193779	T
SNP	685	314	REL606	3242832	T
SNP	686	334	REL606	3484091	G
SNP	687	395	REL606	3762741	T
INS	688	401	REL606	3875632	T
DEL	678	402,4	REL606	3894997	6934	mediated=IS150
MOB	680	6,5	REL606	4524522	IS186	1	6
SNP	689	463	REL606	4616438	G
DEL	.	10001	REL606	2842054	220
#MC	10001		REL606	2842027	2842283	59	59	left_inside_cov=27	left_outside_cov=29	right_inside_cov=26	right_outside_cov=29
NOTE	10002	.	MC10001 is removal of 1 full repeat element, plus middle of another.
MOB	.	10003	REL606	1270660	IS150	-1	4
NOTE	10004	.	jc10002 and jc10003 correspond to insertions on either side of an is element. JC10003 is listed as being in ldrD, but blast reveals it to correspond to bases 1270629-1270661 of ldrc, and the same posisition as the opposite end of the is150 element seen in JC10002
#JC	10002		REL606	588495	1	REL606	1270660	1	0	alignment_overlap=2	coverage_minus=61	coverage_plus=85	flanking_left=34	flanking_right=34	key=REL606__588495__1__REL606__1270658__1__2____34__34__1__0	max_left=31	max_left_minus=31	max_left_plus=30	max_min_left=15	max_min_left_minus=15	max_min_left_plus=15	max_min_right=16	max_min_right_minus=16	max_min_right_plus=16	max_right=31	max_right_minus=31	max_right_plus=31	neg_log10_pos_hash_p_value=0.2	pos_hash_score=51	side_1_annotate_key=repeat	side_1_overlap=2	side_1_redundant=1	side_2_annotate_key=gene	side_2_overlap=0	side_2_redundant=0	total_non_overlap_reads=146
#JC	10003		REL606	590471	-1	REL606	3630716	-1	0	alignment_overlap=2	coverage_minus=30	coverage_plus=58	flanking_left=34	flanking_right=34	key=REL606__590473__-1__REL606__3630716__-1__2____34__34__1__1	max_left=31	max_left_minus=31	max_left_plus=31	max_min_left=14	max_min_left_minus=12	max_min_left_plus=14	max_min_right=16	max_min_right_minus=13	max_min_right_plus=16	max_right=31	max_right_minus=31	max_right_plus=31	neg_log10_pos_hash_p_value=0.7	pos_hash_score=41	side_1_annotate_key=repeat	side_1_overlap=0	side_1_redundant=1	side_2_annotate_key=repeat	side_2_overlap=2	side_2_redundant=1	total_non_overlap_reads=88
