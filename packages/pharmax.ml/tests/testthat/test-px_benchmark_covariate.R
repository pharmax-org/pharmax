test_that("px_benchmark_covariate recovers a known signal", {
  benchmark <- px_benchmark_covariate(
    scenarios = c("known_signal", "missingness"),
    replicates = 2,
    n = 90,
    method = "cor",
    seed = 10
  )

  expect_s3_class(benchmark, "pharmax_covariate_benchmark")
  expect_true(all(c("results", "summary", "settings") %in% names(benchmark)))
  expect_true(
    benchmark$summary$signal_top_rate[benchmark$summary$scenario == "known_signal"] >= 0.5
  )
  expect_s3_class(plot(benchmark), "gg")
})

test_that("px_benchmark_covariate includes no-signal stress testing", {
  benchmark <- px_benchmark_covariate(
    scenarios = "no_signal",
    replicates = 2,
    n = 70,
    method = "cor",
    seed = 20
  )

  expect_equal(benchmark$summary$scenario, "no_signal")
  expect_true(benchmark$summary$signal_top_rate <= 1)
})
