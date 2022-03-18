## Script name: clean_census_profile_data.R
##
## Purpose of script: clean Census Profile 2016 data for use for spatial analysis
##    1) Load raw StatsCan Census Profile 2016 data (Census_division_profile_2016.csv)
##      - obtain population counts of age groups (15-19,...,60-64,65+) and sexes (male,female) by census division
##      - obtain other covariates of interest by census division
##    2) Write to census_profile_data.rds
##
## Author: Taylor Keating
##
## Email: tkeatin@uw.edu
##
## Notes: Analysis will be performed at census division level

setwd("~/Documents/GitHub/ei_benefits_analysis/data_processing")
library(tidyverse)

#---------------------------------
###- Load StatsCan- Census Profile 2016 by Census Division
census_profile_2016_raw<- read.csv("../data/StatsCan_Census_Profile/Census_Profile_2016/Census_division_profile_2016.csv")

###- Clean census profile data
#- filter for:
  # populations for age groups of interest (15-19,..., 60-64, 65+years)
  # other variables (avg age, median age, avg household size, median income)
census_profile_2016_clean<- census_profile_2016_raw %>% 
  filter(Member.ID..Profile.of.Census.Divisions..2247. %in% c(14:24,40,58,661:665))

#- remove columns of no use for this analysis
census_profile_2016_clean<- census_profile_2016_clean %>% 
  select(-c(GNR,GNR_LF,DATA_QUALITY_FLAG,Notes..Profile.of.Census.Divisions..2247.))

#- rename variables
census_profile_2016_clean<- census_profile_2016_clean %>%
  rename(CDUID=GEO_CODE..POR.,
         COVARIATE=DIM..Profile.of.Census.Divisions..2247.,
         COVARIATE_CODE=Member.ID..Profile.of.Census.Divisions..2247.,
         VALUE_BOTH_SEXES=Dim..Sex..3...Member.ID...1...Total...Sex,
         VALUE_MALE=Dim..Sex..3...Member.ID...2...Male,
         VALUE_FEMALE=Dim..Sex..3...Member.ID...3...Female)
####
#---------------------------------

## Save cleaned and filtered Census Profile data
saveRDS(object=census_profile_2016_clean, file="census_profile_data.rds")
