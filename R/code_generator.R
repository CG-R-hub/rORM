# Copyright (C) 2023 - 2024 Benjamin Manns
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


#' Generate the code to map (PostgreSQL) DB tables to a RORM model.
#'
#' @param con DB connection
#' @param prefix The prefix of the class and model variables, default is RORM
#'
#' @return R code in string format which can be evaluated
#' @export
#'
#' @examples
#' rorm_generate_code(con)
#'
#' rorm_generate_code(con, prefix = "DB")
rorm_generate_code <- function(con,
                               prefix = "RORM") {
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
    key <- vector_to_R_code(table_details$primary_keys$column_name)

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


#' Generate the RORM mapper classes / models codes and write it to a file
#' which can be included in the R project
#'
#' @param con DB connection
#' @param prefix The prefix of the class and model variables, default is RORM
#' @param filepath Path to source code
#'
#' @value writes the R code to a file
#' @export
#'
#' @examples
rorm_generate_code_to_file <- function(con,
                                       prefix = "RORM",
                                       filepath = "rorm_models.R") {
  write(rorm_generate_code(con = con, prefix = prefix), file = filepath)
}
