# Data dictionary

All CSV files are semicolon-delimited (`;`), UTF-8 encoded, with a header row. They underpin the overlap analysis reported in *"Navigating data selection for research using Norwegian health registry data: A guide to understanding overlapping information between registries"*.

Registry abbreviations used throughout: NPR (Norwegian Patient Registry), NRPHC (Norwegian Registry for Primary Health Care), HKR (Cardiovascular Disease Registry), NCoDR (Norwegian Cause of Death Registry), MBRN (Medical Birth Registry of Norway), LMR (Norwegian Prescription Database), ABR (Abortion Registry), SYSVAK (Norwegian Immunisation Registry), MSIS (Norwegian Surveillance System for Communicable Diseases), CRN (Cancer Registry of Norway).

## `all_registry_variables.xlsx`

The full variable catalogue exported from HelseData.no for the ten registries, one row per variable (1357 variables). Columns are the fields as published in the metadata catalogue (variable name, variable group, registry, description, data type, code list reference, validity period, etc.) in both Norwegian and English where the catalogue provides both. This is the source table that `summarising_data.R` reads in to build the overlap classification.

**Note:** metadata catalogues are updated periodically. Before relying on this file to reproduce the manuscript's exact figures, confirm its export date matches the vintage used in the published analysis.

## `all_overlap.csv`

One row per variable pair judged to represent the same, or related, information across two registries. 314 rows, grouped into 80 distinct overlapping information domains (`overlap_code`).

| Column | Description |
|---|---|
| `overlap_concept` | The information theme the overlap belongs to (e.g. `diagnoses`, `cause_of_death`, `vaccination`, `birth_weight`). |
| `overlap_code` | Numeric identifier for the overlapping information domain. 80 distinct values; a domain can include more than one variable pair when more than two registries hold related variables. |
| `multiple_variables_concept` | Flag indicating whether this domain involves more than one variable per registry side. |
| `reg1`, `variabelnavn_reg1` | Registry and variable name for one side of the pair. |
| `reg2`, `variabelnavn_reg2` | Registry and variable name for the other side of the pair. |
| `Type of overlap` | One of three categories: `same_name_same_information`, `different_name_same_information`, `overlapping_information` (related but not directly interchangeable information — referred to in the manuscript as "similar information"). |

Distribution of the 80 domains across the three categories: `same_name_same_information` (n = 11, 13.8%), `different_name_same_information` (n = 11, 13.8%), `overlapping_information` (n = 58, 72.5%).

## `total_variables_overlap.csv`

One row per variable that is involved in at least one overlap, with the registries it overlaps with.

| Column | Description |
|---|---|
| `registry` | Registry abbreviation. |
| `total_count_variables` | Total number of variables held by that registry (from the full catalogue). |
| `variable` | Variable name (Norwegian), as it appears in the registry's metadata catalogue. |
| `overlap_1`–`overlap_7` | The registry/registries this variable overlaps with (up to 7; blank where not applicable). |

## `data_flow_registries.csv`

The source/establishment information used to build the data flow diagram (Figure 1).

| Column | Description |
|---|---|
| `Registry` | Registry abbreviation. |
| `Source` | Where the registry's data originates (e.g. "Specialist health services", another registry it draws from, "Pharmacies"). |
| `Date` | Year from which that data source has fed the registry. |

**Note on SYSVAK:** this file lists SYSVAK's date as 1976 for both its source rows. The published Figure 1 labels the SYSVAK node "SYSVAK (1995)", with 1976 relegated to a footnote, reflecting that systematic computerised reporting from 1995 is the registry's primary reference point while 1976 marks an earlier, more limited recording period. Worth double-checking this file's `Date` value against the manuscript's intended framing before publishing, so the two aren't read as contradicting each other.
