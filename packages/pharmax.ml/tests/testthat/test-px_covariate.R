test_that("px_covariate ranks covariates", {
  set.seed(1)
  data <- data.frame(
    ETA_CL = rnorm(60),
    COV_WT = rnorm(60, 70, 10),
    COV_AGE = rnorm(60, 55, 12),
    COV_ALB = rnorm(60, 4, 0.4)
  )
  data$ETA_CL <- 0.6 * scale(data$COV_WT)[, 1] + rnorm(60, sd = 0.3)

  result <- px_covariate(data, method = "cor", n_top = 2)
  expect_s3_class(result, "pharmax_covariate")
  expect_true(all(c("parameter", "covariate", "importance") %in% names(result$ranking)))
  expect_true(all(c("seed", "parameters", "covariates") %in% names(result$context)))
})

test_that("px_covariate auto-detects ETA and COV columns", {
  set.seed(2)
  data <- data.frame(
    ETA_V = rnorm(50),
    COV_ALB = rnorm(50, 4.2, 0.3),
    COV_WT = rnorm(50, 70, 10),
    noise = rnorm(50)
  )
  data$ETA_V <- 0.8 * scale(data$COV_ALB)[, 1] + rnorm(50, sd = 0.2)

  result <- px_covariate(data, method = "auto", n_top = 2)

  expect_s3_class(result, "pharmax_covariate")
  expect_equal(unique(result$ranking$parameter), "ETA_V")
  expect_equal(result$ranking$covariate[1], "COV_ALB")
})

test_that("px_covariate supports all R-native methods", {
  set.seed(3)
  data <- data.frame(
    ETA_CL = rnorm(45),
    COV_WT = rnorm(45, 70, 10),
    COV_AGE = rnorm(45, 55, 12)
  )
  data$ETA_CL <- 0.7 * scale(data$COV_WT)[, 1] + rnorm(45, sd = 0.25)

  for (method in c("cor", "rf", "lasso", "elastic_net", "aalasso", "auto")) {
    result <- px_covariate(data, method = method, n_top = 2, seed = 99)
    expect_s3_class(result, "pharmax_covariate")
    expect_true(nrow(result$ranking) >= 1)
  }
})

test_that("px_covariate errors clearly when required columns are absent", {
  expect_error(px_covariate(data.frame(ID = 1:3)), "No parameter columns")
  expect_error(
    px_covariate(data.frame(ETA_CL = rnorm(3)), covariates = character()),
    "No covariate columns"
  )
})

test_that("synthetic ML workflow recovers known signal", {
  set.seed(2026)
  n <- 100
  data <- data.frame(
    COV_WT = rnorm(n, 70, 10),
    COV_AGE = rnorm(n, 55, 12),
    COV_ALB = rnorm(n, 4.2, 0.4)
  )
  data$ETA_CL <- 0.75 * scale(data$COV_WT)[, 1] + rnorm(n, sd = 0.25)

  quality <- px_data_quality(data, impute = "median")
  screen <- px_covariate(quality$data, method = "auto", n_top = 3, seed = 2026)
  intervals <- px_conformal(
    truth = data$ETA_CL[1:70],
    prediction = data$ETA_CL[1:70] + rnorm(70, sd = 0.2),
    new_prediction = c(-0.5, 0, 0.5),
    alpha = 0.1
  )

  expect_equal(screen$ranking$covariate[1], "COV_WT")
  expect_equal(nrow(intervals), 3)
  expect_true(all(intervals$interval_width > 0))
})
