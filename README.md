# ei_benefits_analysis
Project exploring spatial mapping and regression of employment insurance benefits in Canada

This project is based on data from [Statistics Canada- Employment Insurance Statistics (EIS)](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410032301), the [2016 Statistics Canada Census](https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/prof/details/page.cfm?Lang=E&Geo1=PR&Code1=01&Geo2=PR&Code2=01&Data=Count&SearchText=01&SearchType=Begins&SearchPR=01&B1=All&Custom=&TABID=3), and [geographic shapefiles of Canada by census division](https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm).

## Purpose

This code is used to perform prevalence mapping of the proportion of individuals at least 15 years old receiving employment insurance benefits in Canada, as well as perform spatial regression on this data.

## Files/Folders

### data

Contains the following data:

- employment insurance count data by census division, stratified by age-group and sex, from  [Statistics Canada- Employment Insurance Statistics (EIS)](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410032301)
- population count data by census division and census division level covariate data from [2016 Statistics Canada Census](https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/prof/details/page.cfm?Lang=E&Geo1=PR&Code1=01&Geo2=PR&Code2=01&Data=Count&SearchText=01&SearchType=Begins&SearchPR=01&B1=All&Custom=&TABID=3)
- hierarchical geographic structure in Canada from [Standard Geographic Classification (SGC) 2016 Classification- Statistics Canada](https://www.statcan.gc.ca/en/subjects/standard/sgc/2016/index)
- Statistics Canada [geographic shapefiles by census division](https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm)

### data_processing

- `clean_id_data.R` loads employment insurance count data and obtain EI benefits count by month, census division, age group, and sex. Then write to `ei_data.rds`.
- `clean_census_profile_data.R` loads StatsCan 2016 census data and obtain population counts of age groups (15-19,...,60-64,65+) and sexes (male,female) by census division, obtain other covariates of interest by census division. Then write to `census_profile_data.rds`.
- `combining_ei_census_profile_data.R` adds census profile population and covariate data by census division to EI data for analysis. Then write to `combined_data.rds`.

### census_divisions.graph

- neighbour adjacency matrix by census division created in `ei_spatial_mapping_report.Rmd`

### ei_spatial_mapping_report.Rmd

- code used to run prevalence mapping and spatial regression using `combined_data.rds` and geographic shapefiles

### ei_spatial_mapping_report.html

- spatial analysis report in html format

### ei_spatial_mapping_report.pdf

- spatial analysis report in pdf format


