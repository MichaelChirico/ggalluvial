context("stat-flow")

# weights are used but not returned

test_that("`stat_flow` weights computed variables but drops weight", {
  data <- expand.grid(alluvium = letters[1:3], x = 1:2)
  data$stratum <- LETTERS[c(1, 1, 2, 1, 2, 2)]
  data$y <- c(1, 2, 1, 3, 1, 2)
  data$weight <- c(.5, 1, 2.5, 2, 1.5, 1)
  comp <- as.data.frame(StatFlow$compute_panel(data))
  expect_equivalent(comp[with(comp, order(x, alluvium)), ]$n,
                    c(2.5, 1, 0.5, 1, 1.5, 2))
  expect_equivalent(comp[with(comp, order(x, alluvium)), ]$count,
                    c(2.5, 2, 0.5, 2, 1.5, 6))
  expect_equivalent(comp[with(comp, order(x, alluvium)), ]$prop,
                    c(9.5, 7.6, 1.9, 4, 3, 12) / 19)
  expect_null(comp$weight)
})

# reverse and absolute, negative values

test_that("`stat_flow` orders flows correctly with negative values", {
  data <- expand.grid(alluvium = letters[1:3], x = 1:2)
  data$stratum <- LETTERS[c(1, 1, 2)]
  data$y <- c(1, 1, 1, -1, 1, -1)
  # order by stratum, `reverse = TRUE`
  #ggplot(data, aes(x = x, stratum = stratum, alluvium = alluvium, y = y)) +
  #  geom_flow()
  comp <- StatFlow$compute_panel(data)
  expect_identical(comp[with(comp, order(x, alluvium)), ]$y,
                   c(1.5, 0.5, 2.5, -1.5, -0.5, 0.5))
  # order by stratum, `reverse = FALSE`
  #ggplot(data, aes(x = x, stratum = stratum, alluvium = alluvium, y = y)) +
  #  geom_flow(reverse = FALSE)
  comp <- StatFlow$compute_panel(data, reverse = FALSE)
  expect_identical(comp[with(comp, order(x, alluvium)), ]$y,
                   c(2.5, 0.5, 1.5, -1.5, -0.5, 0.5))
  # order by stratum, `reverse = FALSE, absolute = FALSE`
  #ggplot(data, aes(x = x, stratum = stratum, alluvium = alluvium, y = y)) +
  #  geom_flow(reverse = FALSE, absolute = FALSE)
  comp <- StatFlow$compute_panel(data, reverse = FALSE, absolute = FALSE)
  expect_identical(comp[with(comp, order(x, alluvium)), ]$y,
                   c(0.5, 2.5, 1.5, -1.5, -0.5, 0.5))
})

# aesthetic binding

test_that("`stat_flow` orders alluvia correctly according to `aes.bind`", {
  data <- expand.grid(alluvium = letters[1:4], x = 1:2)
  data$stratum <- LETTERS[c(1, 1, 1, 2, 2, 1, 3, 1)]
  data$y <- 1
  data$fill <- c("red", "blue", "blue", "blue",
                 "red", "blue", "blue", "blue")
  # order by index strata and linked strata (flows)
  #ggplot(data, aes(x = x, stratum = stratum, alluvium = alluvium, y = y)) +
  #  geom_flow(aes(fill = fill))
  comp <- StatFlow$compute_panel(data)
  expect_identical(comp[with(comp, order(x, alluvium)), ]$y,
                   c(2.5, 1.5, 0.5, 3.5, 1.5, 0.5, 2.5, 3.5))
  # order by index strata, linked strata (flows), and aesthetics
  #ggplot(data, aes(x = x, stratum = stratum, alluvium = alluvium, y = y)) +
  #  geom_flow(aes(fill = fill), aes.bind = "flows")
  comp <- StatFlow$compute_panel(data, aes.bind = "flows")
  expect_identical(comp[with(comp, order(x, alluvium)), ]$y,
                   c(1.5, 2.5, 0.5, 3.5, 1.5, 0.5, 2.5, 3.5))
  # cannot order by aesthetics before by linked strata (flows)
  expect_warning(StatFlow$compute_panel(data, aes.bind = "alluvia"), "flows")
})
