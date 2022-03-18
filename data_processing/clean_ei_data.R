## Script name: clean_ei_data.R
##
## Purpose of script: clean Employment Insurance beneficiaries data for use for spatial analysis
##      1) Load StatsCan Standard Geographic Classification (SGC) Structure 2016 (SGC-CGT-2016-Structure-eng.csv)
##      2) Load and Clean raw EI Data (14100323.csv)
##             - obtain Census division names by matching CDUID with SGC Structure 2016
##             - obtain EI benefits count by month, census division, age group, and sex
##      3) Filter EI data
##             - Only months after CERB closed- Oct 2020 onwards (so let's take on Jan 2021 onwards)
##             - All types of income benefits (total counts with no sub-sets)
##             - Males/Females counts
##             - Age group counts (15-24yrs, 25-54yrs, 55+years)
##      4) Write to ei_data.rds
##
## Author: Taylor Keating
##
## Email: tkeatin@uw.edu
##
## Notes: Analysis will be performed at census division level

setwd("~/Documents/GitHub/ei_benefits_analysis/data_processing")
library(tidyverse)


#---------------------------------
# 1) Load StatsCan Standard Geographic Classification (SGC) Structure 2016
# StatsCan- Hierarchical structure of Region, Province, Census Division, Census Subdivision
hier_region_structure<- read.csv("../data/StatsCan_SGC_Structure/SGC-CGT-2016-Structure-eng.csv")
hier_region_structure_division<- hier_region_structure %>% filter(Level<4)
#---------------------------------


#---------------------------------
# 2) Load and Clean EI data
# obtain Census Division names by matching CDUID with SGC Structure 2016
# obtain EI benefits count by month, census division, age group, and sex

#---
###- Load EI data
ei_data_raw<- read.csv("../data/EI_data/14100323.csv")

ei_data_clean<- ei_data_raw %>% select(-c(UOM,UOM_ID,SCALAR_FACTOR,SCALAR_ID,
                                          VECTOR,COORDINATE,STATUS,SYMBOL,
                                          TERMINATED,DECIMALS))

#---
###- Clean EI data
# create GEO_LEVEL identifier- either National, Province and territory, Census division, or Unclassified
ei_data_clean<- ei_data_clean %>% 
  mutate(GEO_LEVEL= case_when(GEO=="Canada" ~ "National",
                              GEO %in% 
                                (hier_region_structure_division %>% filter(Level==2) %>% 
                                   select(Class.title) %>% unique() %>%
                                   pull(Class.title)) ~ "Province and territory",
                              GEO=="Unclassified" ~ "Unclassified",
                              TRUE ~ "Census division"))
# filter out observations for National, Province and territory level, or Unclassified
ei_data_clean<- ei_data_clean %>% filter(GEO_LEVEL=="Census division")

# create CDUID- id for census division from last 4 digits of DGUID
ei_data_clean<- ei_data_clean %>% mutate(CDUID= as.numeric(gsub(x=ei_data_clean$DGUID, 
                                                                pattern="2016A0003", replacement="")))
# create PRUID- id for province/territory from first 2 digits of CDUID
ei_data_clean<- ei_data_clean %>% mutate(PRUID= as.numeric(substr(x=CDUID, start=1, stop=2)))

# add province/territory column through left_join with hierarchical structure
ei_data_clean<- left_join(x= ei_data_clean, 
                          y=(hier_region_structure_division %>% filter(Level==2) %>% select(Code, Class.title)),
                          by=c("PRUID" = "Code"))
ei_data_clean<- ei_data_clean %>% rename(PROVINCE=Class.title)

# add census division column through left_join with hierarchical structure
ei_data_clean<- left_join(x= ei_data_clean,
                          y=(hier_region_structure_division %>% filter(Level==3) %>% select(Code, Class.title)),
                          by=c("CDUID" = "Code"))
ei_data_clean<- ei_data_clean %>% rename(CENSUS_DIVISION= Class.title)

# remove some variables and re-order
ei_data_clean<- ei_data_clean %>% select(-c(GEO,DGUID))
ei_data_clean<- ei_data_clean %>% select(REF_DATE,GEO_LEVEL,PRUID,CDUID,
                                         PROVINCE,CENSUS_DIVISION, everything())
# rename some variables with EI label
ei_data_clean<- ei_data_clean %>% rename(EI_benefit_type=Beneficiary.detail,
                                         EI_Sex=Sex,
                                         EI_Age_group=Age.group,
                                         EI_beneficiaries=VALUE)

#--------------------------------
# 3) Filter EI data
####- filter for:
# only months after CERB closed- Oct 2020 onwards (so let's take on Jan 2021 onwards)
# all types of income benefits (total counts with no sub-sets)
# Males/Females counts
# Age group counts (15-24yrs, 25-54yrs, 55+years)
ei_data_filter<- ei_data_clean %>% filter((REF_DATE > "2020-12") &
                                          (EI_benefit_type=="All types of income benefits") &
                                          (EI_Sex %in% c("Males","Females")) &
                                          (EI_Age_group %in% c("15 to 24 years","25 to 54 years","55 years and over"))
                                          )
#
#- left with a count for each census division per age group, sex, and month (months starting Jan 2021 onwards)

#---------------------------------
## Save cleaned and filtered EI data
saveRDS(object= ei_data_filter, file= "ei_data.rds")

