#Expects to be run with working directory in "summary" 

library(ggplot2)
library(scales)
library(dplyr)
library(RColorBrewer)

for (on_file in c("del", "dup")) {

	X = read.table(paste0("gd2cov.", on_file, ".tab"), header=T)

	theme_set(theme_bw(base_size = 24))
	line_thickness = 0.8
	theme_update(panel.border=element_rect(color="black", fill=NA, size=1), legend.key=element_rect(color=NA, fill=NA))

	#Y = subset(X, time <= 1000)
	#Y = subset(Y, population == "Ara+1")
	Y=subset(X, coverage>0)
	Y$time = factor(Y$time)
	the.width = (Y$position[2] - Y$position[1])
	Y$position = Y$position + the.width / 2

	Z = Y %>% group_by(position) %>% summarise(coverage=n())

	Z$position = as.numeric(Z$position)
	Z$coverage = as.numeric(Z$coverage)

	p = ggplot(data = Z, aes(x = position, y = coverage)) 
	#p + geom_bar(position = "stack", stat="identity") + coord_trans(y = "sqrt") + scale_fill_brewer(palette="Set1")
	p + geom_bar(colour="black", position = "stack", stat="identity", width=the.width) + coord_trans(y = "sqrt") + scale_y_continuous(limits=c(0, 256), breaks=c(1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256)) + scale_x_continuous(breaks=(1:9)*500000) + scale_fill_manual(values=c("black", "black"))
	ggsave(file.path(paste("all_", on_file,".pdf", sep="")), width=12, height=5) 

}
