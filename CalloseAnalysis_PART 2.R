#
# Script for PD callose analysis, updated t 12/05/2021

# In this script there are 4 parts:

# 1. packages that you need to run this script
# 2. colour palette set up that you need if you want to make plots with the colours that I like
# 3. Matt's method of summarising and plotting the data
# 4. Annalisa's method to plot the data following Matt's analysis

# Run part 1 and 2, then copy your data and proceed with part 3 and 4


#========================================== PART 1
#-----------------------------------  packages needed

library("ggplot2")
library("reshape2")
library("RColorBrewer")
library('ggsignif')
library('tidyverse')
library("svglite")
library(gridExtra)
library(grid)




#========================================== PART 2
#-----------------------------------  set colour palette

my_pal_div <- RColorBrewer::brewer.pal(11, "BrBG")[2:11]
my_pal_quant_1 <- RColorBrewer::brewer.pal(9, "Oranges")
my_pal_quant_2 <- RColorBrewer::brewer.pal(9, "Blues")
my_pal_gray <- RColorBrewer::brewer.pal(9, "Greys")
okabe_pal <- c("#E69F00","#56B4E9","#009E73", "#F0E442", "#0072B2", "#D55E00","#CC79A7")

n <- max(length(my_pal_div), length(my_pal_quant_1), length(my_pal_quant_2), length(my_pal_gray), length(okabe_pal))

length(my_pal_div) <- n
length(my_pal_quant_1) <- n
length(my_pal_quant_2) <- n
length(my_pal_gray) <- n
length(okabe_pal) <- n

my_pal_gray_d <- data.frame(my_pal_gray)
my_pal_quant_1_d <- data.frame(my_pal_quant_1)
my_pal_quant_2_d <- data.frame(my_pal_quant_2)
my_pal_div_d <- data.frame(my_pal_div)
okabe_pal_d <- data.frame(okabe_pal)

my_col_set <- (0)
my_col_set <- cbind(my_pal_gray_d, my_pal_quant_1_d)
my_col_set <- cbind(my_col_set, my_pal_quant_2_d)
my_col_set <- cbind(my_col_set, okabe_pal_d)
my_col_set <- cbind(my_col_set, my_pal_div_d)

my_col_set_df <- data.frame(my_col_set)

order <- c(1:10)
my_col_set_df1 <- cbind(my_col_set_df, order)
my_col_set_df1

long_color <- melt(my_col_set_df1,
                   id.vars = "order",
                   variable.name = "palette",
                   value.name = "color")

my_colors_plot <- ggplot(long_color, aes(x = palette, y = order, fill = color)) +
  geom_tile(aes(width=0.93, height=0.95)) +
  scale_fill_identity() +
  scale_y_continuous(breaks=c(1:n)) +
  theme_light()+
  geom_label(aes(label=color),colour = "black", fill= "white", fontface = "bold", size = 4)

my_colors_plot




#========================================== PART 3
#-----------------------------------  Matt's analysis and plotting



#------------------  !!  MANUALLY COPY YOUR DATA FROM EXCEL BEFORE RUNNING THIS !!

#this line takes your data from the clipboard and loads them into R
data<-read.table("clipboard",header=T,sep = "\t")
#this line shows you the first rows of your data
head(data)


#this is how Matt set up the analysis:
#takes your data
numeric <- data %>% 
#groups them by the name column
    #WARNING:
    #Make sure the name column is what you want your data to be grouped for:
    #do you want your data to be grouped by image? 
    #By slice of z-stack?
    #By leaf (did you take more image per each leaf and you want to group your data for each leaf and only compare across leaves?)
    #It is important that you adjust the column name or the grouping variable to obtain what you want
  group_by(Name) %>% 
#this line summarises all the other columns listed while grouping them by the variable you specified above
  summarise(num_pd=n(), mean_avinten=mean(Mean), mean_intden=mean(IntDen), mean_area=mean(Area), image_intden=sum(IntDen), area_pd=sum(Area))
#see first 10 rows of the resulting table
head(numeric, 10)
numeric <- data.frame(numeric)

#attach the resulting data to the columns with the information that were contained in the original data, so you don't lose track of anything
data_sum<-inner_join(numeric, data, by = c("Name")) %>% distinct(Name,.keep_all = T)
head(data_sum)
tail(data_sum)

