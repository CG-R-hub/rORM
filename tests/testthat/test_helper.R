
testthat::test_that("vector_to_R_code", {
  # testthat::expect_equal(vector_to_R_code(1), "c(1)")
  testthat::expect_equal(vector_to_R_code("1"), "c(\"1\")")
  testthat::expect_equal(vector_to_R_code('"'), 'c("\\\"")')
})

testthat::test_that("str_camel_case", {
  testthat::expect_equal(str_camel_case("users"), "Users")
  testthat::expect_equal(str_camel_case("example_table"), "ExampleTable")
  testthat::expect_equal(str_camel_case("AnotherTable_WITH_a-name-"), "AnothertableWithAName")
  testthat::expect_equal(str_camel_case("TaBLE"), "Table")
  testthat::expect_equal(str_camel_case(""), "")

})
