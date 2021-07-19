# PD_detection

This repositiory contains the tools to detect and analyse intensity, number and size of detected particles. 

In particular this was used to detect and analyse intensity of aniline blue staining at plasmodesmata, wich correlates with intensity of callose deposits.

The tool box is consititued by two parts

- PART 1: FIJI macro for image analysis
- PART 2: R script for data analysis

Both scripts drive semi-automated processes that require user input. Both scripts are documented to explain the steps taken byt the programme and the actions that the user needs to take. 
The output of PART 1 is an excel file that needs to be elaborated appropriately by the user befeore proceeding to PART 2. The excel file contains one line for each detected particle. The user needs to add columns taking into account that the analysis in PART 2 uses as a grouping variable a column called 'Name' - if the data need to be analysed grouped by genotype, insert the genotype in the column 'Name'.

This script was used in 

*insert DOI of papers here?*
