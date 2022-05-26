# PD_detection

This repositiory contains the tools to detect and analyse intensity, number and size of detected particles from microscopy images with multiple zlayers. 

In particular this was used to detect and analyse intensity of aniline blue staining at plasmodesmata, wich correlates with abundance of callose deposits.

The tool box is consititued by two parts

- PART 1: FIJI macro for image analysis
- PART 2: R script for data analysis

Both scripts drive semi-automated processes that require user input. Both scripts are documented to explain the steps taken byt the programme and the actions that the user needs to take. 
The output of PART 1 is an excel file that needs to be elaborated appropriately by the user befeore proceeding to PART 2. The excel file contains one line for each detected particle. The user needs to add columns taking into account that the analysis in PART 2 uses as a grouping variable a column called 'Name'.

Briefly, your excel file will have one row for each detected particle and 7 columns:

#Label: the name of your particle, is a combination of leaf number, sample number and particle number in that sample
#Area
#Mean
#Max
#Min
#IntDen
#RawIntDen

For you file to be compatible with the PART 2 straight away, we reccomend that you insert 3 empty columns after the Label column and name them

#Geno: the genotype or condition of your sample
#Leaf: the leaf number 
#Name: the leaf number AND sample number, so this is a unique identifier for each image taken

We usually take at least 2 images per leaf so in the column Name we would have leaf1_sample1, leaf2_sample2 etc for each leaf

Once your excel file is ready select and copy the whole excel file for the columns from Geno to the column RawIntDen and proceed with the PART2 of the analysis.

Further explanations and details are annotated in the scripts.


*insert DOI here*
