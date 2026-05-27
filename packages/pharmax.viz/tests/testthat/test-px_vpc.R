test_that("px_vpc creates a ggplot VPC", {
  set.seed(1)
  data <- data.frame(
    TIME = rep(c(0.5, 1, 2, 4, 8), each = 20),
    DV = abs(stats::rnorm(100, 4, 1)),
    SIM = abs(stats::rnorm(100, 4.2, 1.1))
  )

  expect_s3_class(px_vpc(data), "gg")
  expect_s3_class(px_vpc(data, bins = 3, mode = "dark"), "gg")
})

test_that("px_vpc validates inputs", {
  expect_error(px_vpc(data.frame(TIME = 1, DV = 1)), "Missing required")
  expect_error(
    px_vpc(data.frame(TIME = 1, DV = 1, SIM = 1), probs = c(0.1, 0.5)),
    "three probabilities"
  )
})
