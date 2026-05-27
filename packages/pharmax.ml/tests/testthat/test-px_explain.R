test_that("px_explain returns sorted permutation importance", {
  set.seed(4)
  data <- data.frame(
    COV_WT = rnorm(80, 70, 10),
    COV_AGE = rnorm(80, 55, 12)
  )
  truth <- 0.8 * scale(data$COV_WT)[, 1] + rnorm(80, sd = 0.2)
  model <- ranger::ranger(x = data, y = truth, num.trees = 100, seed = 4)

  explanation <- px_explain(model, data = data, truth = truth, seed = 4)

  expect_true(all(c("feature", "importance", "metric") %in% names(explanation)))
  expect_equal(explanation$feature[1], "COV_WT")
  expect_true(all(diff(explanation$importance) <= 0))
})
