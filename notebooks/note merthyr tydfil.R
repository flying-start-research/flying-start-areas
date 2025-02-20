# ! Code snippet generated from template for 
# ! use ctrl+f to replace 'thisLA' to whatever the LA is called

# thisLA FS areas note book check ---------------

# input/output ------------------------------------------------------------

library(tidyverse)

## source here: 
## Comments:

## Todo list:

## School catchments 
fs1_thisLA <-
  c(
    # list the LSOA that contain any postcodes in FS phase 1 (2006) 
    ## add comments re reliability
    'W01001291',
    'W01001308',
    'W01001300',
    'W01001301',
    'W01001299',
    'W01001292',
    'W01001309'
  )

fs2_thisLA <- 
  c(
    # list the LSOA that contain any postcodes in FS expansion (2012/13 to 2014/15) 
    ## add comments re reliability
    'W01001303',
    'W01001295',
    'W01001290',
    'W01001293',
    'W01001302',
    'W01001321',
    'W01001312',
    'W01001298'

  )

## data to do joins



## Use this for the wimd ranking data and list with LSOA name
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')


# code --------------------------------------------------------------------

## Check which lsoa id to join
fs1_thisLA[!(fs1_thisLA %in% wimd2011_child$`LSOA Code`)]
fs2_thisLA[!(fs2_thisLA %in% wimd2011_child$`LSOA Code`)]



wimd2011_child_joined <-
  wimd2011_child %>%
  filter(
    tolower(`Local Authority`) == tolower('Merthyr Tydfil')
    ) %>%
  mutate(
    fsPhase1 = `LSOA Code` %in% fs1_thisLA
  ) %>%
  mutate(
    fsPhase2 = `LSOA Code` %in% fs2_thisLA
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


### save it

wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note merthyr tydfil FS.csv')
