################################
#Overlapping variables project
################################

#summarising results and figures
#Author: Rachel Forster rachelbedenis.forster@fhi.no
#Date: 27.03.26

################################

library(tidyverse)
library(circlize)
library(writexl)


data <- read.csv2("./data/all_overlap.csv")
data_variables <- read.csv2("./data/total_variables_overlap.csv",
                            fileEncoding = "UTF-8")
# NOTE: the original file was latin1-encoded; it has been re-saved as UTF-8
# in this repository for GitHub compatibility, so this argument was changed
# to match. If you restore the original latin1 file, change this back.

#total variables per registry
total_variables_list <- list(
  MBRN = 354,
  MSIS = 239,
  NPR = 205,
  LMR = 115,
  NRPHC = 102,
  ABR = 80,
  NCoDR = 61,
  CRN = 84,
  HKR = 61,
  SYSVAK = 56
)
total_variables_df <- data.frame(
  registry = names(total_variables_list),
  total_count_variables = unlist(total_variables_list),
  stringsAsFactors = FALSE
)

#make factor variables
data <- data %>%
  mutate(
    overlap_code = as.factor(overlap_code),
    reg1 = as.factor(reg1),
    reg2 = as.factor(reg2),
    overlap_description = as.factor(Type.of.overlap)
  )

# Summary of the number of different overlap_codes
overlap_code_summary <- data %>%
  count(overlap_code)
#80

# Filter to get unique combinations of overlap_code and overlap_description
unique_overlap_summary <- data %>%
  distinct(overlap_code, overlap_description)

######### Summary and pie chart for overlap descriptions ###################
# Calculate the count and proportion for each unique overlap_description
overlap_description_summary <- unique_overlap_summary %>%
  group_by(overlap_description) %>%
  summarise(count = n()) %>%
  mutate(proportion = count / sum(count)*100)

custom_descriptions <- c(
  "same_name_same_information" = "Same variable name, same definition",
  "different_name_same_information" = "Different variable name, same definition",
  "overlapping_information" = "Similar information"


)
custom_colors <- c(
  "overlapping_information" = "#00b782",
  "different_name_same_information" = "#234e5f",
  "same_name_same_information" = "#ec7c73"
)

pie_chart <- ggplot(overlap_description_summary, aes(x = "", y = proportion, fill = overlap_description)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  labs(title= NULL,
       fill = "Overlap Descriptions") +
  scale_fill_manual(
    values = custom_colors,
    labels = custom_descriptions,
    breaks = c("same_name_same_information",
               "different_name_same_information",
               "overlapping_information")
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        plot.title = element_text(size = 18),
        legend.title = element_text(size = 14),
        legend.text = element_text(size = 12)
    ) +
  geom_text(aes(label = paste0(round(proportion, 1), "%")),
            position = position_stack(vjust = 0.5), color = "white", size = 4)
pie_chart
# Save the ggplot using ggsave
ggsave(
  filename = "./output/overlap_descriptions_pie_chart.png",  # Specify the file name and format
  plot = pie_chart,                             # Plot to save
  width = 8,                                       # Width in inches
  height = 6,                                      # Height in inches
  dpi = 300                                        # Resolution in dots per inch
)
###############################################################################
############ Matrix of overlapping concepts #########################
library(dplyr)
library(tidyr)

# Summarize overlap data to get counts between registry pairs
overlap_counts <- data %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup()

# Create symmetric pairs
symmetric_counts <- overlap_counts %>%
  bind_rows(overlap_counts %>% rename(reg1 = reg2, reg2 = reg1))

# List of all registries
registries <- unique(c(data$reg1, data$reg2))

# Generate all possible pair combinations (including each registry meeting itself)
registry_pairs <- expand.grid(reg1 = registries, reg2 = registries)

# Combine registry pairs with symmetric overlap counts
complete_overlap_data <- registry_pairs %>%
  left_join(symmetric_counts, by = c("reg1", "reg2")) %>%
  mutate(overlap_count = replace_na(overlap_count, 0))  # Fill NAs with zero

# Expand data frame into wide matrix format
overlap_matrix <- complete_overlap_data %>%
  pivot_wider(names_from = reg2, values_from = overlap_count, values_fill = list(overlap_count = 0))

# Print matrix for inspection
print(overlap_matrix)

# Visualization
plot_data <- complete_overlap_data  # Already in long format
plot_data <- plot_data %>%
  mutate(overlap_count = ifelse(reg1 == reg2, NA, overlap_count))

overlap_matrix <- ggplot(plot_data, aes(x = reg1, y = reg2)) +
  geom_tile(aes(fill = overlap_count), color = "white") +
  scale_fill_gradient(low = "white", high = "#65a9c5") +
  geom_text(aes(label = overlap_count), color = "black", size = 5) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(hjust = 1, size = 12),
    axis.ticks = element_blank(),
    legend.title = element_blank(),
    plot.title = element_text(size = 18),
    plot.subtitle = element_text(size = 14)
  )+
  labs(
    title = "Registry Overlap Comparison Matrix",
    subtitle = "Number of overlapping concepts between each registry"
  )

