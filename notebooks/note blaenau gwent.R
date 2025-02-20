# ! Code snippet generated from template for 
# ! use ctrl+f to replace 'Blaenau Gwent' to whatever the LA is called

# Blaenau Gwent FS areas note book check ---------------

# input/output ------------------------------------------------------------

library(tidyverse)

## source here: modern webiste and cross-referencing school catachments -- https://www.blaenau-gwent.gov.uk/en/resident/health-wellbeing-social-care/support-for-children-families/flying-start/
## Comments:

## Todo list:

## School catchments 
fs1_BlaenauGwent <-
  c(
    # list the LSOA that contain any postcodes in FS phase 1 (2006) 
    ## add comments re reliability
    'Blaenau Gwent 003E',
    'Blaenau Gwent 006E',
    'Blaenau Gwent 006D',
    'Blaenau Gwent 006C',
    'Blaenau Gwent 009B',
    'Blaenau Gwent 001B',
    'Blaenau Gwent 009C',
    'Blaenau Gwent 009A'
  )

fs2_BlaenauGwent <- 
  c(
    # list the LSOA that contain any postcodes in FS expansion (2012/13 to 2014/15) 
    ## add comments re reliability
    ## Gwent 
    'W01001457',
    'W01001459',
    'W01001453',
    'W01001469'
#    'W01001435', ## 2015/2016 abertillery 1
#    'W01001451' ## 2015/2016 Cwm 2

  )

## data to do joins



## Use this for the wimd ranking data and list with LSOA name
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')

## need to create long LSOA name
wimd2011_child <-
  wimd2011_child %>%
  mutate(
    `lsoa name alt` = paste(`Local Authority`, `ONS Name`)
  )


# code --------------------------------------------------------------------

## Check which lsoa id to join
fs1_BlaenauGwent[!(fs1_BlaenauGwent %in% wimd2011_child$`lsoa name alt`)]
fs2_BlaenauGwent[!(fs2_BlaenauGwent %in% wimd2011_child$`LSOA Code`)]



wimd2011_child_joined <-
  wimd2011_child %>%
  filter(
    tolower(`Local Authority`) == tolower('Blaenau Gwent')
    ) %>%
  mutate(
    fsPhase1 = `lsoa name alt` %in% fs1_BlaenauGwent
  ) %>%
  mutate(
    fsPhase2 = `LSOA Code` %in% fs2_BlaenauGwent
  )

## Check summary of how many areas? ---------
wimd2011_child_joined %>% summary
# results:
## not perect discontinuity -- 2015/2016 areas are not the next most deprived

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

## results: 

## additional covar to health
wimd2011_child_joined %>%
  filter(!fsPhase1) %>% ## optional delete FS phase 1
  ggplot(
    aes(x = `Income domain_Child Index 2011`, 
        y = `Health domain_Child Index 2011`,
        colour = fsPhase2)
  ) +
  geom_point()

## one area is out of place once we take out FS phase 1-- its slap bang in the middle of a school catchment.
## One areas should't quite be there

## save
wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note blaenau gwent FS.csv')

