#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script generates plots similarity metrics between MDT 
# and input images as in "Quality Assurance Strategies for Brain
# State Characterization by MEMRI" 
# by Uselman TW, Jacobs RE, and Bearer EL (2026)md
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# Load/Install required libraries.
libs = c("openxlsx","tidyverse","ggplot2","nlme","emmeans")
lL = length(libs)
vers = c("3.5.0","4.1.0","4.1.0","3.1.0","4.0.0") # minimum R required is 4.1.0
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


data = read.xlsx("./MDT_Alignment.xlsx", colNames = T) %>% as.data.frame() %>%
  mutate(
    ID = factor(ID),
    Alignment = factor(
      Step,
      levels = c(0,1,2),
      labels = c("None","Rigid","Affine")
      )
    ) %>% select(
      ID, Alignment, Threshold, Nbins, JSI, NMI
    )

data_sum = data %>% 
  group_by(Threshold,Nbins,Alignment) %>% 
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
           aes(x = Alignment, y=Avg.JSI, color=Alignment))
p = p + geom_point(position=position_dodge(0.5), alpha=1, size=1)
p = p + geom_errorbar(aes(ymin = Avg.JSI-SE.JSI, ymax = Avg.JSI+SE.JSI),
                      position=position_dodge(0.5), alpha=1, linewidth=0.8, width=0.5)
p = p + scale_color_manual(values=c("skyblue2","dodgerblue2","blue2"))
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
ggsave(filename="./Fig2_D1_JSI.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.55,units="in",dpi=300)
# NMI
p = ggplot(data_sum,
           aes(x = Alignment, y=Avg.NMI, color=Alignment))
p = p + geom_point(position=position_dodge(0.5), alpha=1, size=1)
p = p + geom_errorbar(aes(ymin = Avg.NMI-SE.NMI, ymax = Avg.NMI+SE.NMI),
                      position=position_dodge(0.5), alpha=1, linewidth=0.8, width=0.5)
p = p + scale_color_manual(values=c("skyblue2","dodgerblue2","blue2"))
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
ggsave(filename="./Fig2_D1_NMI.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.55,units="in",dpi=300)


dat_sum2 = data.frame(
  Alignment = rep(data_sum$Alignment,2),
  Index = factor(c(rep("JSI",3),rep("NMI",3)),levels=c("JSI","NMI")),
  COV = c(data_sum$COV.JSI,data_sum$COV.NMI)
)

### COV
p = ggplot(dat_sum2,
           aes(x = Index, y=COV, fill=Alignment, color=Alignment))
p = p + geom_bar(stat="identity", alpha=1,color=NA,
                 position=position_dodge(0.8),width=0.75, linewidth=1)
p = p + scale_fill_manual(values=c("skyblue2","dodgerblue2","blue2"))
p = p + scale_x_discrete(expand = c(0,0.45,0,0.45))
p = p + scale_y_continuous(limits = c(0,0.25), breaks = seq(0,0.25,0.05),
                           expand = c(0,0,0,0))
p = p + theme_classic()
p = p + labs(x="",y="COV",title="Inter-subject Variance Similarity Indices")
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=8,family="sans",angle=30,hjust=0.7,vjust=0.7)
              , axis.title.y = element_text(size=9,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.01, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_D2_COV_JSINMI.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.6,height=1.55,units="in",dpi=300)




lme.out = lme(JSI ~ Alignment, random=(~1|ID), data=data)
summary(lme.out)
anova(lme.out, type = "marginal")

con.out = emmeans(lme.out, specs = "Alignment")
con.out %>% pairs()
con.out %>% pairs(adjust="FDR")

lme.out2 = lme(JSI ~ Alignment, random=(~1|ID), data=data)
summary(lme.out2)
anova(lme.out2, type = "marginal")
con.out2 = emmeans(lme.out2, specs = "Alignment")
con.out2 %>% pairs()
con.out2 %>% pairs(adjust="FDR")
