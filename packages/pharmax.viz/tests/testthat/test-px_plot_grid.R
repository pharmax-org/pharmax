test_that("px_plot_grid composes plots", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(hp, mpg)) + ggplot2::geom_point()

  expect_s3_class(px_plot_grid(p1, p2, title = "Demo"), "patchwork")
  expect_s3_class(px_plot_grid(list(p1, p2), ncol = 1), "patchwork")
})

test_that("px_plot_grid requires plots", {
  expect_error(px_plot_grid(), "at least one plot")
})
