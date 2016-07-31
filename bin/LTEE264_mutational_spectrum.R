#Expects to be run with working directory in "summary" 
library(ggplot2)
library(tidyr)
library(dplyr)

## load data
## X is the full table

X = read.csv("spectrum_counts.csv")

X$population = X$sample

#don't count inversions
X$total = X$total - X$inversion

#large substitutions are all deletions!
X$large_deletion = X$large_deletion + X$large_substitution
X$large_substitution = 0

X$fr_base_substitution = X$base_substitution / X$total
X$fr_small_indel = X$small_indel / X$total
X$fr_large_deletion = X$large_deletion / X$total
X$fr_large_amplification = X$large_amplification / X$total
X$fr_mobile_element_insertion = X$mobile_element_insertion / X$total

## Recategorize into four types of SNPs
## synonymous = synonymous
## nonsynonymous = nonsynymous + nonsense
## intergenic = intergenic
## other = noncoding (RNA) + pseudogene

X$fr_synonymous = X$base_substitution.synonymous / X$total

X$base_substitution.nonsynonymous = X$base_substitution.nonsynonymous + X$base_substitution.nonsense
X$base_substitution.nonsense = 0
X$fr_nonsynonymous = X$base_substitution.nonsynonymous / X$total

X$fr_intergenic = X$base_substitution.intergenic  / X$total

X$base_substitution.other = X$base_substitution.pseudogene + X$base_substitution.noncoding
X$base_substitution.pseudogene = 0
X$base_substitution.noncoding = 0
X$fr_other = X$base_substitution.other  / X$total

X$check_total = X$fr_base_substitution + X$fr_small_indel + X$fr_large_deletion + X$fr_large_amplification + X$fr_mobile_element_insertion

X$check_total = X$fr_synonymous + X$fr_nonsynonymous + X$fr_intergenic + X$fr_other + X$fr_small_indel + X$fr_large_deletion + X$fr_large_amplification + X$fr_mobile_element_insertion

X$time = 0;
X$cumulative = FALSE;
X$population = c("")
for (i in 1:nrow(X)) {
  
  if (grepl(".to.", X$file[i])) {
    
    X$cumulative[i] = TRUE;
    
  } else {
    X$cumulative[i] = FALSE;
  }
  
  file_name = as.character(X$file[i])
  X$time[i] = sub("^.+?\\.(\\d+)gen\\..+", "\\1", file_name , perl=T)
  X$population[i] = sub("^(.+?)\\..+", "\\1", file_name , perl=T)
  
}


X$population = as.factor(X$population)
X$time = as.numeric(X$time)

## save the full table
full_table = X


order_of_pops = c("Ara-5", "Ara-6", "Ara+2", "Ara+4", "Ara+5", "Ara+1", "Ara-2", "Ara-4", "Ara+3", "Ara-3", "Ara+6", "Ara-1")
X = full_table %>% filter(population != "Ara-5-no-alien")
##Reorder based on mutator type
X$population = factor(X$population, levels = order_of_pops)


#plot defaults

plot.width = 7
plot.height = 5
theme_set(theme_bw(base_size = 24))
line_thickness = 0.8
theme_update(panel.border=element_rect(color="black", fill=NA, size=1), legend.key=element_rect(color=NA, fill=NA))

##First graph just the ones at each point

unrolled = X %>% 
  select(population, time, cumulative, fr_synonymous, fr_nonsynonymous, fr_intergenic, fr_other, fr_small_indel, fr_large_deletion, fr_large_amplification, fr_mobile_element_insertion) %>%
  gather(mutation.type, count, fr_synonymous:fr_mobile_element_insertion)

unrolled$population = factor(unrolled$population, levels = order_of_pops)
unrolled$time = factor(unrolled$time)

instantaneous = subset(unrolled, cumulative==FALSE)

p = ggplot(instantaneous , aes(x=time,y=count, fill=mutation.type))
p + geom_bar(stat="identity") + facet_wrap(~population, nrow=2) + scale_y_continuous(limits=c(0,1))

ggsave("instantaneous_spectrum.pdf", height=6, width=24)

## Total mutations over all populations and all generations (including mutators)

total_at_50K = full_table %>% filter( (cumulative==TRUE) & (time==50000)) %>% filter(population != "Ara-5-no-alien")

total_at_50K = total_at_50K %>% 
  select(population, time, base_substitution, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution:mobile_element_insertion) %>% 
  group_by(mutation.type, time) %>% 
  summarize(count = sum(count))


## Nonmutator spectrum sum

unrolled_counts = full_table %>% 
  select(population, time, cumulative, base_substitution.synonymous, base_substitution.nonsynonymous, base_substitution.intergenic, base_substitution.other, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution.synonymous:mobile_element_insertion)

