##  makeFile01 Create the baseline data with the running variable 

# input -------------------------------------------------------------------
library(tidyverse)

list.files('data')

cleaned_files <- 
  list(
  "data/note blaenau gwent FS.csv",   
  "data/note cardiff FS.csv",               
  "data/note caerphilly FS.csv",                      
  "data/note flintshire FS.csv",                    
  "data/note merthyr tydfil FS.csv",                   
  "data/note monmouthshire FS.csv",                   
  "data/note npt FS.csv",                            
  "data/note rct FS.csv",                             
  "data/note swansea FS.csv"    
)

wimd2011_indicators <- 
  'data/raw/wimd2011 indicators.csv' %>%
  read_csv(
    skip = 6, , na = c('.', '', '*') 
           )



wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')

# code --------------------------------------------------------------------

## rename
wimd2011_indicators <-
  wimd2011_indicators %>%
  rename(
    `LSOA Code` = ...1,
  )


joined_df <-
  cleaned_files %>%
  map_dfr(
    read_csv
  )

joined_df <-
  joined_df %>%
  left_join(
    wimd2011_child
  ) %>%
  left_join(
    wimd2011_indicators
  )


# eligible sample  ----------------------------------------------------------------

# # Not in FS phase 1
# joined_df <-
#   joined_df %>%
#   filter(!fsPhase1)

## ! Create the cut off variable -- for each LA 
joined_df <-
  joined_df %>%
#  filter(!fsPhase1) %>%
  rename(
    la = `Local Authority`,
    deprivation = `income-related benefits - Child Index (% 0-18 year olds) (2)`
  ) %>%
  mutate( 
    ### Labelling the predicted cut-offs using 1) LA documents OR 2) the cut where most of the expansion lies behind. 
    k =
          case_when(
            la == 'Blaenau Gwent' ~ deprivation - 47.7,
            la == "Caerphilly" ~ deprivation - 41.8,
            la == "Cardiff" ~ deprivation - 54.5,
            la == "Flintshire" ~ deprivation - 34.3,
            la == "Merthyr Tydfil" ~ deprivation - 33.5,
            la == "Monmouthshire" ~ deprivation - 28.8,
            la == "Neath Port Talbot" ~ deprivation - 35.6,
            la == "Rhondda Cynon Taf" ~ deprivation - 38,
            la == "Swansea" ~ deprivation - 44.9
          ),
      k = k + 0.05 # tiny offset to make sure the last area is over the cut-off
    ) 


# save --------------------------------------------------------------------

joined_df %>%
  write_csv('data/makeFile01 baseline FS data.csv')

joined_df %>% summary
joined_df$fsPhase1 %>% summary ## 98 areas
## test
 joined_df %>%
   filter(!fsPhase1) %>%
   ggplot(aes(x = k, y = fsPhase2)) +
   geom_point() 

 joined_df %>%
   filter(!fsPhase1) %>%
   summary
   
 
