# caerphilly FS areas --
## source: https://democracy.caerphilly.gov.uk/Data/Cabinet/201309041400/Agenda/4(01)%20Flying%20Start%20Programme%20Expansion%202013-2015%20App%201%20-%20049325.pdf
## but also source of the total 26 areas in expansion 
## https://democracy.caerphilly.gov.uk/documents/s500000454/Rhaglen%20Dechraun%20Deg.pdf

# input/output ------------------------------------------------------------

library(tidyverse)
## handcoded 
## Same for 2001 and 2011 
## Supposed to have 10 in original rollout our 

## School catchments 
fs1_caerphilly <-
  c(
    'Twyn Carno 1',# Upper Rhymney 149
    'Bargoed 4',#Heolddu / Park 123
    'Bedwas, Trethomas and Machen 6', #Graig-y-Rhacca 138
    'St. James 3', #St James
    'St. James 4',# St James
    'Moriah 3', # Abertysswg / Bryn Awel 271
    'Newbridge 2', # Pantside 98
    'New Tredegar 3', # Phillipstown & Tirphil 83
    'Hengoed (Caerphilly) 2',# Hengoed 199
    'Darren Valley 2' 
  )

fs2_caerphilly <- 
  c(
    'Penyrheol (Caerphilly) 8',# Cwm Ifor/Cwm Isaf 119 No
    'Penyrheol (Caerphilly) 4',# Plasyfelin/Hendre 118 No
    'Bedwas, Trethomas and Machen 2',# Tynywern/Bedwas 70 Yes
    'Argoed (Caerphilly) 1',# Markham 94 Yes
    'Pengam 2',# Pengam/Fleur 116 No
    'Crumlin 3',# Trinant 78 plus new housing devt No
    'Risca East 2',# Ty Sign/Ty Isaf 151 Some
    'Aber Valley 4',# Cwm Aber/Plasyfelin
    'Cefn Fforest 2'
    
    # ## 2015/2016 areas
    # 'St. Cattwg 1', # 2015/2016
    # 'St. Cattwg 5',# 2015/2016
    # 'Pontllanfraith 5', # 2015/2016
    # 'Aber Valley 3', # 2015/2016
    # 'Blackwood 2', # 2015/2016
    # 'Morgan Jones 2', # 2015/2016
    # 'Pontllanfraith 2' # 2015/2016

  )

## The list is given in actual names we can just join directly to wimd
wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')


# code --------------------------------------------------------------------
fs1_caerphilly[!(fs1_caerphilly %in% wimd2011_child$`LSOA Name`)]
fs2_caerphilly[!(fs2_caerphilly %in% wimd2011_child$`LSOA Name`)]


wimd2011_child_joined <-
  wimd2011_child %>%
  filter(`Local Authority` == 'Caerphilly') %>%
  mutate(
    fsPhase1 = `LSOA Name` %in% fs1_caerphilly
  ) %>%
  mutate(
    fsPhase2 = `LSOA Name` %in% fs2_caerphilly
  )
## Check bivariate plots -- almost perfect!
wimd2011_child_joined %>% summary



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

## Completely perfect 
wimd2011_child_joined %>%
  filter(!fsPhase1) %>% ## optional delete FS phase 1
  ggplot(
    aes(x = `Income domain_Child Index 2011`, 
        y = `Health domain_Child Index 2011`,
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
  write_csv('data/note caerphilly FS.csv')

