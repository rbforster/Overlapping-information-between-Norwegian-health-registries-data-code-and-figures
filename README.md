# Overlapping information between Norwegian health registries

Data, analysis code, and figures supporting:

> Elmalih, V. et al. "Navigating data selection for research using Norwegian health registry data: A guide to understanding overlapping information between registries." *European Journal of Public Health* (submitted).

This repository maps overlapping variables across ten central Norwegian health registries, to help researchers and registry advisors identify which variables are genuinely interchangeable across registries, and which only look similar on the surface.

## Repository structure

```
data/           source data: the full variable catalogue (downloaded from HelseData.no 2026-08-17), the overlap classification,
                and the data underlying the data-flow figure (see data/README.md)
code/           R scripts used to produce the manuscript's figures
figures/        the figures and supplementary figures as published
```

## Figures

| File | Corresponds to |
|---|---|
| `figures/figure1_data_flow.png` | Figure 1 — data flow into each registry |
| `figures/figure2_comparison_matrix.png` | Figure 2 — number of overlapping domains between each pair of registries |
| `figures/figure3_chord_diagrams_main.png` | Figure 3 — overlapping domains by overlap type (A: all 80 domains; B: same name/same information; C: different name/same information; D: overlapping information) |
| `figures/supplementary1_chord_diagrams_diagnoses_death.png` | Supplementary Figure 1 — overlapping domains by theme (A: diagnoses, n = 22; B: cause of death, n = 11) |
| `figures/supplementary2_proportions_bar.png` | Supplementary Figure 2 — proportion of each registry's variables involved in an overlap |

Figure legends (including alt text) are maintained alongside the manuscript; see the Data Availability Statement in the manuscript for how this repository is cited.

## Code

- `code/data_flow_registries.R` — builds Figure 1 from `data/data_flow_registries.csv`.
- `code/summarising_data.R` — reads `data/all_registry_variables.xlsx` and `data/all_overlap.csv`, classifies overlaps, and builds Figure 2, Figure 3, and the supplementary figures.

Both scripts are provided as run, for transparency and reproducibility. See each script's header comments for the R packages required (`DiagrammeR`, `DiagrammeRsvg`, `rsvg`, `tidyverse`, `circlize`, `writexl`, `ggplot2`).

## Data availability statement

The data and code supporting the findings of this study are openly available in this repository: [repository URL]. The underlying registry metadata was obtained from the [HelseData.no](https://helsedata.no) metadata catalogue.

## License

- Code (`code/`): MIT License — see `LICENSE`.
- Data (`data/`) and figures (`figures/`): CC BY 4.0 — see `data/LICENSE`.

## Citation

See `CITATION.cff`.
