# flying-start-areas

Author: Meng Le Zhang

Repository containing lists of Flying Start areas (original areas and 2012-2015 expansion). Areas are listed by LSOA (2001). Includes data on primary sources and checks. 

All data is open source and can be re-used for further research.

## Usage

Summary: You can grab the data from `data/makeFile01 baseline FS data.csv` which contains: the LSOA, LA and the running variable k which is centred such that k = 0 is where the cut-off is (with a slight offset so that all LSOAs over the cut-off have ks bigger than 0).

If you want to check how the data was produced from first principles
- `/docs`: contains documents gathered for evidence on Flying Start. Include primary sources and files for georeferencing printed maps
- `/data`: includes data used for analysis. Contain data on Flying Start areas
- `/notebooks`: R scripts and analysis notebooks for manual data input and validation. 

The script `makeFile01 baseline FS data.R` collates all the data (assuming you've run all the stuff in `/notebooks`). 

More detailed explanations are given in [`note on data sources.md`](<note on data sources.md>).

## Contact
Meng Le Zhang (zhangm19@cardiff.ac.uk)