###################################################################################
# William Kleindl, PhD 
# University of Montana

###################################################################################
# Met file prep provided in the read-me and the attached code will walk through:
# 1.	Deriving daily means with zonal statistics
# 2.	Final file preparation for model input (including issues with leap years)

###################################################################################
#Set working directory home
library(rgdal)
library(maptools)
library(sp)
library(raster)
library(ncdf)
library(plyr)
library(sfsmisc)


#set new wd
wd<-setwd("D:/Publications/nf hydro/Climate Data/met data")
dir(wd)

#load raster brick and alpine/subalpine (combined)shapefile
climate <-readShapePoly("D:/Dropbox/publication/5th - Hydro Model North Fork/Data/Starvation/spatial data/IC-19 Lambert/IC_19_solo_lambert")

##############Precipitation#############
# Set up matrix with first year  
ras <-brick("D:/Research/Past research/Climate Data/Final Met/precipitation/prcp1980.tif")
# shapefile has to be rasterized to apply zonal function
climatezone <-rasterize(climate,ras)

#Apply zonal function and ignore NA to acquire means by zones
climatemean <-zonal(ras,climatezone,'mean',na.rm=T)
climatemean <-t(climatemean)
climatemean <-climatemean[-c(1,1),]
colnames(climatemean)<-c("Alpine","Sun-Alpine")
climatemeanbind <-climatemean

#run loop for following years. 
files<-list.files(wd, recursive=F)

yr=1981
#j increases by odd numbers to skip over the .xml files. 
j<-3
for(yr in 1981:2014){
  file<-sprintf('D:/Research/Past research/Climate Data/Final Met/precipitation/prcp%d.tif', yr)
  file<-brick(file)
  climatemean<-zonal(file,climatezone,fun='mean',na.rm=T)
  climatemean<-t(climatemean) 
  climatemean<-climatemean[-c(1,1),]
  climatemeanbind <-rbind(climatemeanbind,climatemean)
  j<-j+2
  yr<-yr+1
}
pptmeanbind <- round(climatemeanbind, digits = 3)

tail(pptmeanbind)

############## tmax #############
# Set up matrix with first year  
ras <-brick("D:/Research/Past research/Climate Data/Final Met/tmax/tmax1980.tif")
# shapefile has to be rasterized to apply zonal function
#climatezone<-rasterize(climate,ras)
#Set up matrix with first year
climatemean<-zonal(ras,climatezone,fun='mean',na.rm=T)
climatemean<-t(climatemean)
climatemean<-climatemean[-c(1,1),]
colnames(climatemean)<-c("Alpine","Sun-Alpine")
climatemeanbind <-climatemean
#run loop for following years. 
files<-list.files(wd, recursive=F)
yr=1981
#j increases by odd numbers to skip over the .xml files. 
j<-3
for(yr in 1981:2014){
  file<-sprintf('D:/Research/Past research/Climate Data/Final Met/tmax/tmax%d.tif', yr)
  file<-brick(file)
  climatemean<-zonal(file,climatezone,fun='mean',na.rm=T)
  climatemean<-t(climatemean) 
  climatemean<-climatemean[-c(1,1),]
  climatemeanbind<-rbind(climatemeanbind,climatemean)
  j<-j+2
  yr<-yr+1
}
tmaxmeanbind <- round(climatemeanbind, digits = 3)

tail(tmaxmeanbind)

############## tmin #############
# Set up matrix with first year  
ras<-brick("D:/Research/Past research/Climate Data/Final Met/tmin/tmin1980.tif")
# shapefile has to be rasterized to apply zonal function
climatezone<-rasterize(climate,ras)
#Set up matrix with first year
climatemean<-zonal(ras,climatezone,fun='mean',na.rm=T)
climatemean<-t(climatemean)
climatemean<-climatemean[-c(1,1),]
colnames(climatemean)<-c("Alpine","Sun-Alpine")
climatemeanbind <-climatemean
#run loop for following years. 
files<-list.files(wd, recursive=F)
yr=1981
#j increases by odd numbers to skip over the .xml files. 
j<-3
for(yr in 1981:2014){
  file<-sprintf('D:/Research/Past research/Climate Data/Final Met/tmin/tmin%d.tif', yr)
  file<-brick(file)
  climatemean<-zonal(file,climatezone,fun='mean',na.rm=T)
  climatemean<-t(climatemean) 
  climatemean<-climatemean[-c(1,1),]
  climatemeanbind<-rbind(climatemeanbind,climatemean)
  j<-j+2
  yr<-yr+1
}
tminmeanbind <- round(climatemeanbind, digits = 3)

tail (tminmeanbind)

#check that these are all the same length
dim(tminmeanbind)
dim(tmaxmeanbind)
dim(pptmeanbind)

############## Arrange data for HBV met files #############

#split alpine and subalpine 
tmaxalpine<-tmaxmeanbind[,1]
tmaxsubalpine<-tmaxmeanbind[,2]
tminalpine<-tminmeanbind[,1]
tminsubalpine<-tminmeanbind[,2]
pptalpine<-pptmeanbind[,1]
pptsubalpine <-pptmeanbind[,2]

#Set SWE to zero, 
swealpine <- c(1:12775)
swealpine <- swealpine*0
swesubalpine <- c(1:12775)
swesubalpine <- swesubalpine*0


#create surrogate for mean temp by 'averaging' daily max and daily min temp.  
meantempalpine<-((tmaxalpine+tminalpine)/2)
meantempsubalpine<-((tmaxsubalpine+tminsubalpine)/2)
meantempalpine <- round(meantempalpine, digits = 3)
meantempsubalpine<- round(meantempsubalpine, digits = 3)

#arrange alpine climate data 
climatealpine<-pptalpine
climatealpine<-cbind(climatealpine,swealpine)
climatealpine<-cbind(climatealpine,meantempalpine)

#arrange subalpine climate data 
climatesubalpine<-pptsubalpine
climatesubalpine<-cbind(climatesubalpine,swesubalpine)
climatesubalpine<-cbind(climatesubalpine,meantempsubalpine)

#load package sfsmisc to use empty.dimnames to strip all row and column labels still left from the data processing. 
#Then add column names just to track them and wil be erased later in the final met file.  
climatealpine<- empty.dimnames(climatealpine)
climatesubalpine<- empty.dimnames(climatesubalpine) 
colnames(climatealpine)<-c("PPT","SWE","Temp")
colnames(climatesubalpine)<-c("PPT","SWE","Temp") 

head(climatealpine)
head(climatesubalpine)

#write it out...
write.table(climatealpine,"D:/Publications/nf hydro/Climate Data/Starvation Met/starv_alp.txt")
write.table(climatesubalpine,"D:/Publications/nf hydro/Climate Data/Starvation Met/starv_subalp.txt")