### Stats for 5 major mutation categories whether spectrum changed later
unrolled_counts = full_table %>% 
  select(population, time, cumulative, base_substitution, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution:mobile_element_insertion)

instantaneous_counts = subset(unrolled_counts, cumulative==TRUE)

non_mutators = instantaneous_counts %>% 
  filter( ((population=="Ara+1") & (time<= 2000)) |
            ((population=="Ara+2") & (time<=50000)) |
            ((population=="Ara+3") & (time<= 2000)) |
            ((population=="Ara+4") & (time<=50000)) |
            ((population=="Ara+5") & (time<=50000)) |
            ((population=="Ara+6") & (time<= 5000)) |
            ((population=="Ara-1") & (time<=20000)) |
            ((population=="Ara-2") & (time<= 2000)) |
            ((population=="Ara-3") & (time<=30000)) |
            ((population=="Ara-4") & (time<= 5000)) |
            ((population=="Ara-5-no-alien") & (time<=50000)) |
            ((population=="Ara-6") & (time<=50000)) 
  ) %>% group_by(mutation.type, time) %>% summarize(count = sum(count))

p = ggplot(non_mutators, aes(x=time,y=count, fill=mutation.type))
p + geom_bar(stat="identity")

non_mutators_0.5K = subset(non_mutators, time=="500")
non_mutators_1K = subset(non_mutators, time=="1000")
non_mutators_2K = subset(non_mutators, time=="2000")
non_mutators_5K = subset(non_mutators, time=="5000")
non_mutators_10K = subset(non_mutators, time=="10000")
non_mutators_40K = subset(non_mutators, time=="40000")
non_mutators_50K = subset(non_mutators, time=="50000")


non_mutators_40K_to_50K = non_mutators_50K
non_mutators_40K_to_50K$count = non_mutators_50K$count - non_mutators_40K$count


#chisq.test(non_mutators_10K$count, non_mutators_40K_to_50K$count, correct=T)
fisher.test(matrix(c(non_mutators_10K$count, non_mutators_40K_to_50K$count), ncol=2))

fisher.test(matrix(c(non_mutators_5K$count, non_mutators_40K_to_50K$count), ncol=2))

fisher.test(matrix(c(non_mutators_2K$count, non_mutators_40K_to_50K$count), ncol=2))

fisher.test(matrix(c(non_mutators_1K$count, non_mutators_40K_to_50K$count), ncol=2))

fisher.test(matrix(c(non_mutators_0.5K$count, non_mutators_40K_to_50K$count), ncol=2))

## Mutations in all nonmutator genomes through 50K

unrolled_counts = full_table %>% 
  select(population, time, cumulative, base_substitution.synonymous, base_substitution.nonsynonymous, base_substitution.intergenic, base_substitution.other, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution.synonymous:mobile_element_insertion)

instantaneous_counts = subset(unrolled_counts, cumulative==TRUE)

non_mutators_cumulative = instantaneous_counts %>% 
  filter( ((population=="Ara+1") & (time<= 2000)) |
            ((population=="Ara+2") & (time<=50000)) |
            ((population=="Ara+3") & (time<= 2000)) |
            ((population=="Ara+4") & (time<=50000)) |
            ((population=="Ara+5") & (time<=50000)) |
            ((population=="Ara+6") & (time<= 5000)) |
            ((population=="Ara-1") & (time<=20000)) |
            ((population=="Ara-2") & (time<= 2000)) |
            ((population=="Ara-3") & (time<=30000)) |
            ((population=="Ara-4") & (time<= 5000)) |
            ((population=="Ara-5-no-alien") & (time<=50000)) |
            ((population=="Ara-6") & (time<=50000)) 
  ) 

non_mutator_summary = non_mutators_cumulative %>% filter(time==50000) %>% group_by(mutation.type) %>% summarize(count = sum(count))
non_mutator_summary$fraction = non_mutator_summary$count / sum(non_mutator_summary$count)
non_mutator_summary$fraction

##Then graph the instantaneous uniques including the latest generations

unrolled_counts = full_table %>% 
  select(population, time, cumulative, base_substitution.synonymous, base_substitution.nonsynonymous, base_substitution.intergenic, base_substitution.other, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution.synonymous:mobile_element_insertion)

instantaneous_counts = subset(unrolled_counts, cumulative==FALSE)

