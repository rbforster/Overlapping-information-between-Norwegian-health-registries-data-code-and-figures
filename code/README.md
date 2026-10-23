# Code

- `data_flow_registries.R` — builds Figure 1 from `data/data_flow_registries.csv`.
- `summarising_data.R` — reads `data/all_registry_variables.xlsx` (not currently used directly — the script embeds total variable counts per registry) and `data/all_overlap.csv`, classifies overlaps, and builds Figure 2, the pie chart (not used in the final manuscript), Figure 3, Supplementary Figure 1, and Supplementary Figure 2.

Both scripts write their outputs to a local `./output/` folder (not included in this repository — create it before running, or adjust the `ggsave()`/`png()` paths).

## Requirements

```r
install.packages(c("tidyverse", "circlize", "writexl",
                    "DiagrammeR", "DiagrammeRsvg", "rsvg"))
```

## One encoding note

`summarising_data.R` originally read `total_variables_overlap.csv` with `fileEncoding = "latin1"`. The copy of that file in this repository has been re-saved as UTF-8 (so GitHub and other tools render the Norwegian variable names correctly), and the script's `fileEncoding` argument has been updated to `"UTF-8"` to match. This is the one deliberate edit made to either script for this repository — everything else is unchanged from the versions used to produce the published figures.
