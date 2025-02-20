# Flintshire FS areas --
## source: 18 March Council cabinet meeting 
# https://committeemeetings.flintshire.gov.uk/documents/s21714/Flying%20Start%20Update.pdf?LLL=0
## additional areas here 

# input/output ------------------------------------------------------------

library(tidyverse)
## handcoded 
## Same for 2001 and 2011 

## School catchments -
## Based entirely on the LSOA list -- get rid of the LSOA if the name matches / cross reference 
## with WG maps
fs1_Flintshire <-
  c(
    ## Basically they said to use 
    'Shotton Higher 1',
    'Shotton Higher 2',
    'Aston 1',
    'Aston 2',
#    'Queensferry',
#    Connah’s Quay Central Bryn Deva Primary ## can be several lsoas
"Connah's Quay Central 1",
"Connah's Quay Central 2",
 "Connah's Quay Golftyn 4",# maybe think this was a previous FS they were expanding

#    Flint Gwynedd Primary --- Flint can be so many places need to check 
## -- this is actually near a train station called Flint  
## From Welsh Gov's maps in stats summary -- we're erring on caution
# 005A
# 004B
# 004A
# 004C
# 005D
# 005B 
# 005C
# 004D
'Flint Coleshill 1',
'Flint Coleshill 3',
'Flint Trelawny 1', 
'Flint Trelawny 2', 
'Flint Castle',     
'Flint Coleshill 2',
'Flint Oakenholt 1',
'Flint Oakenholt 2',

#    Greenfield Maes Glas Primary
"Greenfield 1",
"Greenfield 2"

  )

fs2_Flintshire <- 
  c(
    # 2013 - 2014
    'Holywell Central', # 107 
    'Sealand 2', #/ 92 
    'Mold West 1', #/ 69
    'Buckley Bistre West 3',
    # 2014-2015 
    'Queensferry', # 90
    'Mancot 2' #/ 75
    # potential extra 
##    "Connah's Quay Golftyn 4" #only 31 children -- was this a previous FS start and they were expanding?


    # ## 2015 onward part of delvierty 
    # 'Bagillt West', #2015/2016
    # 'Holywell West' # 2015/2016
    # 
    ## unclear if Mancot 1 or 2 was included. mancot 1 is not very deprived vs mancot 2  
  )

## The list is given in actual names we can just join directly to wimd
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')


# code --------------------------------------------------------------------

wimd2011_child_joined <-
  wimd2011_child %>%
  filter(`Local Authority` == 'Flintshire')
wimd2011_child_joined#$`LSOA Name` %>% sort()

wimd2011_child_joined <-
  wimd2011_child %>%
  filter(`Local Authority` == 'Flintshire') %>%
  mutate(
    fsPhase1 = `LSOA Name` %in% fs1_Flintshire
  ) %>%
  mutate(
    fsPhase2 = `LSOA Name` %in% fs2_Flintshire
  )
## Check bivariate plots -- almost perfect!
## all seems very geographically clustered 


## Check it on a dashboard 

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

## almost perfect -- flint oakenholt 1 and flint castle is on the wrong side but i think this may be in FS phase 1 
## Connah's Quay Golftyn 4 seems not very deprived and should be there originally -- i reckon this is 
##  also in FS phase 1
## - [x] 2015/2016 areas are not simply the next most deprived 

wimd2011_child_joined %>%
  #  filter(!fsPhase1) %>% ## optional delete FS phase 1
  ggplot(
    aes(x = `Income domain_Child Index 2011`, y = `Health domain_Child Index 2011`,
        colour = fsPhase2)
  ) +
  geom_point()


## save the data 
wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note flintshire FS.csv')

