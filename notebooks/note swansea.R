# ! Code snippet generated from template for 
# ! use ctrl+f to replace 'Swansea' to whatever the LA is called

# Swansea FS areas note book check ---------------

# input/output ------------------------------------------------------------

library(tidyverse)

## source here: 
## Comments:

## Todo list:

## School catchments 
fs1_Swansea <-
  c(
    # list the LSOA that contain any postcodes in FS phase 1 (2006) 
    ## add comments re reliability
    'Swansea 011E',
    'Swansea 011A',
    'Swansea 011B',
    'Swansea 011D',
    'Swansea 011C',
    'Swansea 013E',
    'Swansea 016F',
    'Swansea 016A',
    'Swansea 016E',
    'Swansea 016D',
    'Swansea 016B',
    'Swansea 025A',
    'Swansea 019C',
    'Swansea 019E',
    'Swansea 019A',
    'Swansea 019F',
    'Swansea 019D',
    'Swansea 014B'
  )

fs2_Swansea <- 
  c(
    # list the LSOA that contain any postcodes in FS expansion (2012/13 to 2014/15) 
    ## add comments re reliability
    'Swansea 001D',
    'Swansea 002C', 
    'Swansea 003D',
    'Swansea 006D',
    'Swansea 008C', 
    'Swansea 009A',
    'Swansea 011D',
    'Swansea 011C',
    'Swansea 011B',
    'Swansea 011E',
    'Swansea 011A',
    'Swansea 013C', 
    'Swansea 025B',
    'Swansea 026B', 
    'Swansea 026A', 
    'Swansea 019A',
    'Swansea 019B',
    'Swansea 019C',
    'Swansea 019E',
    'Swansea 019F',
    'Swansea 016A',
    'Swansea 016F',
    'Swansea 021B',
    'Swansea 021A',
    'Swansea 014A'

  )

## data to do joins


## fix: get rid of phase 1 areas in phase 2 inlist
# setdiff(1:3, 2:4)# example
fs2_Swansea <- setdiff(fs2_Swansea, fs1_Swansea)

## Use this for the wimd ranking data and list with LSOA name
## Get this for all naming types 

wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')

## need to create long LSOA name
wimd2011_child <-
  wimd2011_child %>%
  mutate(
    `lsoa name alt` = paste(`Local Authority`, `ONS Name`)
  )

# code --------------------------------------------------------------------
## Check which lsoa id to join
fs1_Swansea[!(fs1_Swansea %in% wimd2011_child$`lsoa name alt`)]
fs2_Swansea[!(fs2_Swansea %in% wimd2011_child$`lsoa name alt`)]



wimd2011_child_joined <-
  wimd2011_child %>%
  filter(
    tolower(`Local Authority`) == tolower('Swansea')
    ) %>%
  mutate(
    fsPhase1 = `lsoa name alt` %in% fs1_Swansea
  ) %>%
  mutate(
    fsPhase2 = `lsoa name alt` %in% fs2_Swansea
  )

## Check summary of how many areas? ---------
wimd2011_child_joined %>% summary
# results:


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

### save swansea

wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note swansea FS.csv')


