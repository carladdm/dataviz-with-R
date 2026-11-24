#!/usr/bin/env Rscript
# Descarga el histórico de embalses de MITECO y guarda una copia cruda en RDS.
# Requiere el controlador ODBC "Microsoft Access Driver (*.mdb, *.accdb)" de 64 bits.

suppressWarnings(suppressPackageStartupMessages({
  library(here)
  library(dplyr)
  library(readr)
  library(janitor)
  library(RODBC)
}))

source(here("R", "embalses.R"))

dir.create(DIR_RAW, showWarnings = FALSE, recursive = TRUE)
dir.create(DIR_PROCESSED, showWarnings = FALSE, recursive = TRUE)

if (!file.exists(EMBALSES_MDB)) {
  message("Descargando BD-Embalses.zip ...")
  tmp <- tempfile(fileext = ".zip")
  on.exit(unlink(tmp), add = TRUE)
  download.file(EMBALSES_URL, tmp, mode = "wb", quiet = TRUE)
  unzip(tmp, files = "BD-Embalses.mdb", exdir = DIR_RAW)
}

# Conexión: el conductor puede cambiar de nombre entre versiones de Windows.
con <- suppressWarnings(
  try(
    RODBC::odbcDriverConnect(paste0(
      "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",
      normalizePath(EMBALSES_MDB, winslash = "/")
    )),
    silent = TRUE
  )
)

if (inherits(con, "try-error") || !inherits(con, "RODBC")) {
  stop(
    "No se pudo abrir el MDB con el controlador Access de 64 bits. ",
    "Instala 'Microsoft Access Database Engine 2016 Redistributable' ",
    "(64 bits) o coloca manualmente BD-Embalses.mdb en data/raw/ y ",
    "asegúrate de que el controlador esté registrado.",
    call. = FALSE
  )
}
on.exit(RODBC::odbcClose(con), add = TRUE)

tablas <- RODBC::sqlTables(con)$TABLE_NAME
tablas_emb <- grep("Datos Embalses", tablas, value = TRUE)
if (length(tablas_emb) == 0) {
  stop("No se encontró la tabla de embalses. Tablas disponibles: ",
       paste(tablas, collapse = ", "), call. = FALSE)
}
tabla <- sort(tablas_emb)[length(tablas_emb)]
message("Leyendo tabla: ", tabla)

emb <- RODBC::sqlFetch(con, tabla) %>%
  janitor::clean_names() %>%
  mutate(
    across(
      starts_with("agua"),
      ~ readr::parse_number(
        as.character(.x),
        locale = readr::locale(decimal_mark = ",", grouping_mark = ".")
      )
    )
  )

if (!inherits(emb$fecha, "Date")) {
  emb$fecha <- lubridate::ymd(as.character(emb$fecha))
}

readr::write_rds(emb, EMBALSES_RAW)
message("Guardado: ", EMBALSES_RAW, " (", nrow(emb), " filas)")
