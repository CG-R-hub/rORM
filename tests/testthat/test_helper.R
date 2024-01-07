# this will be generated with code generator
# the idea is to have a base class which handle many situations
# then the code generator only creates the inherit classes with hopefully only need to specifiy table names, col names and primary keys

# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'
testthat::test_that("vector_to_R_code", {
  testthat::expect_equal(vector_to_R_code(1), "c(\"1\")")
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
