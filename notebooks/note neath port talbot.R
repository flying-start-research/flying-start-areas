# Neath Port Talbot FS areas note book check ---------------

# input/output ------------------------------------------------------------

library(tidyverse)

## source here: https://democracy.npt.gov.uk/Data/Children,%20Young%20People%20and%20Education%20Cabinet%20Board/20121220/Agenda/$CYPEB-201212-REP-EL-RAW.doc.pdf
## Comments: in a neat table

## Todo list:

## School catchments 
fs1_npt <-
  c(
    # list the LSOA that contain any postcodes in FS phase 1 (2006) 
    ## Apparently chosen based on  free    school meals take up    of 45% or more
    # Those schools are
    # Glyncorrwg,
    # Croeserw, Glanymor,
    # Tir Morfa, Brynhfryd,
    # Melin Infants,
    # Sandfields Primary
    
    'Aberavon 4',
    'Briton Ferry West 1', # 60 105 67.2% Phase 1
    'Aberavon 2',# 45 164 59.3% Phase 1
    'Cymmer (Neath Port Talbot) 2',# 50 25 57.1% Phase 1
    'Sandfields West 2',# 45 58 55.6% Phase 1
    'Sandfields East 2',# 45 67 53.9% Phase 1
    'Neath East 2',# 25 141 50.9% Phase 1
    'Sandfields West 4',# 25 135 50.6% Phase 1
    'Sandfields West 3',# 25 124 49.4% Phase 1
    'Aberavon 3',# 35 101 47.2% Phase 1
    'Neath South 2',# 50 176 46.2% Phase 1
    'Neath East 1',# 40 167 46.0% Phase 1
    'Sandfields East 1',# 30 219 45.8% Phase 1
    'Glyncorrwg',# 25 168 44.9% Phase 1
    'Neath East 3',# 35 201 42.5% Phase 1
    'Neath South 1',# 25 364 35.5% Phase 1
    'Cymmer (Neath Port Talbot) 1',# 20 446 34.0% Phase 1
    'Briton Ferry West 2',# 20 645 33.2% Phase 1
    'Neath East 4',# 35 196 31.9% Phase 1
    'Sandfields West 1',# 25 416 29.4% Phase 1
    'Sandfields East 3'# 
  )

fs2_npt <- 
  c(
    # list the LSOA that contain any postcodes in FS expansion (2012/13 to 2014/15) 
    ## add comments re reliability
    'Neath North 3',# 35 271 51.5% 2012/13 
    'Glynneath 1',# 30 268 44.4% 2013/14
    'Coedffranc Central 3',# 40 234 43.1% 2013/14
    'Tai-bach 2',# 25 283 42.9% 2013/14
    'Bryn and Cwmavon 3',# 35 222 42.8% 2013/14
    'Pontardawe 2',# 40 447 40.3% 2013/14
    'Ystalyfera 2',# 20 318 36.2% 2013/14
    'Gwynfi',# 30 193 36.1% 2013/14
    'Sandfields East 4',# 25 303 40.7% 2014/15
    'Gwaun-Cae-Gurwen 1',# 25 497 36.1% 2014/15
    'Blaengwrach',# 25 654 35.7% 2014/15
    'Briton Ferry East 2'# 25 346 35.6% 2014/15
    
  )

## data to do joins



## Use this for the wimd ranking data and list with LSOA name
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')


# code --------------------------------------------------------------------

## Check which lsoa id to join
fs1_npt[!(fs1_npt %in% wimd2011_child$`LSOA Name`)]
fs2_npt[!(fs2_npt %in% wimd2011_child$`LSOA Name`)]



wimd2011_child_joined <-
  wimd2011_child %>%
  filter(
    tolower(`Local Authority`) == tolower('Neath Port Talbot')
  ) %>%
  mutate(
    fsPhase1 = `LSOA Name` %in% fs1_npt
  ) %>%
  mutate(
    fsPhase2 = `LSOA Name` %in% fs2_npt
  )


## Check summary of how many areas? ---------
wimd2011_child_joined %>% summary
# results: 21 in phase 1 and 12 in phase 2


## Check it on a dashboard -------------

library(plotly)

p <- 
  wimd2011_child_joined %>%
  filter(!fsPhase1) %>% ## optional delete FS phase 1
  mutate(`in FS (jittered)` = fsPhase2 %>% as.numeric() +rnorm( n(), sd = 0.05 )) %>%
  ggplot(
    aes(x = `Income domain_Child Index 2011`, 
        y = `in FS (jittered)`, #`Education domain_Child Index 2011`,
        label = `LSOA Name`,
        colour = fsPhase2)
  ) +
  #  geom_text(size = 0.4) +
  geom_point()

ggplotly(p)

## results: Perfect discontinuity! 

## additional covar to health
wimd2011_child_joined %>%
  filter(!fsPhase1) %>% ## optional delete FS phase 1
  ggplot(
    aes(x = `Income domain_Child Index 2011`, 
        y = `Health domain_Child Index 2011`,
        colour = fsPhase2)
  ) +
  geom_point()

## save
wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note npt FS.csv')


