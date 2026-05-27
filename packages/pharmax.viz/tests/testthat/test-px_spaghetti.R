test_that("px_spaghetti creates a ggplot", {
  data <- data.frame(
    ID = rep(1:3, each = 5),
    TIME = rep(c(0, 1, 2, 4, 8), 3),
    DV = abs(stats::rnorm(15, 5, 2)),
    EVID = rep(0, 15)
  )

  expect_s3_class(px_spaghetti(data), "gg")
  expect_s3_class(px_spaghetti(data, highlight_ids = 1), "gg")
})

test_that("px_spaghetti validates required columns", {
  expect_error(px_spaghetti(data.frame(ID = 1, TIME = 1)), "Missing required")
})
