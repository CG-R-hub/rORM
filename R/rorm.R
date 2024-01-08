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


logging::basicConfig()
#' The package internal logger
#' @export
rorm_logger <- logging::getLogger("rORM")

#' RORM constant to define different table key settings like UNION or PRIMARY
#' @export
RORMPostgreSQLKeySetting <- list(UNIQUE = "UNIQUE",
                                 PRIMARY = "PRIMARY",
                                 NONE = "NONE")

#' Base class to connect to a specific given (PostgreSQL) DB table to run
#' standardized CRUD operations, like create, read, update and delete on this
#' table.
#' This base class is mainly the core to the RORM package and will be inherited
#' using the code generator to configure the ORM mapper for each table.
#' @export
RORMPostgreSQLBaseClass <- R6::R6Class(
  classname = "RORMPostgreSQLBaseClass",
  public = list(
    fields = NULL,
    key = NULL,
    table_name = NULL,
    key_setting = NULL,
    db_connection = NULL,
    initialize = function(conn) {
      if (any(is.null(c(self$field, self$table_name, self$key_setting)))) {
        stop("You try to initalize a base ORM class which is not possible.
             Please use a derivated class for initialization.")
      }
      self$db_connection <- conn
    },
    verbose = TRUE,
    dry_run = FALSE,
    delete = function(key) {
      key <- private$format_key_if_neccessary(key)

      private$validate_key_and_stop(key)

      sql <- glue::glue_sql('DELETE FROM "',
                            self$table_name,
                            '"  WHERE ', private$key_sql(key), .con = self$db_connection)
      if (self$verbose) {
        rorm_logger$info(sql)
      }
      if (self$dry_run) {
        return(sql)
      } else {
        return(DBI::dbExecute(self$db_connection, sql))
      }

    },
    get = function(key) {
      key <- private$format_key_if_neccessary(key)
      private$validate_key_and_stop(key)

      sql <- glue::glue_sql('SELECT * from "', self$table_name, '" WHERE ', private$key_sql(key), .con = self$db_connection)
      if (self$verbose) {
        rorm_logger$info(sql)
      }
      if (self$dry_run) {
        return(sql)
      } else {
        return(DBI::dbGetQuery(self$db_connection, sql))
      }
    },
    all = function() {
      sql <- glue::glue_sql('SELECT * from "', self$table_name, '"', .con = self$db_connection)
      if (self$verbose) {
        rorm_logger$info(sql)
      }

      if (self$dry_run) {
        return(sql)
      } else {
        return(DBI::dbGetQuery(self$db_connection, sql))
      }
    },
    insert = function(df) {
      col_names <- names(df)
      required_fields <- self$fields

      missing_cols <- setdiff(required_fields, col_names)
      for (missing_col in missing_cols) {
        df[, missing_col] <- NA
      }

      if (self$key_setting == RORMPostgreSQLKeySetting$PRIMARY) {
        required_fields <- c(required_fields, self$keys)
      }
      df <- df[required_fields]
      if (self$verbose) {
        rorm_logger$info(df)
      }


      if (self$dry_run) {
        return(df)
      } else {
        return(DBI::dbAppendTable(self$db_connection, self$table_name, df))
      }

    },
    update = function(key, df) {
      key <- private$format_key_if_neccessary(key)
      private$validate_key_and_stop(key)

      if (self$verbose) {
        rorm_logger$info(self$fields)
        rorm_logger$info(key)
      }


      key_names <- names(key)
      query_where <- c()
      for (i in seq_along(key_names)) {
        column <- key_names[i]
        query_where <- c(query_where, sprintf('"%s"=\'%s\'', column, key[[column]]))
      }


      df_names <- names(df)
      query_set <- c()
      for (i in seq_along(df_names)) {
        column <- df_names[i]
        query_set <- c(query_set, sprintf('"%s"=\'%s\'', column, df[[column]]))
      }

      sql <- glue::glue_sql(
        .con = self$db_connection,
        "UPDATE ", self$table_name, " SET ", paste(query_set, collapse = ","), " WHERE ", paste(query_where, collapse = ",")
      )

      if (self$verbose) {
        rorm_logger$info(sql)
      }


      if (self$dry_run) {
        return(sql)
      } else {
        return(DBI::dbExecute(self$db_connection, sql))
      }
    }
  ),
  private = list(
    format_key_if_neccessary = function(key) {
      if (self$key_setting == RORMPostgreSQLKeySetting$PRIMARY && !private$is_named(key)) {
        names(key) <- self$key
      }
      return(key)
    },
    validate_key_and_stop = function(key) {
      msg <- sprintf("You specified a key which is invalid. For the table '%s' these are the primariy / unique keys: (%s)", self$table_name, self$key)

      if (self$key_setting == RORMPostgreSQLKeySetting$NONE ||
          self$key_setting == RORMPostgreSQLKeySetting$UNIQUE) {
        # We need a named key otherwise we can not work
        if (!private$is_named(key)) {
          stop(msg)
        }
      } else if (self$key_setting == RORMPostgreSQLKeySetting$PRIMARY && length(key) != 1) {
        stop(msg)
      }
    },
    is_named = function(vector) {
      return(!is.null(names(vector)))
    },
    key_sql = function(key) {
      private$validate_key_and_stop(key)
      if (self$key_setting == RORMPostgreSQLKeySetting$PRIMARY) {
        if (!private$is_named(key)) {
          names(key) <- self$key
        }
      }



      key_names <- names(key)
      query_where <- c()
      for (i in seq_along(key_names)) {
        column <- key_names[i]

        query_where <- c(query_where, sprintf('"%s" = \'%s\'', column, key[[column]]))
      }
      return(query_where)
    }
  )
)

