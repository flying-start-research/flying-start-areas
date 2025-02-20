# note-rhondda Rhondda taf put all their FS area up BUT I'm still unsure re: FS phase one 


# input/output ------------------------------------------------------------

fsRhondda <-
  'raw data/Rhondda FS list 2015.csv' %>%
  read_csv(skip = 1)


wimd2011_child <- read_csv('data/raw/wimd2011 child.csv')

# code --------------------------------------------------------------------


## Rhondda code needs to be converted to LSOA 
fsRhondda <-
  fsRhondda %>%
  rename(
    `LSOA Name` = lsoa2001Nm
  )
 

fsPhase1 <-
    (fsRhondda %>% filter(fsStatus == 'Flying Start Area'))$`LSOA Name`

### Note that in FS by 31/3/16 doesn;t mean some of the areas arent already in fS 
fsPhase2 <-
    (fsRhondda %>% filter(fsStatus == 'In FS by 31/3/16'))$`LSOA Name`


wimd2011_child_joined <-
  wimd2011_child %>%
  filter(`Local Authority` == 'Rhondda Cynon Taf') %>%
  mutate(
    fsPhase1 = `LSOA Name` %in% fsPhase1,
    fsPhase2 = `LSOA Name` %in% fsPhase2
  )

## Rhondda seems to have loads of FS 
wimd2011_child_joined %>% 
  select(`Local Authority`,
         `ONS Name`,
         `LSOA Name`,
         `LSOA Code`,
         `Income domain_Child Index 2011`,
         fsPhase1,
         fsPhase2) %>%
  write_csv('data/note rct FS.csv')
