#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script generates line plots for FPR/FNR and Balanced
# Accuracy analysis in "Quality Assurance Strategies for Brain
# State Characterization by MEMRI" 
# by Uselman TW, Jacobs RE, and Bearer EL (2026)md
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# Load/Install required libraries.
libs = c("openxlsx","tidyverse","ggplot2")
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

df = read.xlsx("./ConfusionData.xlsx",
               sheet="ConfusionData",
               colNames=T)

df1 = df %>% 
  mutate(
    Kernel = factor(Kernel),
    CohD  = factor(round(CohD ,3))
  )

cls = c(RColorBrewer::brewer.pal(5,"Blues")[3:5],RColorBrewer::brewer.pal(5,"OrRd")[3:5])

if (!dir.exists("./FigData/")) {dir.create("./FigData/")}
p1 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = Specificity*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1)*100, breaks = seq(0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[4:6])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="Specificity (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
pleg1 = cowplot::get_plot_component(p1, 'guide-box-top', return_all = TRUE)
ggsave(filename = "Fig3_Analysis_FPRNCP_legend.tif",
       plot = pleg1,
       path = "./FigData/",
       width = 3.25, height = 0.5, units = "in", dpi = 600)
p1 = p1 + theme(legend.position = "none")
p1
ggsave(filename = "Fig3_Analysis_SpecificitybyNCP.tif",
       plot = p1,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)

p2 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = FPR*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,0.07)*100, breaks = seq(0,0.07,0.01)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[4:6])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="False Positive Rate (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p2 = p2 + theme(legend.position = "none")
p2
ggsave(filename = "Fig3_Analysis_FPRbyNCP.tif",
       plot = p2,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)



df1 = df1 %>% group_by(Kernel,CohD) %>% 
  mutate(
    Percent.Removed = (FP[ClusterSize==1]-FP) /
      FP[ClusterSize==1],
    Percent.Remaining = 1 - Percent.Removed
  ) %>% ungroup()


p3 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = Percent.Removed*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1)*100, breaks = seq(0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5), expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[4:6])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="False Positives Removed (%)",color="Cohen's D\nThreshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(1, "cm"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )
p3 = p3 + theme(legend.position = "none")
p3
ggsave(filename = "Fig3_Analysis_PercentFPRemove_byCohD.tif",
       plot = p3,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)



p4 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = Percent.Remaining*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1)*100, breaks = seq(0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5), expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[4:6])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="False Positives Remaining (%)",color="Cohen's D\nThreshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(1, "cm"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )
# pleg3 = suppressWarnings(cowplot::get_legend(p3))
p4 = p4 + theme(legend.position = "none")
p4
ggsave(filename = "Fig3_Analysis_PercentFPRemaining_byCohD.tif",
       plot = p4,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)




p5 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = FNR*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1)*100, breaks = seq(0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[1:3])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="False Negative Rate (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
pleg5 = cowplot::get_plot_component(p5, 'guide-box-top', return_all = TRUE)
ggsave(filename = "Fig3_Analysis_FNRNCP_legend.tif",
       plot = pleg5,
       path = "./FigData/",
       width = 3.25, height = 0.5, units = "in", dpi = 600)
p5 = p5 + theme(legend.position = "none")
p5
ggsave(filename = "Fig3_Analysis_FNRbyNCP.tif",
       plot = p5,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)




p6 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = Sensitivity*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1)*100, breaks = seq(0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = cls[1:3])+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="Sensitivity (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p6 = p6 + theme(legend.position = "none")
p6
ggsave(filename = "Fig3_Analysis_SensitivitybyNCP.tif",
       plot = p6,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)



p7 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = BalAcc*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0.4,1)*100, breaks = seq(0.4,1,0.1)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = rev(c("black","grey30","gray60")))+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="Balanced Accuracy (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
pleg7 = cowplot::get_plot_component(p7, 'guide-box-top', return_all = TRUE)
ggsave(filename = "Fig3_Analysis_BalAccNCP_legend.tif",
       plot = pleg7,
       path = "./FigData/",
       width = 3.25, height = 0.5, units = "in", dpi = 600)
p7 = p7 + theme(legend.position = "none")
p7
ggsave(filename = "Fig3_Analysis_BalancedAccuracy_byNCP.tif",
       plot = p7,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)


TableOut = df1 %>% mutate(BalancedAccuracy = round(BalAcc, 3)) %>% filter(Kernel != "0") %>% group_by(Kernel, CohD, ClusterSize) %>% select(Kernel, BalancedAccuracy, CohD, ClusterSize) %>% arrange(Kernel,desc(BalancedAccuracy))
TableOut %>% knitr::kable()

