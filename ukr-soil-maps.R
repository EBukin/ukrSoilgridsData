library(raster)
library(sf)
library(readr)
library(tidyverse)

ukr_admin <- 
  read_rds("data-raw/admin/ukr_admin0_country.rds") |> 
  st_transform(st_crs("+proj=igh +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")) |> 
  st_make_valid() |> 
  st_buffer(10000)


ukr_extent <- as(extent(st_bbox(ukr_admin)), 'SpatialPolygons')
crs(ukr_extent) <- "+proj=igh +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

# #  One trial ------------------------------------------------------------------
# link<-"/vsicurl/https://files.isric.org/soilgrids/latest/data/ocs/ocs_0-30cm_mean.vrt"
# one_layer <- raster(link)
# one_layer_croped <- crop(one_layer, ukr_extent)
# tifoptions <- c("COMPRESS=DEFLATE", "PREDICTOR=2", "ZLEVEL=6")
# writeRaster(one_layer_croped, "data-raw/ocs/ocs_0.30cm_mean.tif",
#             options = tifoptions, overwrite = FALSE)
# 
# library(stars)
# read_stars("data-raw/ocs/ocs_0.30cm_mean.tif") |> plot()

# # Most probable soil class
# ukr_extent2 <- 
#   ukr_admin |> st_transform(st_crs("+proj=longlat +datum=WGS84 +no_defs")) |> 
#   st_bbox() |> extent() |> as('SpatialPolygons')
# crs(ukr_extent2) <- "+proj=longlat +datum=WGS84 +no_defs"
# single_layer <- raster("https://files.isric.org/soilgrids/latest/data/wrb/MostProbable.vrt")
# single_layer <- crop(x = single_layer, y = ukr_extent2) 
# writeRaster(x = single_layer, "data-raw/ukr/MostProbable.tif", overwrite = TRUE)


# Loading all layers. --------------------------------------------------------
# data: https://files.isric.org/soilgrids/latest/data/
# description: https://www.isric.org/explore/soilgrids/faq-soilgrids#What_do_the_filename_codes_mean
# More descrition: https://www.isric.org/explore/soilgrids/faq-soilgrids#How_can_I_access_SoilGrids

base_url <- "/vsicurl/https://files.isric.org/soilgrids/latest/data"

layers_to_get <- c(
  "ocs_0-30cm_mean.vrt", # Organic carbon stocks	t/ha	10	kg/m²
  "ocd_0-5cm_mean.vrt", # Organic carbon density	hg/m³	10	kg/m³
  "ocd_5-15cm_mean.vrt", 
  "ocd_15-30cm_mean.vrt",
  "ocd_30-60cm_mean.vrt", 
  "ocd_30-60cm_mean.vrt", 
  "ocd_60-100cm_mean.vrt", 
  "ocd_100-200cm_mean.vrt",
  "bdod_0-5cm_mean.vrt", # Bulk density of the fine earth fraction	cg/cm³	100	kg/dm³
  "bdod_5-15cm_mean.vrt", 
  "bdod_15-30cm_mean.vrt",
  "bdod_30-60cm_mean.vrt", 
  "bdod_30-60cm_mean.vrt", 
  "bdod_60-100cm_mean.vrt", 
  "bdod_100-200cm_mean.vrt",
  "nitrogen_0-5cm_mean.vrt", # 	Total nitrogen (N)	cg/kg	100	g/kg
  "nitrogen_5-15cm_mean.vrt", 
  "nitrogen_15-30cm_mean.vrt",
  "nitrogen_30-60cm_mean.vrt", 
  "nitrogen_30-60cm_mean.vrt", 
  "nitrogen_60-100cm_mean.vrt", 
  "nitrogen_100-200cm_mean.vrt",
  "phh2o_0-5cm_mean.vrt", # 		Soil pH	pHx10	10	pH
  "phh2o_5-15cm_mean.vrt", 
  "phh2o_15-30cm_mean.vrt",
  "phh2o_30-60cm_mean.vrt", 
  "phh2o_30-60cm_mean.vrt", 
  "phh2o_60-100cm_mean.vrt", 
  "phh2o_100-200cm_mean.vrt",
  "sand_0-5cm_mean.vrt", # 		sand	Proportion of sand particles (> 0.05/0.063 mm) in the fine earth fraction	g/kg	10	g/100g (%)
  "sand_5-15cm_mean.vrt", 
  "sand_15-30cm_mean.vrt",
  "sand_30-60cm_mean.vrt", 
  "sand_30-60cm_mean.vrt", 
  "sand_60-100cm_mean.vrt", 
  "sand_100-200cm_mean.vrt",
  "silt_0-5cm_mean.vrt", # silt	Proportion of silt particles (≥ 0.002 mm and ≤ 0.05/0.063 mm) in the fine earth fraction	g/kg	10	g/100g (%)
  "silt_5-15cm_mean.vrt", 
  "silt_15-30cm_mean.vrt",
  "silt_30-60cm_mean.vrt", 
  "silt_30-60cm_mean.vrt", 
  "silt_60-100cm_mean.vrt", 
  "silt_100-200cm_mean.vrt",
  "clay_0-5cm_mean.vrt", # clay	Proportion of clay particles (< 0.002 mm) in the fine earth fraction	g/kg	10	g/100g (%)
  "clay_5-15cm_mean.vrt", 
  "clay_15-30cm_mean.vrt",
  "clay_30-60cm_mean.vrt", 
  "clay_30-60cm_mean.vrt", 
  "clay_60-100cm_mean.vrt", 
  "clay_100-200cm_mean.vrt",
  "cfvo_0-5cm_mean.vrt", # cfvo	Volumetric fraction of coarse fragments (> 2 mm)	cm3/dm3 (vol‰)	10	cm3/100cm3 (vol%)
  "cfvo_5-15cm_mean.vrt", 
  "cfvo_15-30cm_mean.vrt",
  "cfvo_30-60cm_mean.vrt", 
  "cfvo_30-60cm_mean.vrt", 
  "cfvo_60-100cm_mean.vrt", 
  "cfvo_100-200cm_mean.vrt",
  "cec_0-5cm_mean.vrt", # cec	Cation Exchange Capacity of the soil	mmol(c)/kg	10	cmol(c)/kg
  "cec_5-15cm_mean.vrt", 
  "cec_15-30cm_mean.vrt",
  "cec_30-60cm_mean.vrt", 
  "cec_30-60cm_mean.vrt", 
  "cec_60-100cm_mean.vrt", 
  "cec_100-200cm_mean.vrt"
)


layers_to_get |> 
  walk(~{
    local_link <- str_c(base_url, "/",
                        str_split(.x[[1]], "_")[[1]][[1]], "/",
                        .x)
    local_file <- str_c("data-raw/ukr/", str_replace(.x, "vrt", "tif"))
    one_layer <- raster(link)
    one_layer_croped <- crop(one_layer, ukr_extent)
    # tifoptions <- c("COMPRESS=DEFLATE", "PREDICTOR=2", "ZLEVEL=10")
    #options = tifoptions,
    writeRaster(one_layer_croped, local_file, overwrite = TRUE)

    # library(stars)
    # read_stars(local_file) |> plot()
  }, .progress = TRUE)
