#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script generates plots grayscale histograms and 
# similarity metrics between MDT and input images as in 
# "Quality Assurance Strategies for Brain State 
# Characterization by MEMRI" 
# by Uselman TW, Jacobs RE, and Bearer EL (2026)md
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# Load/Install required libraries.
libs = c("RNifti","tidyverse","ggplot2")
lL = length(libs)
vers = c("3.5.0","4.1.0","4.1.0") # minimum R required is 4.1.0
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


fnames = list.files(path="./", pattern = "PTSD") # Specific Subset of images used (corresponds to Standard 'Std' mice from published dataset)
fnamesout = list.files(path="./output", pattern = "PTSD") # Specific Subset of images used (corresponds to Standard 'Std' mice from published dataset)
refname = list.files(path="./", pattern = "MDA.nii")
for (i in 1:length(fnames)) {
  if (i == 1) {
    ref_dat = as.vector(readNifti(refname))
  }
  nii_dat = as.vector(readNifti(fnames[i]))
  niiout_dat = as.vector(readNifti(paste0("./output/",fnamesout[i])))
  df = data.frame(
    "Image" = factor(
      c(rep("MDA",length(ref_dat)),
        rep("Pre-Scaled",length(nii_dat)),
        rep("Scaled",length(niiout_dat))),
      levels = c("MDA","Pre-Scaled","Scaled")),
    "SI" = c(ref_dat,nii_dat,niiout_dat)
  )
  p = ggplot(df, aes(x = SI, fill = Image)) + 
    geom_histogram(data=subset(df,Image == 'MDA'),fill = ColPal$RGB[2], alpha = 0.75, bins=1000) +
    geom_histogram(data=subset(df,Image == 'Pre-Scaled'),fill = ColPal$RGB[3], alpha = 0.75, bins=1000) +
    geom_histogram(data=subset(df,Image == 'Scaled'),fill = ColPal$RGB[1], alpha = 0.75, bins=1000) +
    # # geom_density(aes(y=..count..),alpha = 0.25, color=NA) + 
    scale_x_continuous(limits=c(3000,12000), breaks=seq(4000,12000,2000), expand=c(0,0,0,0)) +
    scale_y_continuous(limits=c(0,5000), breaks=seq(0,5000,1000), expand=c(0,0,0,0)) +
    # scale_fill_manual(values=c("goldenrod2","darkblue",ColPal$RGB[2])) +
    labs(x="Signal Intensity",y="Number of Voxels") +
    theme_classic() + theme(plot.title = element_blank()
                            , axis.title.x = element_text(size=8,face="bold",family="sans")
                            , axis.text.x = element_text(size=7,family="sans",hjust=0.8)
                            , axis.title.y = element_text(size=8,face="bold",family="sans")
                            , axis.text.y = element_text(size=7,family="sans")
                            , panel.spacing.x = unit(0.05, "lines")
                            , strip.text = element_blank()
                            , strip.background = element_blank())
  
  ggsave(filename=paste0("./Fig2_E_ModScal_",i,".tiff")
         ,plot=p
         ,device="tiff"
         ,path=paste0(wdir)
         ,width=2.25,height=1.5,units="in",dpi=300)
}


fnames = c("./ScalingTest.csv","./output/ScalingTest.csv")
scalingdata1 <- read.csv(fnames[1], header = TRUE, stringsAsFactors = TRUE) %>% 
  mutate(Image = Var1,
         ScalingFactor = sfacth,
         AbsDiffSF = abs(ScalingFactor-1)) %>%
  select(Image,ScalingFactor,AbsDiffSF)
scalingdata2 <- read.csv(fnames[2], header = TRUE, stringsAsFactors = TRUE) %>%
  mutate(Image = Var1,
         ScalingFactor = sfacth,
         AbsDiffSF = abs(ScalingFactor-1)) %>%
  select(Image,ScalingFactor,AbsDiffSF)

df_modscale = rbind(cbind.data.frame(scalingdata1,
                                     Step=factor(rep("Pre-Scale",dim(scalingdata1)[1]),
                                                 levels = c("Pre-Scale","Scaled"))),
                    cbind.data.frame(scalingdata2,
                                     Step=factor(rep("Scaled",dim(scalingdata2)[1]),
                                                 levels = c("Pre-Scale","Scaled"))))

str(df_modscale)

df_modscale_sum = df_modscale %>% 
  filter(!(Image %in% c("MDA.nii","MDA.hist.nii"))) %>%
  group_by(Step) %>%
  reframe(
    Avg = mean(ScalingFactor),
    SD  = sd(ScalingFactor),
    SE  = SD / sqrt(n()),
    COV = SD / Avg
  ) %>%
  ungroup() %>%
  as.data.frame()

p = ggplot(df_modscale_sum, aes(x = Step, y = Avg, color = Step)) +
  geom_point(alpha = 1,size = 1) +
  geom_errorbar(aes(ymin = Avg-SE, ymax = Avg+SE),
                linewidth=0.8, width=0.5) +
  geom_point(data= df_modscale, aes(x = Step, y = ScalingFactor, color = Step),
             alpha = 0.25, size = 0.5) +
  scale_y_continuous(limits=c(0.75,1.5), breaks=seq(0.75,1.5,0.25), expand=c(0,0,0,0)) +
  scale_color_manual(values=ColPal$RGB[c(1,3)]) +
  labs(x="",y="Modal Scaling Factor") +
  theme_classic() +
  theme(plot.title = element_blank()
        , axis.title.x = element_blank()
        , axis.text.x = element_text(size=7,family="sans",angle=30,hjust=0.7,vjust=0.8)
        , axis.title.y = element_text(size=8,face="bold",family="sans")
        , axis.text.y = element_text(size=7,family="sans")
        , panel.spacing.x = unit(0.05, "lines")
        , strip.text = element_blank()
        , strip.background = element_blank()
        , legend.position = "none")
p  
ggsave(filename="./Fig2_E2_ScaleFact.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.5,units="in",dpi=300)


p = ggplot(df_modscale_sum, aes(x = Step, y = COV, fill = Step))
p = p + geom_bar(stat="identity", alpha=1,color=NA,width=0.75)
p = p + scale_fill_manual(values=ColPal$RGB[c(1,3)])
p = p + scale_y_continuous(limits = c(0,0.251), breaks = seq(0,0.25,0.05),
                           expand = c(0,0,0,0))
p = p + theme_classic()
p = p + labs(x="",y="COV")
p = p + theme(plot.title = element_blank()
              , axis.title.x = element_blank()
              , axis.text.x = element_text(size=7,family="sans",angle=30,hjust=0.7,vjust=0.8)
              , axis.title.y = element_text(size=8,face="bold",family="sans")
              , axis.text.y = element_text(size=7,family="sans")
              , panel.spacing.x = unit(0.05, "lines")
              , strip.text = element_blank()
              , strip.background = element_blank()
              , legend.position = "none")
p
ggsave(filename="./Fig2_E2_ScaleFact_COV.tiff"
       ,plot=p
       ,device="tiff"
       ,path=paste0(wdir)
       ,width=1.2,height=1.5,units="in",dpi=300)
