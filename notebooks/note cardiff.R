# ! Code snippet generated from template for 
# ! use ctrl+f to replace 'Cardiff' to whatever the LA is called

# Cardiff FS areas note book check ---------------
# from digitising this document 
## https://cardiff.moderngov.co.uk/documents/s12940/Item%204.pdf

## update 19/2/2025: We have primary source data from the council on the 
## school catchment. digitised and checked

# input/output ------------------------------------------------------------

library(tidyverse)

## source here: 
## Comments:

## Todo list:
### - need to eliminate school catchments 

## School catchments 
fs1_Cardiff <-
  c(
    # list the LSOA that contain any postcodes in FS phase 1 (2006) 
    ## add comments re reliability
    ## using cardiff council doc 1 (georefenced map) and original source from the council (not in repo)

    ## trelai
    '041C',
    '041A',
    '045B',
    '045C',
    '045D',

    
    ### mt stuart and st mary 
    '047C',
    '047B',
    '047A',

    ## Herbert thompson 
    '039A',
    '039C',
    '039D',
    '041D',
#    '031B', #tiny non-residential area
#    '031C', #tiny non-residential area
    '031D', #tiny but inludes an estate
    # windsor clive
    '039B',
    '039E',
    '043A',
    '043C', #tiny bit
    
    

    ## adamsdown
    '032B',
    '036B',
    '036C',
    '036A',
    
    ## glan yr afon
    '015B',
    '007C',
    '007B',
    ## other bits overlapping with LAs are not residential

    ## Greenway
    '011D',
    '016B',
    '022D',
#    '022A', # insubstantial area (greenfield)
    '016A',
    '016D',  ## essentially 1 street
    '022B' ## tiny -- one road
  )

fs2_Cardiff <- 
  c(
    # list the LSOA that contain any postcodes in FS expansion (2012/13 to 2014/15) 
    ## add comments re reliability
    
    ## NOTE: These are the LSOA w/o school catchments (which are in the first file)
  # Adamsdown
    'Adamsdown 1',
    'Adamsdown 2',
    'Adamsdown 3',
    'Adamsdown 4',
 # butetown
'Butetown 1',
'Butetown 2',
'Butetown 3',

# Caerau
'Caerau (Cardiff) 2',
'Caerau (Cardiff) 3',
'Caerau (Cardiff) 4',
'Caerau (Cardiff) 6',

# ely
'Ely 1',
'Ely 2',
'Ely 3',
'Ely 4',
'Ely 5',
'Ely 6',
'Ely 8',
'Ely 10',

# fairwater
'Fairwater (Cardiff) 5',


# llanrumney
'Llanrumney 3',
'Llanrumney 6',
'Llanrumney 7',

# rumney
'Rumney 4',
'Rumney 5',
'Rumney 6',

# splott
'Splott 3',
'Splott 6',
'Splott 8',

#trowbridge
'Trowbridge 4',
'Trowbridge 8',
'Trowbridge 10',

'..'
  )

## data to do joins



## Use this for the wimd ranking data and list with LSOA name
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')
wimd2011_child %>% summary
# no missingness in child index but... missingness in income stat
#

wimd2011__child_v2 <- 
  'data/raw/wimd2011 indicators.csv' %>%
  read_csv(skip = 6, na = c('.', '', '*'))

wimd2011__child_v2 %>% summary # 100 NAs -- why

wimd2011__child_v2 %>% 
  filter(is.na(`income-related benefits - Child Index (% 0-18 year olds) (2)`)) 
## these areas are missing data on indicators 

wimd2011__child_v2 <-
  wimd2011__child_v2 %>%
  transmute(
    k = `income-related benefits - Child Index (% 0-18 year olds) (2)`,
    `LSOA Code` = ...1
  )

wimd2011__child_v2 %>%
  filter( !(`LSOA Code` %in% wimd2011_child$`LSOA Code`) ) %>%
  summary
## basically 96 out 97 of those codes that aren't in the WIMD child index have missing
## data on the income

wimd2011__child_v2
wimd2011_child$`LSOA Code` %in% wimd2011__child_v2$`LSOA Code` %>% summary

wimd2011_child <-
  wimd2011_child %>%
  left_join(
    wimd2011__child_v2
  )

wimd2011_child %>% summary

# code --------------------------------------------------------------------

## Check which lsoa id to join
fs1_Cardiff[!(fs1_Cardiff %in% wimd2011_child$`ONS Name`)]
fs2_Cardiff[!(fs2_Cardiff %in% wimd2011_child$`LSOA Name`)]



wimd2011_child_joined <-
  wimd2011_child %>%
  filter(
    tolower(`Local Authority`) == tolower('Cardiff')
    ) %>%
  mutate(
    fsPhase1 = `ONS Name` %in% fs1_Cardiff
  ) %>%
  mutate(
    fsPhase2 = `LSOA Name` %in% fs2_Cardiff
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
    aes(x = k, 
        y = `in FS (jittered)`, #`Education domain_Child Index 2011`,
        label = `LSOA Name`,
        colour = fsPhase2)
  ) +
  #  geom_text(size = 0.4) +
  geom_point()

ggplotly(p)

## why is
# 1) ely 9 not in FS at that time 
# 2) Pentwyn 3 and riverside 3 there?
# 3) Pentwyn 8 is also over the threshold but not considered

# using 2025 info
# Pentwyn 3: CF23 7XH is in that LSOA and has FS childcare only (so not FS full prog)
#   pentwyn 8: CF23 7XG is in that LSOA and Flying Start 
# riverside 3: CF11 9EX is in that LSOA and Flying Start

## ... in addition riverside 8: CF11 6LN in riverside in FS but the LSOA was not listed
## ... Trowbridge 5: CF3 0AH is FS childcare only and not in expansion. (as expected)

## results: 
# trimming is too agrresive

## additional covar to health
wimd2011_child_joined %>%
  filter(!fsPhase1) %>% ## optional delete FS phase 1
  ggplot(
    aes(x = `Income domain_Child Index 2011`, 
        y = `Health domain_Child Index 2011`,
        colour = fsPhase2)
  ) +
  geom_point()

## save it anyway -- not clean enough
# 
# wimd2011_child_joined %>% 
#   select(`Local Authority`,
#          `ONS Name`,
#          `LSOA Name`,
#          `LSOA Code`,
#          `Income domain_Child Index 2011`,
#          fsPhase1,
#          fsPhase2) %>%
#   write_csv('data/note cardiff FS.csv')
# 
# 