non_mutators = instantaneous_counts %>% 
  filter( ((population=="Ara+1") & (time<= 2000)) |
          ((population=="Ara+2") & (time<=50000)) |
          ((population=="Ara+3") & (time<= 2000)) |
          ((population=="Ara+4") & (time<=50000)) |
          ((population=="Ara+5") & (time<=50000)) |
          ((population=="Ara+6") & (time<= 5000)) |
          ((population=="Ara-1") & (time<=20000)) |
          ((population=="Ara-2") & (time<= 2000)) |
          ((population=="Ara-3") & (time<=30000)) |
          ((population=="Ara-4") & (time<= 5000)) |
          ((population=="Ara-5-no-alien") & (time<=50000)) |
          ((population=="Ara-6") & (time<=50000)) 
        )  

non_mutators = non_mutators %>% 
  group_by(mutation.type, time) %>% summarize(count = sum(count))

non_mutator_totals = non_mutators %>% group_by(time) %>% summarize(total = sum(count))

non_mutators = non_mutators %>% left_join(non_mutator_totals, by="time")

non_mutators$fraction = non_mutators$count / non_mutators$total

non_mutators$time = factor(non_mutators$time)
p = ggplot(non_mutators, aes(x=time,y=fraction, fill=mutation.type))
p + geom_bar(stat="identity")

ggsave("nonmutators_spectrum.pdf", height=6, width=8)

## These are the TOTAL mutation counts in each column
subset(non_mutators, mutation.type=="base_substitution.synonymous")$total



## MA counts
MA.X = read.csv("count.MAE.masked.no_IS_adjacent.csv")
MA.X$population = MA.X$sample

MA.X$large_deletion = MA.X$large_deletion + MA.X$large_substitution
MA.X$large_substitution = 0

MA.unrolled_counts = MA.X %>% 
  select(population, time, base_substitution, small_indel, large_deletion, large_amplification, mobile_element_insertion) %>%
  gather(mutation.type, count, base_substitution:mobile_element_insertion)

MA.total.counts = MA.unrolled_counts  %>% group_by(mutation.type, time) %>% summarize(count = sum(count))


##comparison of ALL nonmutator uniques to the MA data

LTEE.nonmutator.total.unrolled_counts = subset(unrolled_counts, (cumulative==TRUE) & (time == "50000"))


LTEE.nonmutator.total.unrolled_counts = LTEE.nonmutator.total.unrolled_counts %>%
  filter( ((population=="Ara+1") & (time<= 2000)) |
            ((population=="Ara+2") & (time<=50000)) |
            ((population=="Ara+3") & (time<= 2000)) |
            ((population=="Ara+4") & (time<=50000)) |
            ((population=="Ara+5") & (time<=50000)) |
            ((population=="Ara+6") & (time<= 5000)) |
            ((population=="Ara-1") & (time<=20000)) |
            ((population=="Ara-2") & (time<= 2000)) |
            ((population=="Ara-3") & (time<=30000)) |
            ((population=="Ara-4") & (time<= 5000)) |
            ((population=="Ara-5-no-alien") & (time<=50000)) |
            ((population=="Ara-6") & (time<=50000)) 
  ) %>% group_by(mutation.type, time) %>% summarize(count = sum(count))

LTEE.nonmutator.total.unrolled_counts$fraction = LTEE.nonmutator.total.unrolled_counts$count / sum(LTEE.nonmutator.total.unrolled_counts$count)

fisher.test(matrix(c(MA.total.counts$count, non_mutators_10K$count), ncol=2))


## Calculating the distribution of the different base substitution categories

unrolled_bs_counts = X %>% 
  select(population, time, cumulative, base_substitution.synonymous, base_substitution.nonsynonymous, base_substitution.nonsense, base_substitution.noncoding, base_substitution.intergenic, base_substitution.pseudogene) %>%
  gather(mutation.type, count, base_substitution.synonymous:base_substitution.pseudogene)

non_mutators_bs = unrolled_bs_counts %>% 
  filter( ((population=="Ara+1") & (time<= 2000)) |
            ((population=="Ara+2") & (time<=50000)) |
            ((population=="Ara+3") & (time<= 2000)) |
            ((population=="Ara+4") & (time<=50000)) |
            ((population=="Ara+5") & (time<=50000)) |
            ((population=="Ara+6") & (time<= 5000)) |
            ((population=="Ara-1") & (time<=20000)) |
            ((population=="Ara-2") & (time<= 2000)) |
            ((population=="Ara-3") & (time<=30000)) |
            ((population=="Ara-4") & (time<= 5000)) |
            ((population=="Ara-5-no-alien") & (time<=50000)) |
            ((population=="Ara-6") & (time<=50000)) 
  )   %>% group_by(mutation.type, time) %>% summarize(count = sum(count))

LTEE.bs.nonmutator.total.unrolled_counts = subset(non_mutators_bs, (time == "50000"))

LTEE.bs.nonmutator.total.unrolled_counts$fraction = LTEE.bs.nonmutator.total.unrolled_counts$count / sum(LTEE.bs.nonmutator.total.unrolled_counts$count)

