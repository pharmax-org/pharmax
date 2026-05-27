test_that("px_gof creates a patchwork plot", {
  data <- data.frame(
    DV = c(5, 8, 6, 3, 1),
    PRED = c(4.5, 7.5, 5.8, 3.2, 1.1),
    IPRED = c(5.1, 8.2, 5.9, 2.9, 0.9),
    CWRES = stats::rnorm(5),
    TIME = c(0.5, 1, 2, 4, 8),
    EVID = rep(0, 5)
  )

  expect_s3_class(px_gof(data), "patchwork")
})

test_that("px_gof validates required columns", {
  expect_error(px_gof(data.frame(DV = 1)), "Missing required")
})
