test_that("px_data_quality summarizes missingness and imputes numeric values", {
  data <- data.frame(WT = c(70, NA, 80), AGE = c(50, 60, 200))
  result <- px_data_quality(data, impute = "median")

  expect_s3_class(result, "pharmax_data_quality")
  expect_false(anyNA(result$data$WT))
  expect_true(all(c("missing", "outliers") %in% names(result)))
})

test_that("px_data_quality reports IQR outliers", {
  data <- data.frame(WT = c(70, 72, 71, 500), AGE = c(40, 42, 43, 41))
  result <- px_data_quality(data, outlier = "iqr")

  expect_true(result$outliers$outlier_n[result$outliers$column == "WT"] >= 1)
})
