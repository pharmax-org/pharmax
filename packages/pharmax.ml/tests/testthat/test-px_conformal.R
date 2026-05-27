test_that("px_conformal returns prediction intervals", {
  result <- px_conformal(
    truth = c(1, 2, 3, 4),
    prediction = c(1.1, 1.8, 3.1, 3.9),
    new_prediction = c(2, 5),
    alpha = 0.1
  )

  expect_equal(nrow(result), 2)
  expect_true(all(result$lower <= result$prediction))
  expect_true(all(result$upper >= result$prediction))
})

test_that("px_conformal validates inputs", {
  expect_error(
    px_conformal(truth = c(1, 2), prediction = c(1), new_prediction = 1),
    "same length"
  )
  expect_error(
    px_conformal(truth = c(1, 2), prediction = c(1, 2), new_prediction = 1, alpha = 1),
    "between 0 and 1"
  )
})
