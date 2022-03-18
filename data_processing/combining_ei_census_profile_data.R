## Script name: combining_ei_census_profile_data.R
##
## Purpose of script: Add census profile population and covariate data by census division to EI data for analysis.
##        1) Load Cleaned EI (ei_data.rds) and census profile data (census_profile_data.rds)
##        2) Add Population data by age group, sex, and census division to EI data
##        3) Add Covariate data by census division to EI data
##        4) Write to combined_data.rds
##
## Author: Taylor Keating
##
## Email: tkeatin@uw.edu
##
## Notes: Analysis will be performed at census division level
##        Used underlying population by census division from 2016 census throughout.
##        Beware: population by census division may have changed from 2016-2021 (and within 2021)

setwd("~/Documents/GitHub/ei_benefits_analysis/data_processing")
library(tidyverse)

#-----------------------------
# 1) Load Cleaned Data
#- load EI data
ei_data<- readRDS("ei_data.rds")

#- load census profile data
census_profile_data<- readRDS("census_profile_data.rds")
#-----------------------------


#-----------------------------
# 2) Add Population data by age group, sex, and census division to EI data
#       age groups to find are (15-24, 25-54, 55+ years)

#- Calculate population by age group, sex, and census division
pop_15_24_data<- census_profile_data %>%
  filter(COVARIATE_CODE %in% c(14:15)) %>% 
  select(CDUID, COVARIATE, VALUE_MALE, VALUE_FEMALE) %>%
  group_by(CDUID) %>%
  mutate(pop_15_24_male= sum(as.numeric(VALUE_MALE)),
         pop_15_24_female= sum(as.numeric(VALUE_FEMALE))) %>%
  select(CDUID, pop_15_24_male, pop_15_24_female) %>% 
  distinct()
pop_25_54_data<- census_profile_data %>%
  filter(COVARIATE_CODE %in% c(16:21)) %>%
  select(CDUID, COVARIATE, VALUE_MALE, VALUE_FEMALE) %>%
  group_by(CDUID) %>%
  mutate(pop_25_54_male= sum(as.numeric(VALUE_MALE)),
         pop_25_54_female= sum(as.numeric(VALUE_FEMALE))) %>%
  select(CDUID, pop_25_54_male, pop_25_54_female) %>% 
  distinct()
pop_55_over_data<- census_profile_data %>%
  filter(COVARIATE_CODE %in% c(22:24)) %>%
  select(CDUID, COVARIATE, VALUE_MALE, VALUE_FEMALE) %>%
  group_by(CDUID) %>%
  mutate(pop_55_over_male= sum(as.numeric(VALUE_MALE)),
         pop_55_over_female= sum(as.numeric(VALUE_FEMALE))) %>%
  select(CDUID, pop_55_over_male, pop_55_over_female) %>% 
  distinct()
pop_data<- left_join(pop_15_24_data,
                     pop_25_54_data,
                     by="CDUID") %>%
  left_join(pop_55_over_data,
            by="CDUID")

# Combine population data to EI data by age group, sex, census division
combined_data_15_24_male<- ei_data %>%
  filter(EI_Sex=="Males", EI_Age_group=="15 to 24 years") %>%
  left_join((pop_data %>% select(CDUID,pop_15_24_male) %>% rename(pop=pop_15_24_male)),
            by="CDUID")
combined_data_15_24_female<- ei_data %>%
  filter(EI_Sex=="Females", EI_Age_group=="15 to 24 years") %>%
  left_join((pop_data %>% select(CDUID,pop_15_24_female) %>% rename(pop=pop_15_24_female)),
            by="CDUID")
combined_data_25_54_male<- ei_data %>%
  filter(EI_Sex=="Males", EI_Age_group=="25 to 54 years") %>%
  left_join((pop_data %>% select(CDUID,pop_25_54_male) %>% rename(pop=pop_25_54_male)),
            by="CDUID")
combined_data_25_54_female<- ei_data %>%
  filter(EI_Sex=="Females", EI_Age_group=="25 to 54 years") %>%
  left_join((pop_data %>% select(CDUID,pop_25_54_female) %>% rename(pop=pop_25_54_female)),
            by="CDUID")
combined_data_55_over_male<- ei_data %>%
  filter(EI_Sex=="Males", EI_Age_group=="55 years and over") %>%
  left_join((pop_data %>% select(CDUID,pop_55_over_male) %>% rename(pop=pop_55_over_male)),
            by="CDUID")
combined_data_55_over_female<- ei_data %>%
  filter(EI_Sex=="Females", EI_Age_group=="55 years and over") %>%
  left_join((pop_data %>% select(CDUID,pop_55_over_female) %>% rename(pop=pop_55_over_female)),
            by="CDUID")
combined_data<- rbind(combined_data_15_24_male,
                      combined_data_15_24_female,
                      combined_data_25_54_male,
                      combined_data_25_54_female,
                      combined_data_55_over_male,
                      combined_data_55_over_female) %>%
  arrange(CDUID,REF_DATE)


# population_data<- census_profile_data %>% 
#   filter(COVARIATE_CODE %in% c(14:24)) %>% 
#     select(CDUID, COVARIATE, VALUE_BOTH_SEXES, VALUE_MALE, VALUE_FEMALE) %>%
#       group_by(CDUID) %>%
#         mutate(pop_tot= sum(as.numeric(VALUE_BOTH_SEXES)),
#                pop_15_24_male=sum(as.numeric(VALUE_MALE[])),
#                pop_15_24_female,
#                pop_25_54_male,
#                pop_25_54_female,
#                pop_55_over_male,
#                pop_55_over_female)
# population_data<- population_data %>%
#   select(CDUID, pop_over_15) %>%
#     distinct()

# #- create combined dataframe 
# combined_data<- ei_data
# #- add population over 15 to combined_data by census division
# combined_data<- left_join(x=combined_data,
#                           y=population_data,
#                           by="CDUID")

#----------------------------
# 3) Add Covariate data by census division to EI data

#- find rest of covariates by census division
covariate_data<- census_profile_data %>% 
  filter(COVARIATE_CODE %in% c(40,58,663)) %>%
    select(CDUID, COVARIATE, COVARIATE_CODE, VALUE_BOTH_SEXES) %>%
  mutate(VALUE_BOTH_SEXES= as.numeric(VALUE_BOTH_SEXES))
#- add median age
combined_data<- left_join(x=combined_data,
                          y=(covariate_data %>% 
                               filter(COVARIATE_CODE==40) %>% 
                               select(CDUID, VALUE_BOTH_SEXES) %>%
                               rename(pop_median_age=VALUE_BOTH_SEXES)),
                          by="CDUID")
#- add avg household size
combined_data<- left_join(x=combined_data,
                          y=(covariate_data %>% 
                               filter(COVARIATE_CODE==58) %>% 
                               select(CDUID, VALUE_BOTH_SEXES) %>%
                               rename(pop_avg_hh_size=VALUE_BOTH_SEXES)),
                          by="CDUID")
#- add median income
combined_data<- left_join(x=combined_data,
                          y=(covariate_data %>% 
                               filter(COVARIATE_CODE==663) %>% 
                               select(CDUID, VALUE_BOTH_SEXES) %>%
                               rename(pop_median_income=VALUE_BOTH_SEXES)),
                          by="CDUID")
#--------------------------------------


##- Save combined data
saveRDS(object= combined_data, file= "combined_data.rds")


