test_that("px_simulate_covariates creates benchmark scenarios", {
  known <- px_simulate_covariates(n = 80, scenario = "known_signal", seed = 1)
  missing <- px_simulate_covariates(n = 80, scenario = "missingness", seed = 1)
  no_signal <- px_simulate_covariates(n = 80, scenario = "no_signal", seed = 1)

  expect_true(all(c("ETA_CL", "ETA_V", "COV_WT", "COV_ALB") %in% names(known)))
  expect_true(anyNA(missing$COV_WT))
  expect_true(is.na(attr(no_signal, "pharmax_signal")))
})
