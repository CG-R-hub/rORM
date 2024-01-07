testthat::test_that("rorm_extract_pg_structure_table data table", {
  con <- rorm_connect_to_test_db()
  rorm_initialize_database_with_testdata(con)

  pg_structure <- rorm_extract_pg_structure_table(con, "beaver")

  testthat::expect_setequal(names(pg_structure), c("primary_keys", "fields"))
  testthat::expect_equal(nrow(pg_structure$primary_keys), 0)

  testthat::expect_setequal(pg_structure$fields, c("day", "time", "temp", "activ"))
  rorm_cleanup_database_from_testdata(con)
})


testthat::test_that("rorm_extract_pg_structure_table primary keys", {
  con <- rorm_connect_to_test_db()
  rorm_initialize_database_with_testdata(con)

  pg_structure <- rorm_extract_pg_structure_table(con, "chicken_weight")

  testthat::expect_setequal(names(pg_structure), c("primary_keys", "fields"))
  testthat::expect_equal(
    pg_structure$primary_keys,
    data.frame(column_name = "meassue_id", data_type = "integer")
  )

  testthat::expect_setequal(pg_structure$fields, c("meassue_id", "weight", "time", "chicken_id", "diet_id"))
  rorm_cleanup_database_from_testdata(con)
})
