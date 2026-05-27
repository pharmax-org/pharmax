test_that("public package registry lists the current proof slice", {
  packages <- px_public_packages()
  expect_equal(nrow(packages), 3)
  expect_setequal(packages$package, c("pharmax", "pharmax.viz", "pharmax.ml"))
})

test_that("public status includes limitations", {
  status <- px_public_status()
  expect_equal(status$package_count, 3)
  expect_match(status$limitation, "not validated")
})
