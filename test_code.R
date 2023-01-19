library(tidyverse)

setwd("~/Documents/GitHub/LAK-sandbox/")

#load Biology subset of Ben Koester's PLA data
testdat <- read.csv("biol_student_record.csv")

#return number of students per course catalog number, per term
testdat %>% count(CATALOG_NBR, TERM)