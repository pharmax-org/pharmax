test_that("px_ensemble averages numeric predictions", {
  result <- px_ensemble(c(1, 2, 3), c(3, 4, 5))
  expect_equal(result, c(2, 3, 4))

  weighted <- px_ensemble(c(1, 2), c(3, 4), weights = c(0.25, 0.75))
  expect_equal(weighted, c(2.5, 3.5))
})

test_that("px_ensemble rejects invalid inputs", {
  expect_error(px_ensemble(c("a", "b"), c("c", "d")), "numeric")
  expect_error(px_ensemble(c(1, 2), c(3, 4), weights = c(1, 2, 3)), "weights")
})
