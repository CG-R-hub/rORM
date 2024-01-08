RORMAccountClass <- R6::R6Class(
  classname = 'RORMAccountClass',
  inherit = RORMPostgreSQLBaseClass,
  public = list(
    fields = c("user_id", "prename", "name", "email", "last_login", "last_password_change"),
    key = c("user_id"),
    table_name = 'account',
    key_setting = 'PRIMARY'
  )
)

RORMAccountModel <- RORMAccountClass$new(rorm_connect_to_test_db())

# In dry run the SQL is only generated and will be return, no execution is
# done
RORMAccountModel$dry_run <- TRUE
RORMAccountModel$verbose <- FALSE

testthat::test_that("RORMPostgreSQLBaseClass - all() method", {
  sql <- RORMAccountModel$all()
  testthat::expect_equal(as.character(sql), "SELECT * from \"account\"")
})

testthat::test_that("RORMPostgreSQLBaseClass - get() method", {
  sql <- RORMAccountModel$get(1)
  testthat::expect_equal(as.character(sql), 'SELECT * from "account" WHERE "user_id" = \'1\'')
})

testthat::test_that("RORMPostgreSQLBaseClass - insert() method", {
  df <- RORMAccountModel$insert(data.frame(email = "example_email@exampledomain.com"))

  # missing fields will be filled up with NA which is NULL in the DB table
  expected_df <- data.frame(
    user_id  = NA,
    prename = NA,
    name = NA,
    email = "example_email@exampledomain.com",
    last_login = NA,
    last_password_change = NA
  )

  testthat::expect_equal(df, expected_df)
})


testthat::test_that("RORMPostgreSQLBaseClass - update() method", {
  sql <- RORMAccountModel$update(1, data.frame(email = "example_email@exampledomain.com", prename="Alan"))
  testthat::expect_equal(as.character(sql), 'UPDATE account SET "email"=\'example_email@exampledomain.com\',"prename"=\'Alan\' WHERE "user_id"=\'1\'')
})

testthat::test_that("RORMPostgreSQLBaseClass - delete() method", {
  sql <- RORMAccountModel$delete(1)
  testthat::expect_equal(as.character(sql), 'DELETE FROM "account"  WHERE "user_id" = \'1\'')
})


testthat::test_that("RORMPostgreSQLKeySetting", {
  testthat::expect_equal(RORMPostgreSQLKeySetting$UNIQUE, "UNIQUE")
  testthat::expect_equal(RORMPostgreSQLKeySetting$PRIMARY , "PRIMARY")
  testthat::expect_equal(RORMPostgreSQLKeySetting$NONE, "NONE")
})

rm(RORMAccountClass)
rm(RORMAccountModel)
