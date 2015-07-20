# HBV-EC-Met-Prep
Code to convert Daymet processed met data into met files for HBV-EC input
###################################################################################
William Kleindl, PhD 
University of Montana

###################################################################################
Met file prep provided in the read-me and the attached code will walk through:
1.	Deriving daily means with zonal statistics
2.	Final file preparation for model input (including issues with leap years)

###################################################################################
1. Deriving daily means with zonal stats: I am using a hydrologic model titled HBV-EC. This model requires daily means of Rainfall, Snowfall and Temperature for each climate zone in the modeled watershed.  For my project, I used two climate zones, alpine (>1980 meters) and non-alpine (<1980 meters). I created a shape file with two zones in the lambert project from the Daymet processing code in the GitHub file.  To do zonal statistics for one year I applied the attached code in the repository.

###################################################################################
2. Final file preparation for model input (including issues with leap year)
HBV-EC wants daily mean Rainfall, Snowfall, and Temperature, as well as monthly averages of temperature and evaporation over the period of record. 
•	Temperature - This attribute shows the temperature of the air for each altitude band, in degrees Celsius, over the simulated period.
•	Rainfall - This attribute shows the rainfall, in millimeters per simulation time step, for each area over the simulated period. 
•	Snowfall - This attribute shows the snowfall, in millimeters per simulation time step, for each area over the simulated period. The units for measurement of snowfall is given in millimeters of water equivalent, not centimeters of snowfall. In general, the water equivalent is considered to be one tenth of the measured depth of fresh snow.  NOTE Daymet gives SWE in kg/m^2 which is equal to 1 mm.
•	Evaporation - This attribute shows the evaporation rate, in millimeters per simulation time step, for each area over the simulated period.