#Matt's Anova for stat analysis
num_pdsig<-if(anova(lm(num_pd~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}
mean_avintensig<-if(anova(lm(mean_avinten~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}
mean_intdensig<-if(anova(lm(mean_intden~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}
mean_areasig<-if(anova(lm(mean_area~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}
image_intdensig<-if(anova(lm(image_intden~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}
area_pdsig<-if(anova(lm(area_pd~Geno, data_sum))[5][1,1]<0.05){"SIG"}else{"NOT SIG"}

#Matt's plots - please note all these metrics are either per image or per zslice or per zstack or per leaf... it depends on what you put in the name column or on what grouoing variable you chose!!

#numer of detected particles in each image/zslice/zstack: this is a controversial metric, be careful
num_pd<-ggplot(data_sum, aes(x=Geno, y=num_pd,))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Number of detected callose deposits per image")+ggtitle(num_pdsig)

#mean of avearage PD intesity in an image/zslice/zstack: takes pixels intensity value of a PD, calculates the average intesity of pixels in that one PD, makes mean of the average intensities of all PD in each image/zslice/zstack. So this is the mean of the mean intensities
mean_avinten<-ggplot(data_sum, aes(x=Geno, y=mean_avinten))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Average depositintensity of aniline blue/deposit (AU)")+ggtitle(mean_avintensig)

#average PD intensity: takes pixels intensity values of each Pd and sums them up to obtain total intensity of one PD, then makes average of those PD values across one image/zslice/zstack. So this is the mean in the total intensity
#This is the one I used (Annalisa)
mean_intden<-ggplot(data_sum, aes(x=Geno, y=mean_intden))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Total deposit intensity of aniline blue/deposit (AU)")+ggtitle(mean_intdensig)

#mean aread of detected particles in an image/zslice/zstack
mean_area<-ggplot(data_sum, aes(x=Geno, y=mean_area))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Mean callose deposit size (microns^2)")+ggtitle(mean_areasig)

#total intensity of aniline blue signal in the detected particles of an image/zslice/zstack
image_intden<-ggplot(data_sum, aes(x=Geno, y=image_intden))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Total intensity of aniline blue (AU)")+ggtitle(image_intdensig)

#total area occupied by the detected particles of an image/zslice/zstack
area_pd<-ggplot(data_sum, aes(x=Geno, y=area_pd))+geom_boxplot()+xlab("Genotype")+theme_bw()+ guides(shape=FALSE)+geom_jitter(width=0.1, alpha=.4)+ylab("Total area of callose deposits (microns^2)")+ggtitle(area_pdsig)

#this arranges the plots above in a grid
grid.arrange(num_pd,mean_avinten,mean_intden,mean_area,image_intden,area_pd, ncol=2)



#========================================== PART 4
#-----------------------------------  My plots (Annalisa)


#The data elaborated with Matt's method are plotted singlularly instead of in a grid
#I used wilcoxon rank sum test as analysis
#I save the plots in svg png and pdf formats


#============= TO MANUALLY SET BEFORE RUNNING

#set the name of your experiment
EXP <- 'Effector PD callose' #insert your exp title between ''

#set your working directory (where do you want your plots to be saved)
setwd("C:/Users/bellanda/Desktop/xiaokun_troubleshoot") #insert your path between the ''

#For each plot you need to manually type 
  #The labels of the x axis and the comparisons you want to make
  #The label of the y axis depending on your grouping variable you chose
  #you may need to adjust the length of the y axis and position of the stat results 



#============= PLOTS

#number of pd plot
num_pd_wil <- ggplot(data_sum, mapping=aes(x=Geno, y=num_pd, color=Geno))+
  geom_boxplot(data_sum, mapping=aes(x=Geno, y=num_pd, color=Geno), outlier.shape = NA)+
  scale_color_manual(values = c(okabe_pal[1], okabe_pal[2], my_pal_gray[5]))+
  scale_fill_manual(values = c(okabe_pal[1], okabe_pal[2], my_pal_gray[5]))+
  xlab("Genotype")+
  theme_bw(base_size=20)+ 
  guides(shape=FALSE)+
  geom_jitter(width=0.1, alpha=.4)+
  ylab("n callose deposits") +
  #set the labels that you want here
  #scale_x_discrete(labels=c("30-23_1-2",'30-23_2-1','GFP')) +
  ggtitle("Number of Callose deposits per image")+
  theme(plot.title = element_text(hjust = 0.4))+
  coord_cartesian(ylim=c(0,1750)) +
  theme(legend.position = "none")+
  #set the comparisosns that you want to make here
  geom_signif(comparisons =list(c("30-23_1-2", "GFP")),
              step_increase = 0.1, map_signif_level=c("***"=0.001, "**"=0.01, "*"=0.05, "NS"<0.05), test = 'wilcox.test', color='black',size = 1, y_position = 1250, textsize = 7) + #default is to wilcoxon test
geom_signif(comparisons =list(c("30-23_2-1", "GFP")),
            step_increase = 0.1, map_signif_level=c("***"=0.001, "**"=0.01, "*"=0.05, "NS"<0.05), test = 'wilcox.test', color='black',size = 1, y_position = 1550, textsize = 7) #default is to wilcoxon test


num_pd_wil

#saves PNG version for easy acces
ggsave(paste(EXP, "number deposits_wilcox", ".png"), num_pd_wil, width = 8, height = 8, dpi = 450, device = 'png')

#saves svg version for easy editing, this is correctly visualized only in illustrator while in inkscape looses the 
#strokes and looses size of the legend. To insert in thesis, open in illustrator, save and save as pdf
svglite(file=paste(EXP, "number deposits_wilcox", ".svg"),width=8,height=8)
figure <- num_pd_wil
print(figure)
dev.off()

#saves pdf version for easy insertion in thesis. Problem with this pdf is that the data point are rendered as squares in 
#illustrator, however this renders correctly in inkscape
ggsave(paste(EXP,"number deposits_wilcox", ".pdf"), num_pd_wil, width = 8, height = 8, dpi = 450)






#average intensity of callose deposits plot
int_pd_wil <- ggplot(data_sum, mapping=aes(x=Geno, y=mean_intden, color=Geno))+
  geom_boxplot(data_sum, mapping=aes(x=Geno, y=mean_intden, color=Geno))+
  scale_color_manual(values = c(okabe_pal[1], okabe_pal[2], my_pal_gray[5]))+
  scale_fill_manual(values = c(okabe_pal[1], okabe_pal[2], my_pal_gray[5]))+
  xlab("Genotype")+
  theme_bw(base_size=20)+ 
  guides(shape=FALSE)+
  geom_jitter(width=0.1, alpha=.4)+
  ylab("intensity [AU]") +
  #set the labels that you want here
  scale_x_discrete(labels=c("30-23_1-2",'30-23_2-1','GFP')) +
  ggtitle("Intensity of aniline blue per deposit")+
  theme(plot.title = element_text(hjust = 0.4))+
  coord_cartesian(ylim=c(500,12800)) +
  theme(legend.position = "none")+
  #set the comparisosns that you want to make here
  geom_signif(comparisons =list(c("30-23_1-2", "GFP")),
              step_increase = 0.1, map_signif_level=c("***"=0.001, "**"=0.01, "*"=0.05, "NS"<0.05), test = 'wilcox.test', color='black',size = 1, y_position = 9000, textsize = 7) + #default is to wilcoxon test
  geom_signif(comparisons =list(c("30-23_2-1", "GFP")),
              step_increase = 0.1, map_signif_level=c("***"=0.001, "**"=0.01, "*"=0.05, "NS"<0.05), test = 'wilcox.test', color='black',size = 1, y_position = 10850, textsize = 7) #default is to wilcoxon test

int_pd_wil

#saves PNG version for easy acces
ggsave(paste(EXP, "intensity deposits_wilcox", ".png"), int_pd_wil, width = 8, height = 8, dpi = 450, device = 'png')

#saves svg version for easy editing, this is correctly visualized only in illustrator while in inkscape looses the 
#strokes and looses size of the legend. To insert in thesis, open in illustrator, save and save as pdf
svglite(file=paste(EXP, "intensity deposits_wilcox", ".svg"),width=8,height=8)
figure <- int_pd_wil
print(figure)
dev.off()

#saves pdf version for easy insertion in thesis. Problem with this pdf is that the data point are rendered as squares in 
#illustrator, however this renders correctly in inkscape
ggsave(paste(EXP,"intensity deposits_wilcox", ".pdf"), int_pd_wil, width = 8, height = 8, dpi = 450)
