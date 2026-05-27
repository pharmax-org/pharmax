test_that("theme_pharmax returns a ggplot theme", {
  expect_s3_class(theme_pharmax(), "theme")
  expect_s3_class(theme_pharmax(mode = "dark"), "theme")
})

test_that("px_colors returns requested number of colors", {
  expect_length(px_colors(3), 3)
  expect_length(px_colors(8), 8)
  expect_length(px_colors(12), 12)
})

test_that("pharmax scales are ggplot scales", {
  expect_s3_class(scale_color_pharmax(), "ScaleDiscrete")
  expect_s3_class(scale_fill_pharmax(), "ScaleDiscrete")
})
