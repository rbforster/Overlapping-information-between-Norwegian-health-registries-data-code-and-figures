################################
#Overlapping variables project
################################

#Registry data flow diagram
#Author: Rachel Forster rachelbedenis.forster@fhi.no
#Date: 14.04.26

################################

library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)
library(tidyverse)
################################

registry_data <- read.csv2("./data/data_flow_registries.csv")

##########
# Create a label with registry name and year
registry_data <- registry_data %>%
  group_by(Registry) %>%
  mutate(label = paste0(Registry, " (", Date, ")")) %>%
  ungroup()

# Define node types and positions
intermediate_sources <- c("NPR", "NCoDR")
main_sources <- unique(registry_data$Source)
registries <- unique(registry_data$Registry)

# Create the Diagrammer graph using graphviz notation
graph_code <- "
digraph registry_data_flow {
  rankdir=TB;

  // Node definitions with shapes and positions
  node [shape = circle, fontname = Arial, fontsize = 18, style = filled, fillcolor = '#40436d', fontcolor = white, width = 1.3];
  Specialist [label = 'Specialist health services'];
  Primary [label = 'Primary/municipal health services'];
  Pharm [label = 'Pharmacies'];
  Lab [label = 'Laboratories'];

  node [shape = rectangle, style=filled, fillcolor='#a93c38', fontname = Arial, fontsize = 16, fontcolor = white, width = 1, height = 0.8];
  NPR [label = 'NPR (2008)*'];
  NCoDR [label = 'NCoDR (1951)'];

  node [shape = rectangle, fontname = Arial, fontsize = 16, style=filled, fillcolor='#d74b46'];
  NRPHC [label = 'NRPHC (2017)'];
  HKR [label = 'HKR (2012)'];
  MBRN [label = 'MBRN (1967)***'];
  LMR [label = 'LMR (2004)'];
  ABR [label = 'ABR (1979)'];
  SYSVAK [label = 'SYSVAK (1995)**'];
  MSIS [label = 'MSIS (1975)'];
  CRN [label = 'CRN (1951)'];

  // Edge definitions
  Specialist -> NPR;
  Primary -> NRPHC;
  NPR -> HKR;
  NCoDR -> HKR;
  Specialist -> NCoDR;
  Primary -> NCoDR;
  Specialist -> MBRN;
  Primary -> MBRN;
  Pharm -> LMR;
  Specialist -> ABR;
  Primary -> SYSVAK;
  Specialist -> SYSVAK;
  Specialist -> MSIS;
  Primary -> MSIS;
  Lab -> MSIS;
  Lab -> CRN;
  Primary -> CRN;
  Specialist -> CRN;
  NCoDR -> CRN;
  NPR -> CRN;


}
"


# Render the graph
grViz(graph_code)


# Render SVG from DiagrammeR graph
svg_code <- grViz(graph_code) %>% export_svg()

# Convert SVG to PNG with specified resolution and dimensions
rsvg_png(charToRaw(svg_code), file = "./output/registry_data_flow.png", width = 1000, height = 800)
