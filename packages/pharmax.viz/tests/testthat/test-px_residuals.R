test_that("px_residuals creates a patchwork diagnostic panel", {
  data <- data.frame(
    TIME = rep(c(0.5, 1, 2, 4, 8), 4),
    PRED = seq(1, 20),
    CWRES = stats::rnorm(20)
  )

  expect_s3_class(px_residuals(data), "patchwork")
  expect_s3_class(px_residuals(data[, "CWRES", drop = FALSE]), "patchwork")
})

test_that("px_residuals requires a residual column", {
  expect_error(px_residuals(data.frame(TIME = 1:3)), "No residual column")
})
