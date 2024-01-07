# rORM
ORM (Object Relational Mapper) for R Language 



## Examples

```R
RORMSystemUserClass <- R6::R6Class(
  classname = "RORMSystemUserClass",
  inherit = RORMPostgreSQLBaseClass,
  public = list(
    fields = c("given_name", "familiy_name"),
    key = c("user_id"),
    table_name = "system_user",
    key_setting = RORMPostgreSQLKeySetting$PRIMARY
  )
)



RORMDumpClass <- R6::R6Class(
  classname = "RORMDumpClass",
  inherit = RORMPostgreSQLBaseClass,
  public = list(
    fields = c("given_name", "familiy_name"),
    key = c(),
    table_name = "dump",
    key_setting = RORMPostgreSQLKeySetting$NONE
  )
)






DBI::dbGetQuery(con, "SELECT * from information_schema.table_constraints")


con <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  user = "postgres",
  password = "password",
  port = "5432",
  host = "127.0.0.1"
)
RORMSystemUserModel <- RORMSystemUserClass$new(con)
RORMSystemUserModel$update(1, data.frame("given_name" = "AAA"))


RORMSystemUserModel$insert(data.frame("given_name" = "AAA", "user_id" = 1)) # "user_id will be deleted form the data frame because it is a primary key and the id is created




RORMSystemUserModel$delete(c("user_id" = 1))
 

RORMSystemUserModel$insert(data.frame("given_name" = "AAA", "user_id" = 1)) # "user_id will be deleted form the data frame because it is a primary key and the id is created

RORMSystemUserModel$all()
RORMSystemUserModel$get(c("user_id" = 1))




cat(rorm_generate_code(con))
rorm_generate_code_to_file(con)
```