overlap_matrix

ggsave(
  filename = "./output/overlap_matrix.png",  # Specify the file name and format
  plot = overlap_matrix,                             # Plot to save
  width = 10,                                       # Width in inches
  height = 6,                                      # Height in inches
  dpi = 300                                        # Resolution in dots per inch
)
################################################################################

########## Summarise proportion of registry variables involved in an overlap ##
# Count unique variables per registry
involved_counts <- data_variables %>%
  distinct(registry, variable) %>%
  group_by(registry) %>%
  summarise(involved_count = n_distinct(variable))

bar_custom_colors <- c(
  "SYSVAK" = "#09181f",
  "ABR" = "#16323d",
  "HKR" = "#234e5f",
  "MBRN" = "#2a6a82",
  "NCoDR" = "#4089a7",
  "CRN" = "#65a9c5",
  "NPR" = "#8fc5dc",
  "LMR" = "#c8e1ec",
  "NRPHC" = "#e0f0f7",
  "MSIS" = "#f2fafe"
)

proportion_data <- involved_counts %>%
  left_join(total_variables_df, by = "registry") %>%
  mutate(
    proportion = involved_count / total_count_variables * 100
  )

proportion_data <- proportion_data %>%
  arrange(desc(proportion)) %>%
  mutate(
    registry = factor(registry, levels = unique(registry)),
    registry_label = paste0(registry, " (", involved_count, " of ", total_count_variables, ")"),
    registry_label = factor(registry_label, levels = registry_label))

# Create bar chart
bar_chart <- ggplot(proportion_data, aes(x = registry_label, y = proportion, fill = registry)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Proportion of Variables Involved in Overlaps by Registry",
    x = "Registry (total number variables in registry)",
    y = "Proportion (%)"
  ) +
  theme_minimal() +
  scale_fill_manual(values = bar_custom_colors) +  # Customize colors: you can choose other palettes
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(size = 18),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    legend.position = "none"
  )
bar_chart
ggsave(
  filename = "./output/proportion_variables_involved.png",  # Specify the file name and format
  plot = bar_chart,                             # Plot to save
  width = 8,                                       # Width in inches
  height = 6,                                      # Height in inches
  dpi = 300                                        # Resolution in dots per inch
)
################################################################################
############## chord diagam #########

# Summarize data to count how many unique overlap_codes exist for each pair of registries
overlap_summary <- data %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/chord_diagram.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  overlap_summary,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
  )

label_tweaks <- list(
  CRN = list(adj = c(0.5, -1.2), nudge = 0),
  SYSVAK = list(adj = c(0.5, -1.6), nudge = 0),
  NRPHC = list(adj = c(0.5, -0.2), nudge = -0.15)
)

default_tweak <- list(adj = c(0.5, -0.2), nudge = 0)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    s <- CELL_META$sector.index
    tw <- if (s %in% names(label_tweaks)) label_tweaks[[s]] else default_tweak
    circos.text(
      x = CELL_META$xcenter + tw$nudge * CELL_META$xrange,
      y = CELL_META$ylim[1],
      labels = s,
      facing = "bending", niceFacing = TRUE, cex = 1.2,
      adj = tw$adj
      )
  },
  bg.border = NA
)
dev.off()
circos.clear()

write_xlsx(overlap_summary, path = "./output/overlap_summary.xlsx")

###############################################################################
# Chord for just similar information
data_similar <- data %>%
  filter(overlap_description == "overlapping_information")