write.xlsx(TableOut, "./FigData/BalancedAccuracy_Table.xlsx", asTable = T)


p7.1 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = wBalAcc*100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0.4,1)*100, breaks = seq(0.4,1,0.1)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = rev(c("black","grey30","gray60")))+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="Weighted Balanced Accuracy (%)",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p7.1 = p7.1 + theme(legend.position = "none")
p7.1
ggsave(filename = "Fig3_Analysis_WeightedBalancedAccuracy_byNCP.tif",
       plot = p7.1,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)


TableOut = df1 %>% mutate(wBalancedAccuracy = round(wBalAcc, 3)) %>% filter(Kernel != "0") %>% group_by(Kernel, CohD, ClusterSize) %>% select(Kernel, wBalancedAccuracy, CohD, ClusterSize) %>% arrange(Kernel,desc(wBalancedAccuracy))
TableOut %>% knitr::kable()

write.xlsx(TableOut, "./FigData/WeightedBalancedAccuracy_Table.xlsx", asTable = T)


p8 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = MattCorCoef *100,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(-0.1,1)*100, breaks = seq(-0,1,0.25)*100) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = rev(c("black","grey30","gray60")))+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="MCC",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p8 = p8 + theme(legend.position = "none")
p8
ggsave(filename = "Fig3_Analysis_MCC_byNCP.tif",
       plot = p8,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)

TableOut = df1 %>% mutate(MatthewCorrelation = round(MattCorCoef, 3)) %>% filter(Kernel != "0") %>% group_by(Kernel, CohD, ClusterSize) %>% select(Kernel, MatthewCorrelation, CohD, ClusterSize) %>% arrange(Kernel, desc(MatthewCorrelation))
TableOut %>% knitr::kable()

write.xlsx(TableOut, "./FigData/MCC_Table.xlsx", asTable = T)


p9 = ggplot(df1,
            aes(x = ClusterSize^(1/3),
                y = YoudenJ,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(-0.01,1), breaks = seq(0,1,0.25)) +
  scale_x_continuous(limits = c(1,5), breaks = seq(1,5),
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = rev(c("black","grey30","gray60")))+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="",y="Youden's J Statistic",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p9 = p9 + theme(legend.position = "none")
p9
ggsave(filename = "Fig3_Analysis_YoudenJ_byNCP.tif",
       plot = p9,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)

TableOut = df1 %>% mutate(YoudenJ = round(YoudenJ, 3)) %>% filter(Kernel != "0") %>% group_by(Kernel, CohD, ClusterSize) %>% select(Kernel, YoudenJ, CohD, ClusterSize) %>% arrange(Kernel, desc(YoudenJ))
TableOut %>% knitr::kable()

write.xlsx(TableOut, "./FigData/YoudenJ_Table.xlsx", asTable = T)




p10 = ggplot(df1,
            aes(x = FPR,
                y = Sensitivity,
                group = interaction(Kernel,CohD),
                color = CohD)) +
  geom_line(linewidth=1) +
  geom_point(size=2) +
  scale_y_continuous(limits = c(0,1), breaks = seq(0,1,0.25)) +
  scale_x_continuous(limits = c(0,0.25), breaks = seq(0,0.25,0.05), 
                     expand = c(0.01,0.01)) +
  scale_color_manual(values = rev(c("black","grey30","gray60")))+
  facet_grid(Kernel ~ ., labeller = labeller(Kernel = c("0" = "0 um","150" = "150 um", "300" = "300 um"))) +
  labs(x="False Positive Rate",
       y="Sensitivity",color="Cohen's D Threshold") +
  theme_bw() + 
  theme(
    axis.title = element_text(family="sans",face="bold",size=8),
    axis.text  = element_text(family="sans",size=7),
    strip.text = element_text(family="sans",size=8,margin=margin(0,2,0,2)),
    strip.background = element_rect(fill="gray90"),
    legend.title = element_text(family="sans",face="bold",size=7,hjust=0.5),
    legend.text = element_text(family="sans",size=6,hjust=0.5),
    legend.key.size = unit(0.5, "cm"),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
p10 = p10 + theme(legend.position = "none")
p10
ggsave(filename = "Fig3_Analysis_ROC_byNCP.tif",
       plot = p10,
       path = "./FigData/",
       width = 1.9, height = 3, units = "in", dpi = 600)
