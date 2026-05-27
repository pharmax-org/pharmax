test_that("px_npde creates a patchwork diagnostic panel", {
  data <- data.frame(
    TIME = rep(c(0.5, 1, 2, 4, 8), 8),
    PRED = seq(1, 40),
    NPDE = stats::rnorm(40)
  )

  expect_s3_class(px_npde(data), "patchwork")
  expect_s3_class(px_npde(data[, "NPDE", drop = FALSE]), "patchwork")
})

test_that("px_npde validates required columns", {
  expect_error(px_npde(data.frame(TIME = 1:3)), "Missing required")
})
