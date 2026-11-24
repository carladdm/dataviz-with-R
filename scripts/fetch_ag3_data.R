#!/usr/bin/env Rscript
# Descarga y cachea los datos del proyecto 2: lagos del SNIG, MDT y Eurostat.

suppressWarnings(suppressPackageStartupMessages({
  library(here)
  library(sf)
  library(terra)
  library(elevatr)
  library(giscoR)
  library(eurostat)
  library(dplyr)
  library(readr)
}))

DIR_RAW <- here::here("data", "raw")
DIR_PROCESSED <- here::here("data", "processed")
dir.create(DIR_RAW, showWarnings = FALSE, recursive = TRUE)
dir.create(DIR_PROCESSED, showWarnings = FALSE, recursive = TRUE)

LAKES_URL <- "https://sniambgeoviewer.apambiente.pt/Geodocs/shpzips/vw_lag_aguas_publicas.zip"
LAKES_RDS <- here::here("data", "processed", "lagos_portugal.rds")
MDT_TIF <- here::here("data", "processed", "mdt_portugal.tif")
BEDS_RDS <- here::here("data", "processed", "camas_hospitalarias.rds")
NUTS_RDS <- here::here("data", "processed", "nuts2_2013.rds")

# --- Lagos / lagunas (SNIG) -------------------------------------------------
if (!file.exists(LAKES_RDS)) {
  message("Descargando capa de lagos del SNIG ...")
  zip <- here::here("data", "raw", "vw_lag_aguas_publicas.zip")
  if (!file.exists(zip)) {
    download.file(LAKES_URL, zip, mode = "wb", quiet = TRUE)
  }
  shp <- list.files(DIR_RAW, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
  if (length(shp) == 0) {
    unzip(zip, exdir = here::here("data", "raw", "snig"))
    shp <- list.files(here::here("data", "raw", "snig"),
                      pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
  }
  lagos <- sf::st_read(shp[1], quiet = TRUE)
  readr::write_rds(lagos, LAKES_RDS)
  message("Guardado: ", LAKES_RDS)
}

# --- Modelo digital del terreno --------------------------------------------
if (!file.exists(MDT_TIF)) {
  lagos <- readr::read_rds(LAKES_RDS)
  pt <- giscoR::gisco_get_countries(country = "Portugal", resolution = "03")

  message("Descargando MDT (z = 10); puede tardar varios minutos ...")
  mdt <- suppressWarnings(elevatr::get_elev_raster(pt, z = 10))
  mdt <- terra::rast(mdt) %>%
    terra::mask(terra::vect(pt)) %>%
    terra::project(terra::crs(lagos)) %>%
    terra::aggregate(fact = 10, fun = mean)

  names(mdt) <- "alt"
  terra::writeRaster(mdt, MDT_TIF, overwrite = TRUE)
  message("Guardado: ", MDT_TIF)
}

# --- Camas hospitalarias (Eurostat) ----------------------------------------
if (!file.exists(BEDS_RDS) || !file.exists(NUTS_RDS)) {
  # hlth_rs_bdsrg es histórico. 2013 es el último año con cobertura amplia
  # en NUTS-2 para la unidad P_HTHAB (por 100.000 habitantes).
  anio <- "2013"
  message("Descargando Eurostat hlth_rs_bdsrg (", anio, ") ...")
  camas <- eurostat::get_eurostat("hlth_rs_bdsrg", time_format = "raw") %>%
    filter(unit == "P_HTHAB", facility == "HBEDT", TIME_PERIOD == anio) %>%
    distinct(geo, values)

  if (anyDuplicated(camas$geo)) {
    stop("Quedan regiones duplicadas en el join de Eurostat.", call. = FALSE)
  }

  geo <- eurostat::get_eurostat_geospatial(
    nuts_level = 2, year = anio, resolution = "20"
  )

  readr::write_rds(camas, BEDS_RDS)
  readr::write_rds(geo, NUTS_RDS)
  message("Guardado: ", BEDS_RDS, " y ", NUTS_RDS)
}
