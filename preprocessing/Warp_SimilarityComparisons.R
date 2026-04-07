
#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script generates plots for similarity metrics between 
# individual images at different stages of the anatomical 
# alignment process and the MDT (template) as in 
# "Quality Assurance Strategies for Brain State
# Characterization by MEMRI" 
# by Uselman TW, Jacobs RE, and Bearer EL (2026)md
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# Load/Install required libraries.
libs = c("tidyverse","ggplot2","nlme")
lL = length(libs)
vers = c("4.1.0","4.1.0","3.1.0") # minimum R required is 4.1.0
lV = length(vers)
minvers = numeric_version(max(package_version(vers)))
if (getRversion() < minvers) {stop(paste0("ERROR: minimum R version must be ",minvers))} 
for (i in 1:length(libs)) {
  if (lL != lV) {stop("be sure correct minvers are included libs")}
  if (!requireNamespace(libs[i], quietly = TRUE)) {install.packages(libs[i])}
}

#######################
# Set Local Directory #
#######################
wdir = "SET-LOCAL-DIRECTORY"
#######################
setwd(wdir)


# Set up color pallete
ColPal = data.frame(
  ColorName = c("Blue","Vermillion","SkyBlue","Yellow"),
  Red = c(0,213,86,240)/255,
  Green = c(114,94,180,228)/255,
  Blue = c(178,0,223,66)/255
) %>% mutate(
  RGB = rgb(red=Red,green=Green,blue=Blue,alpha=1)
)

# For extracting numbers using regular expressions

dat_jac = read.csv("./03_Similarity_Analysis/JacSim-MDT.csv", header = T) %>% as.data.frame() %>%
  mutate(
    # Extract numbers from Image Name using regular expressions
    ID = factor(unlist(regmatches(Image, gregexpr("[0-9]+", Image)))),
    Alignment = factor(
      ifelse(grepl("wr",Image),"Nonlinear","Linear"),
      levels = c("Linear","Nonlinear")
    ),
    MnII = factor(
      ifelse(grepl("pre.",Image),"PreMn","PostMn"),
      levels = c("PreMn","PostMn")
    )
  )
dat_nmi = read.csv("./03_Similarity_Analysis/NMI-MDT.csv", header = T) %>% as.data.frame() %>%
  mutate(
    # Extract numbers from Image Name using regular expressions
    ID = factor(unlist(regmatches(Image, gregexpr("[0-9]+", Image)))),
    Alignment = factor(
      ifelse(grepl("wr",Image),"Nonlinear","Linear"),
      levels = c("Linear","Nonlinear")
    ),
    MnII = factor(
      ifelse(grepl("pre.",Image),"PreMn","PostMn"),
      levels = c("PreMn","PostMn")
    )
  )

data = cbind.data.frame(dat_nmi %>% select(Image,THR,NBINS,ID,Alignment,MnII,NMI), dat_jac %>% select(JSI))

data_sum = data %>% 
  group_by(Alignment,MnII) %>% 
  reframe(Avg.JSI = mean(JSI),
          Avg.NMI = mean(NMI),
          SD.JSI  = sd(JSI),
          SD.NMI  = sd(NMI),
          SE.JSI  = SD.JSI / sqrt(n()),
          SE.NMI  = SD.NMI / sqrt(n()),
          COV.JSI = SD.JSI / Avg.JSI,
          COV.NMI = SD.NMI / Avg.NMI
          ) %>%
  ungroup()

# JSI
p = ggplot(data_sum,
           aes(x = MnII, y=Avg.JSI, color=Alignment))
p = p + geom_point(position=position_dodge(0.5), alpha=1, size=1)
p = p + geom_errorbar(aes(ymin = Avg.JSI-SE.JSI, ymax = Avg.JSI+SE.JSI),
                      position=position_dodge(0.5), alpha=1, linewidth=0.8, width=0.5)
p = p + scale_color_manual(values=ColPal$RGB)
p = p + scale_y_continuous(limits = c(0,1), breaks = seq(0,1,0.25),
                           expand = c(0,0,0,0))
p = p + theme_classic()
p = p + labs(x="",y="JSI")
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=8,family="sans",angle=30,hjust=0.7,vjust=0.7)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.05, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_F1_JSI_v2.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.55,units="in",dpi=300)

lme.jsi = lme(JSI ~ Alignment * MnII, random = (~1|Image), data)
anova(lme.jsi, type = "marginal")

car::leveneTest(JSI ~ Alignment, data)
car::leveneTest(JSI ~ MnII, data)

# NMI
p = ggplot(data_sum,
           aes(x = MnII, y=Avg.NMI, color=Alignment))
