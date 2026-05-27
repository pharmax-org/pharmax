test_that("px_ml_report returns structured decision-support evidence", {
  data <- px_simulate_covariates(n = 80, scenario = "known_signal", seed = 30)
  quality <- px_data_quality(data, impute = "median")
  screen <- px_covariate(quality$data, method = "cor", n_top = 3, seed = 30)
  calibration <- px_calibrate_conformal(
    truth = data$ETA_CL[1:20],
    lower = data$ETA_CL[1:20] - 0.4,
    upper = data$ETA_CL[1:20] + 0.4,
    prediction = data$ETA_CL[1:20],
    alpha = 0.1
  )

  report <- px_ml_report(
    screen,
    quality = quality,
    calibration = calibration,
    context = list(context_of_use = "Synthetic package test")
  )

  expect_s3_class(report, "pharmax_ml_report")
  expect_true(all(c("top_signals", "limitations", "human_oversight", "context") %in% names(report)))
  expect_match(report$human_oversight, "human-reviewed")
  expect_equal(report$context$context_of_use, "Synthetic package test")
})

test_that("px_ml_report validates input class", {
  expect_error(px_ml_report(data.frame()), "pharmax_covariate")
})
