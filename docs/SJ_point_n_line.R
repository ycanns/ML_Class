# THIS CODE IS PREPARED FOR COMBINING(SPATIAL JOIN) BETWEEN POINT(CSV FILE) AND LINE(SHAPE FILE)
# Code prepared by YCANNS (2022.12.06)

dir <- "~/Desktop/Point_line/"
setwd(dir)


# Change Encoding & Language
Sys.getlocale()
Sys.setlocale("LC_ALL","C") # remove language (temporary)
Sys.setlocale('LC_ALL' , 'ko_KR.UTF-8')


# define libraries
if(!require("pacman")){install.packages("pacman")}
libraries <- c("sp", "rgdal", "sf", "raster", "dplyr", "data.table", "tidyverse")

#lapply(libraries, library, character.only = TRUE) >> Check packages
p_load(libraries,character.only=TRUE)





# loading point data and line(shape file)
point_data <- read_delim(paste0(dir, "test.csv"), ",", 
           escape_double = FALSE, trim_ws = TRUE, col_names = TRUE,
           locale=locale(encoding="cp949"))

line <- readOGR(dsn = paste0(dir,"/link/."), layer="road", use_iconv=TRUE, encoding = "UTF-8")






# Convert point data to spatialpoint using latlong information
point_data_new <- SpatialPoints(point_data[, c("long", "lat")], proj4string=CRS("+init=epsg:4326"))  

# Convert Spatial data to sf format
point_sfdf = st_sf(id_pt = 1:length(point_data_new), geom = st_as_sfc(point_data_new))
line_sf = st_sf(id_ln = 1:length(line), geom = st_as_sfc(line))

# get nearest line information for each point (This step might take some time....)
point_sfdf_w_pts = st_join(point_sfdf, line_sf, join = st_nearest_feature)




# Converting and Cleaning
line_df <- line@data
line_df$id_ln <- seq(1,nrow(line_df))
SJ_points <- cbind(point_data, point_sfdf_w_pts[,c("id_ln")])
SJ_points <- left_join(SJ_points, line_df, by= "id_ln")
SJ_points$id_ln <- NULL; SJ_points$geom <- NULL; 

# remove NA values
SJ_points[is.na(SJ_points)] <- 0



# Exporting final data with encoding + csv format
con <- file(paste0(dir, "SJ_points.csv"), encoding = "UTF-8")
write.csv(SJ_points, con, row.names=FALSE)



