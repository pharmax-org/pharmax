test_that("px_calibrate_conformal summarizes coverage and interval width", {
  truth <- c(1, 2, 3, 4)
  result <- px_calibrate_conformal(
    truth = truth,
    lower = truth - 0.5,
    upper = truth + 0.5,
    prediction = truth,
    alpha = 0.1
  )

  expect_s3_class(result, "pharmax_conformal_calibration")
  expect_equal(result$summary$empirical_coverage, 1)
  expect_true(result$summary$mean_interval_width > 0)
})

test_that("px_calibrate_conformal validates vector lengths", {
  expect_error(
    px_calibrate_conformal(truth = c(1, 2), lower = 1, upper = c(2, 3)),
    "same length"
  )
  expect_error(
    px_calibrate_conformal(truth = c(1, 2), lower = c(0, 1), upper = c(2, 3), prediction = 1),
    "match the length"
  )
})
