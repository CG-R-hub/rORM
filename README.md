# rORM (for PostgreSQL)

PostgreSQL ORM (Object Relational Mapper) for R Language using `DBI` package as
base.

Currently, there is only PostgreSQL supported. If you require more drivers, let
me know.

The idea is simple: The `rORM` package give you the possibility to generate R 
code which provides `R6` objects for each DB table. This objects works as models
which can be used to perform basic CRUD operations on the DB. 



## Installation

Only github installation possibly right now:

`devtools::install_github("https://github.com/CG-staff/rORM")`

## Get Started

The idea how to use the rORM integration is as follows:

1. Setup a PostgreSQL connection using the `DBI` package. This can loks as follows:
```R
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  user = "postgres",
  password = "password",
  port = "5432",
  host = "127.0.0.1"
)
```
2. Everytime a change in the DB was done run in the R console: `rorm_generate_code_to_file(con)`.
This creates a file called `rorm_models.R`. The file name and path can be
changed using the parameter `filepath`.
3. Load the new models to the environment using `source("rorm_models.R")`.
4. Now the mapper models can be used for example image we have a table called
`account`, then the model object called: `RORMAccountModel`. Then we can load
all entries with: `RORMAccountModel$all()` or `RORMAccountModel$insert(data.frame(field_a = 1, field_b = "2")).`


## Code Generator Options

Using the code generator there are two optional options
`rorm_generate_code_to_file(con = con, prefix = prefix, filepath = filepath)`.
One is the `prefix` where the name of the models can be changed. 
The second is the `filepath` where the path to the generated source code can
be changed.


## Model API

- `RORMExampleModel$insert(df)`

- `RORMExampleModel$update(key, df)`

- `RORMExampleModel$delete(key)`

- `RORMExampleModel$get(key)`

- `RORMExampleModel$all()`


 
