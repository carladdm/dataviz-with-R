# Constantes y utilidades del proyecto de embalses ---------------------------

EMBALSES_URL <- paste0(
  "https://www.miteco.gob.es/content/dam/miteco/es/agua/temas/",
  "evaluacion-de-los-recursos-hidricos/boletin-hidrologico/",
  "Historico-de-embalses/BD-Embalses.zip"
)

DIR_RAW <- here::here("data", "raw")
DIR_PROCESSED <- here::here("data", "processed")
EMBALSES_MDB <- here::here("data", "raw", "BD-Embalses.mdb")
EMBALSES_RAW <- here::here("data", "processed", "embalses_raw.rds")

PERCENTILE_BREAKS <- c(0, 0.05, 0.10, 0.25, 0.40, 0.60, 0.75, 0.90, 0.95, 1)

#' Umbral usado para "más seco de lo normal": percentil 40.
DRY_MAX <- 0.40

#' Lee el dato crudo ya descargado por scripts/fetch_embalses.R.
read_embalses <- function() {
  if (!file.exists(EMBALSES_RAW)) {
    stop(
      "No existe data/processed/embalses_raw.rds. ",
      "Ejecuta primero: Rscript scripts/fetch_embalses.R",
      call. = FALSE
    )
  }
  readr::read_rds(EMBALSES_RAW)
}

#' Deriva año hidrológico, percentil por embalse y categoría.
#'
#' El percentil se calcula respecto al histórico completo disponible en el
#' archivo (baseline fijo 1988-...), no con una ventana acumulada. Esto debe
#' interpretarse como "posición respecto al histórico", no como pronóstico
#' disponible en cada fecha.
prepare_embalses <- function(emb_raw) {
  emb_raw %>%
    dplyr::mutate(
      hy = ifelse(lubridate::month(fecha) >= 10,
                  lubridate::year(fecha) + 1L,
                  lubridate::year(fecha)),
      agua_perc = ave(
        agua_actual,
        embalse_nombre,
        FUN = function(x) {
          ok <- !is.na(x)
          out <- rep(NA_real_, length(x))
          if (any(ok)) out[ok] <- stats::ecdf(x[ok])(x[ok])
          out
        }
      ),
      agua_cat = cut(agua_perc, PERCENTILE_BREAKS, include.lowest = TRUE)
    )
}

#' Proporción de registros por debajo del percentil 40.
share_dry <- function(data, group_vars = character()) {
  data %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) %>%
    dplyr::summarise(
      n = dplyr::n(),
      n_seco = sum(agua_perc < DRY_MAX, na.rm = TRUE),
      rel_seco = n_seco / n,
      .groups = "drop"
    )
}
