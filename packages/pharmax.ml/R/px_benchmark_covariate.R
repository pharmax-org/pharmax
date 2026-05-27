# Purpose: Repeated synthetic benchmark for covariate screening workflows
# Internal/exported: exported

#' Benchmark covariate screening on synthetic scenarios
#'
#' @param scenarios Scenario names passed to [px_simulate_covariates()].
#' @param replicates Number of replicates per scenario.
#' @param n Number of rows per replicate.
#' @param method Screening method passed to [px_covariate()].
#' @param n_top Number of top covariates to retain.
#' @param seed Random seed.
#' @return A `pharmax_covariate_benchmark` object.
#' @export
px_benchmark_covariate <- function(scenarios = c(
                                     "known_signal",
                                     "no_signal",
                                     "correlated",
                                     "missingness"
                                   ),
                                   replicates = 5L,
                                   n = 120L,
                                   method = "auto",
                                   n_top = 5L,
                                   seed = 2026L) {
  rows <- purrr::map_dfr(scenarios, function(scenario) {
    purrr::map_dfr(seq_len(replicates), function(replicate_id) {
      data <- px_simulate_covariates(
        n = n,
        scenario = scenario,
        seed = seed + replicate_id + match(scenario, scenarios) * 1000
      )
      quality <- px_data_quality(data, impute = "median")
      screen <- px_covariate(quality$data, method = method, n_top = n_top, seed = seed)
      eta_cl <- screen$ranking[screen$ranking$parameter == "ETA_CL", , drop = FALSE]
      signal_rank <- eta_cl$rank[eta_cl$covariate == "COV_WT"]
      if (length(signal_rank) == 0) {
        signal_rank <- NA_integer_
      }

      tibble::tibble(
        scenario = scenario,
        replicate = replicate_id,
        top_covariate = eta_cl$covariate[[1]],
        top_importance = eta_cl$importance[[1]],
        signal_rank = as.integer(signal_rank[[1]]),
        recovered_signal = isTRUE(signal_rank[[1]] == 1L),
        missing_cells = sum(is.na(data))
      )
    })
  })

  summary <- rows |>
    dplyr::group_by(.data$scenario) |>
    dplyr::summarise(
      replicates = dplyr::n(),
      signal_top_rate = mean(.data$recovered_signal, na.rm = TRUE),
      median_signal_rank = stats::median(.data$signal_rank, na.rm = TRUE),
      mean_top_importance = mean(.data$top_importance, na.rm = TRUE),
      .groups = "drop"
    )

  structure(
    list(
      results = rows,
      summary = summary,
      settings = list(
        scenarios = scenarios,
        replicates = replicates,
        n = n,
        method = method,
        n_top = n_top,
        seed = seed
      )
    ),
    class = "pharmax_covariate_benchmark"
  )
}

#' @export
print.pharmax_covariate_benchmark <- function(x, ...) {
  cat("pharmax covariate benchmark\n\n")
  print(x$summary, n = nrow(x$summary))
  cat("\nInterpretation: synthetic evidence for screening behavior, not clinical validation.\n")
  invisible(x)
}

#' @export
plot.pharmax_covariate_benchmark <- function(x, ...) {
  ggplot2::ggplot(
    x$summary,
    ggplot2::aes(x = .data$scenario, y = .data$signal_top_rate)
  ) +
    ggplot2::geom_col(fill = "#008f5d", width = 0.72) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(
      title = "Synthetic Covariate Benchmark",
      subtitle = "Known-signal recovery across synthetic stress-test scenarios",
      x = "Scenario",
      y = "Known signal ranked first"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 16),
      plot.subtitle = ggplot2::element_text(color = "grey35"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank()
    )
}