overlap_summary_similar <- data_similar %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/chord_diagram_similar.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  overlap_summary_similar,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    s <- CELL_META$sector.index
    tw <- if (s %in% names(label_tweaks)) label_tweaks[[s]] else default_tweak
    circos.text(
      x = CELL_META$xcenter + tw$nudge * CELL_META$xrange,
      y = CELL_META$ylim[1],
      labels = s,
      facing = "bending", niceFacing = TRUE, cex = 1.2,
      adj = tw$adj
    )
  },
  bg.border = NA
)
dev.off()
circos.clear()
write_xlsx(overlap_summary_similar, path = "./output/overlap_summary_similar.xlsx")

###############################################################################
# Chord for just same/same information
data_samesame <- data %>%
  filter(overlap_description == "same_name_same_information")

overlap_summary_samesame <- data_samesame %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/chord_diagram_samesame.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  overlap_summary_samesame,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    # Customize 'adj' for specific labels if overlapping occurs
    if (CELL_META$sector.index %in% c("CRN")) {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -1.2))  # Adjust 'adj' manually for overlap cases
    } else {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -0.2))  # Standard positioning
    }
  },
  bg.border = NA
)
dev.off()
circos.clear()
write_xlsx(overlap_summary_samesame, path = "./output/overlap_summary_samesame.xlsx")

###############################################################################
# Chord for just diff/same
data_diffsame <- data %>%
  filter(overlap_description == "different_name_same_information")

overlap_summary_diffsame <- data_diffsame %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/chord_diagram_diffsame.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  overlap_summary_diffsame,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    # Customize 'adj' for specific labels if overlapping occurs
    if (CELL_META$sector.index %in% c("CRN")) {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -1.2))  # Adjust 'adj' manually for overlap cases
    } else {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -0.2))  # Standard positioning
    }
  },
  bg.border = NA
)
dev.off()
circos.clear()
write_xlsx(overlap_summary_diffsame, path = "./output/overlap_summary_diffsame.xlsx")

######################## chord diagam DIAGNOSES #########
data_diagnoses <- data %>%
  filter(overlap_concept == "diagnoses")

# Summarize data to count how many unique overlap_codes exist for each pair of registries
diagnoses_overlap_summary <- data_diagnoses %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/diagnoses_chord_diagram.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  diagnoses_overlap_summary,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    # Customize 'adj' for specific labels if overlapping occurs
    if (CELL_META$sector.index %in% c("")) {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -1.2))  # Adjust 'adj' manually for overlap cases
    } else {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -0.2))  # Standard positioning
    }
  },
  bg.border = NA
)

dev.off()
circos.clear()
write_xlsx(diagnoses_overlap_summary, path = "./output/diagnoses_overlap_summary.xlsx")
################################################################################
######################## chord diagam COD ########
data_death <- data %>%
  filter(overlap_concept == "cause_of_death")

# Summarize data to count how many unique overlap_codes exist for each pair of registries
death_overlap_summary <- data_death %>%
  group_by(reg1, reg2) %>%
  summarise(overlap_count = n_distinct(overlap_code)) %>%
  ungroup() %>%
  mutate()

png("./output/death_chord_diagram.png", width = 1000, height = 1000, res = 150)

# Create chord diagram
chordDiagram(
  death_overlap_summary,
  grid.col = c(
    "SYSVAK" = "#d74b46",
    "ABR" = "#40436d",
    "HKR" = "#61d2b2",
    "MBRN" = "#a93c38",
    "NCoDR" = "#f9dc8c",
    "CRN" = "#7176c9",
    "NPR" = "#65a9c5",
    "LMR" = "#2a6a82",
    "NRPHC" = "#179463",
    "MSIS" = "#f0af5e"
    # Add colors for all registries involved in your df
  ),
  annotationTrack = c("grid"),
  preAllocateTracks = list(list(track.height = 0.075)),
  transparency = 0.4,
  link.lwd = 1,    # Line width
  link.lty = 1,    # Line type
  link.border = 1
)

circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    # Customize 'adj' for specific labels if overlapping occurs
    if (CELL_META$sector.index %in% c("")) {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -1.2))  # Adjust 'adj' manually for overlap cases
    } else {
      circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index,
                  facing = "bending", niceFacing = TRUE, cex = 1.2, adj = c(0, -0.2))  # Standard positioning
    }
  },
  bg.border = NA
)

dev.off()
circos.clear()
write_xlsx(death_overlap_summary, path = "./output/death_overlap_summary.xlsx")
##############################################################################
