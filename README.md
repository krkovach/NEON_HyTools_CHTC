#### Bash workflow for processing HyTools BRDF and topographic corrections with subsequent trait estimation for ABoVE data from the AVIRIS-NG sensor.

1. **HyTools_CHTC.sub** - Initial processing script for submitting jobs to the UW-CHTC cluster.

   Controls distribution of jobs using parameters from list */Tables/ABOVE_joblistfull.txt*
   
2. **HyTools_CHTC.sh** - Bash shell script for processing job on single node (also local machine).

   Runs specific job on each node using lines pulled from url locations and BRDF grouped according to file */Tables/ABOVE_Lines.txt*.  This file allows for the specification of different locations for both the **OBS_ORT** file and **image binary and .hdr files** (as has been the case with existing AVIRIS-NG repos).

#### Processing steps within *HyTools_CHTC.sh* are as follows:

1. Set environmental variables (specified from **HyTools_CHTC.sub**).
2. Import and set Python environment (available [here](https://drive.google.com/file/d/1SA5sEl1XUSjpTKohVrjByJXYkqd5eNKi/view?usp=sharing)).  *Add this file to "/Zips"*.
3. Import and organize files necessary for processing.
4. Make folders and populate lists with necessary information from */Tables/ABOVE_Lines.txt* file.
5. Correct **OBS_ORT** rotation by creating newly corrected **OBS_ORT** file.
6. Carry out topographic and grouped FlexBRDF correction.
7. Apply trait models to produce trait maps (base: NEON 2016-2018 models).
8. TAR and GZ all output files.
9. Cleanup temporary files.
