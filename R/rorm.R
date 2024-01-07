RORMPostgreSQLKeySetting <- list(UNIQUE = "UNIQUE", PRIMARY = "PRIMARY", NONE = "NONE")


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
        stop("You try to initalize a base ORM class which is not possible. Please use a derivated class for initialization.")
      }
      self$db_connection <- conn
    },
    verbose = TRUE,
    dry_run = FALSE,
    delete = function(key) {
      print("SQL")
      print(private$key_sql(key))





      key <- private$format_key_if_neccessary(key)

      private$validate_key_and_stop(key)

      sql <- glue::glue_sql('DELETE FROM "', self$table_name, '"  WHERE ', private$key_sql(key), .con = self$db_connection)
      if (self$verbose) {
        print(sql)
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
        print(sql)
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
        print(sql)
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
        print(df)
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
        print(self$fields)
        print(key)
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
        print(sql)
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
