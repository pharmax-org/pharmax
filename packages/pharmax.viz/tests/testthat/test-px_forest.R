test_that("px_forest creates a ggplot forest plot", {
  data <- data.frame(
    term = c("WT on CL", "AGE on V", "ALB on CL"),
    estimate = c(0.25, -0.10, 0.18),
    lower = c(0.05, -0.30, 0.02),
    upper = c(0.45, 0.10, 0.34)
  )

  expect_s3_class(px_forest(data), "gg")
  expect_s3_class(px_forest(data, mode = "dark"), "gg")
})

test_that("px_forest validates required columns", {
  expect_error(px_forest(data.frame(term = "WT")), "Missing required")
})
