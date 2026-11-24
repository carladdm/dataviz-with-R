#' Tema compartido por los informes
#'
#' Theme mínimo con leyenda horizontal y ejes sobrios, inspirado en el
#' estilo usado en las actividades guiadas.
theme_informe <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title.position = "top",
      legend.title = ggplot2::element_text(hjust = 0),
      legend.direction = "horizontal",
      legend.key.height = grid::unit(0.3, "lines"),
      legend.key.width = grid::unit(3, "lines"),
      axis.ticks = ggplot2::element_line(),
      axis.ticks.length = grid::unit(0.5, "mm"),
      plot.margin = ggplot2::margin(10, 10, 20, 10)
    )
}