p = p + geom_point(position=position_dodge(0.5), alpha=1, size=1)
p = p + geom_errorbar(aes(ymin = Avg.NMI-SE.NMI, ymax = Avg.NMI+SE.NMI),
                      position=position_dodge(0.5), alpha=1, linewidth=0.8, width=0.5)
p = p + scale_color_manual(values=ColPal$RGB)
p = p + scale_y_continuous(limits = c(0,1), breaks = seq(0,1,0.25),
                           expand = c(0,0,0,0))
p = p + theme_classic()
p = p + labs(x="",y="NMI")
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=8,family="sans",angle=30,hjust=0.7,vjust=0.7)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.05, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_F2_NMI_v2.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.55,units="in",dpi=300)

lme.nmi = lme(NMI ~ Alignment * MnII, random = (~1|Image), data)
anova(lme.nmi, type = "marginal")

car::leveneTest(NMI ~ Alignment, data)
car::leveneTest(NMI ~ MnII, data)

dat_sum2 = data.frame(
  Alignment = rep(data_sum$Alignment,2),
  MnII = rep(data_sum$MnII,2),
  Index = factor(c(rep("JSI",4),rep("NMI",4)),levels=c("JSI","NMI")),
  Measure = c(data_sum$Avg.JSI,data_sum$Avg.NMI),
  M.SEM = c(data_sum$SE.JSI,data_sum$SE.NMI),
  M.SD  = c(data_sum$SD.JSI,data_sum$SD.NMI)
)


p = ggplot(dat_sum2,
           aes(x = MnII, y=Measure, fill=interaction(Index,Alignment)))
p = p + geom_bar(stat="identity",color=NA,
                 position=position_dodge(0.8),width=0.75, linewidth=1)
p = p + geom_errorbar(aes(ymin = Measure - M.SD, ymax = Measure + M.SD,
                          group =interaction(Index,Alignment)),
                      position=position_dodge(0.8),
                      width = 0.5, linewidth = 1, color = "black")
p = p + scale_fill_manual(values=ColPal$RGB)
p = p + scale_x_discrete(expand = c(0,0.45,0,0.45))
p = p + scale_y_continuous(limits = c(0,1), breaks = seq(0,1,0.25),
                           expand = c(0,0,0,0))
p = p + facet_grid(. ~ Index)
p = p + theme_classic()
p = p + labs(x="",y="Similarity Index",title=)
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=7,family="sans",angle=30,hjust=1,vjust=1)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.01, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_F1_JSINMI.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.5,height=1.55,units="in",dpi=300)

p = ggplot(dat_sum2,
           aes(x = MnII, y=Measure, color=interaction(Index,Alignment)))
p = p + geom_point(stat="identity",
                 position=position_dodge(0.8), alpha=1, size=1)
p = p + geom_errorbar(aes(ymin = Measure - M.SD, ymax = Measure + M.SD,
                          group =interaction(Index,Alignment)),
                      position=position_dodge(0.8), alpha=1, linewidth=0.8, width=0.7)
p = p + scale_color_manual(values=ColPal$RGB)
p = p + scale_x_discrete(expand = c(0,0.45,0,0.45))
p = p + scale_y_continuous(limits = c(0.5,1), breaks = seq(0.5,1,0.1),
                           expand = c(0,0,0,0))
p = p + facet_grid(. ~ Index)
p = p + theme_classic()
p = p + labs(x="",y="Similarity Index",title=)
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=7,family="sans",angle=30,hjust=1,vjust=1)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.01, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_F1_JSINMI_v2.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.5,height=1.55,units="in",dpi=300)


dat_sum3 = data.frame(
  Alignment = rep(data_sum$Alignment,2),
  MnII = rep(data_sum$MnII,2),
  Index = factor(c(rep("JSI",4),rep("NMI",4)),levels=c("JSI","NMI")),
  COV = c(data_sum$COV.JSI,data_sum$COV.NMI)
)

### COV
p = ggplot(dat_sum3,
           aes(x = MnII, y=COV, fill=interaction(Index,Alignment)))
p = p + geom_bar(stat="identity",color=NA,
                 position=position_dodge(0.8),width=0.75, linewidth=1)
p = p + scale_fill_manual(values=ColPal$RGB)
p = p + scale_x_discrete(expand = c(0,0.45,0,0.45))
p = p + scale_y_continuous(limits = c(0,0.25), breaks = seq(0,0.25,0.05),
                           expand = c(0,0,0,0))
p = p + facet_grid(. ~ Index)
p = p + theme_classic()
p = p + labs(x="",y="COV",title="Inter-subject Variance Similarity Indices")
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=7,family="sans",angle=30,hjust=1,vjust=1)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.01, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_F2_JSINMI.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.5,height=1.55,units="in",dpi=300)


