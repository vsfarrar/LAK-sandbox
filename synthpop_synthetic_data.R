# Synthetic SEISMIC Data using Synthpop
# Goal: To create a synthetic dataset for the LAK Workshop (and beyond)
# to produce equity reports and replicate WG1 equity analyses

#using upper division dataset from SEISMIC Measurements Fellowship project, summer 2021
#selecting four courses of interest

dat <- mydata %>% filter(crs_name %in% c("STA100","EVE100", "BIS101","CHE128A")) %>%
  select(st_id, female, ethniccode_cat = ethnicode_cat, 
         firstgen, international, transfer, lowincomeflag, 
         numgrade, cum_prior_gpa, gpao, crs_name, crs_section = crs_term,
         admit_gpa) %>%
  filter(!is.na(numgrade)) %>%
  filter(between(female, 0,1)) %>%
  filter(between(crs_section, 201610,201910))

#reformatting variables for synthesis
dat$crs_section <- as.factor(dat$crs_section)
dat$crs_name <- as.factor(dat$crs_name)
dat <- dat %>% mutate_at(c('female', 'ethniccode_cat',
                           'firstgen','international',
                           'transfer','lowincomeflag'), as.numeric)

#Synthpop to synthesize similar data ####
  #refer to tutorial in ref[1]
library(synthpop)

#describe characteristics of the dataset
codebook.syn(dat)

#synthesize data
mysyn <- syn(dat)

#compare variable spread and characteristics between datasets - close! 
compare(mysyn,dat, stat = "counts") #it works great!


#Clean Up Synthesized Data to Prepare for Workshop Use  ####

#load data
#synthesized data from above was synthesized and run 1/26/2023
#modified in Excel to change course names

syndat <- read.csv("~/Downloads/LAK-workshop-materials/mysyn.csv")

#data processing
syndat_clean <- 
syndat %>% 
  add_count(crs_name, crs_section, name = "n_section") %>% #add a class size per section
  filter(!str_sub(as.character(crs_section), -1) %in% c("5","6","7")) %>% #remove summer course sections
  filter(n_section > 70) %>% #remove small sections
  #conservatively code the missing demographic values instead of excluding
  tidyr::replace_na(list(ethniccode_cat = 0, firstgen = 0, international = 0,
                         transfer = 0, lowincomeflag = 0)) 

#create better random ids for students (see ref [2])
library(ids)
randomids <- ids::random_id(n = 16616, bytes = 2) 

syndat_clean$st_id <- randomids #replace student id column in dataframe

#Export cleaned synthetic data ####
write.csv(syndat_clean, file = "~/Downloads/LAK-workshop-materials/SEISMIC_synthetic_data_2023-01-26.csv")

# References ####
#[1]https://www.synthpop.org.uk/get-started.html
#[2]https://stackoverflow.com/questions/58228092/generate-a-unique-random-string-in-r-using-stringi