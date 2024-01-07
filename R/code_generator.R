#' Title
#'
#' @param con
#' @param prefix
#'
#' @return
#' @export
#'
#' @examples
rorm_generate_code <- function(con, prefix="RORM") {
  generated_code <- ""
  for (table_name in DBI::dbListTables(con)) {
    table_details <- rorm_extract_pg_structure_table(con, table_name)
    classname <- sprintf("%s%sClass", prefix, str_camel_case(table_name))

    if (nrow(table_details$primary_keys) == 1) {
      key_setting <- RORMPostgreSQLKeySetting$PRIMARY
    } else if (nrow(table_details$primary_keys) > 1) {
      key_setting <- RORMPostgreSQLKeySetting$UNIQUE
    } else {
      key_setting <- RORMPostgreSQLKeySetting$NONE
    }

    # TODO in a helper function
    fields <- vector_to_R_code(table_details$fields)
    key <-vector_to_R_code(table_details$primary_keys$column_name)

    modelname <- sprintf("%s%sModel", prefix, str_camel_case(table_name))


    code <- glue::glue("
\n
{classname} <- R6::R6Class(
  classname = '{classname}',
  inherit = RORMPostgreSQLBaseClass,
  public = list(
    fields = ", fields, ",
    key = ", key, ",
    table_name = '{table_name}',
    key_setting = '{key_setting}'
  )
)

{modelname} <- {classname}$new(con)
")


    generated_code <- paste0(generated_code, code)

  }
  return(generated_code)
}


#' Title
#'
#' @param con
#' @param prefix
#' @param filepath
#'
#' @return
#' @export
#'
#' @examples
rorm_generate_code_to_file <- function(con, prefix="RORM", filepath = "rorm_classes.R") {
write(rorm_generate_code(con = con, prefix = prefix), file = filepath)
}

