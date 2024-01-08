testthat::test_that("rorm_extract_db_structure_table data table", {
  con <- rorm_connect_to_test_db()
  rorm_initialize_database_with_testdata(con)

  db_structure <- rorm_extract_db_structure_table(con, "beaver")

  testthat::expect_setequal(names(db_structure), c("primary_keys", "fields"))
  testthat::expect_equal(nrow(db_structure$primary_keys), 0)

  testthat::expect_setequal(db_structure$fields, c("day", "time", "temp", "activ"))
  rorm_cleanup_database_from_testdata(con)
})


testthat::test_that("rorm_extract_db_structure_table primary keys", {
  con <- rorm_connect_to_test_db()
  rorm_initialize_database_with_testdata(con)

  db_structure <- rorm_extract_db_structure_table(con, "chicken_weight")

  testthat::expect_setequal(names(db_structure), c("primary_keys", "fields"))
  testthat::expect_equal(
    db_structure$primary_keys,
    data.frame(column_name = "meassue_id", data_type = "SERIAL")
  )

  testthat::expect_setequal(db_structure$fields, c("meassue_id", "weight", "time", "chicken_id", "diet_id"))
  rorm_cleanup_database_from_testdata(con)
})
