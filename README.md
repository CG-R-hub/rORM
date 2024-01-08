# rORM (for PostgreSQL)

PostgreSQL ORM (Object Relational Mapper) for R Language using `DBI` package as
base.

Currently, there is only PostgreSQL supported. If you require more drivers, let
me know.

The idea is simple: The `rORM` package give you the possibility to generate R 
code which provides `R6` objects for each DB table. This objects works as models
which can be used to perform basic CRUD operations on the DB. 

![build workflow](https://github.com/CG-R-hub/rORM/actions/workflows/R-CMD-check.yaml/badge.svg)

## Installation

Only github installation possibly right now:

`devtools::install_github("https://github.com/CG-R-hub/rORM")`

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

- `RORMExampleModel$insert(df)`: Method to insert new table content.
   - `df` contains the new content of the DB table. Potential values for the key columns will be deleted if the table has a primary key and overwritten by the primary key logic of the DB.

- `RORMExampleModel$update(key, df)`: Method to update existing table content
    - `key`: The column value which content should be updated. If the table has a primary key, then only a value can be provided, otherwise a named vector is required. Does the table has no keys at all, then any named vector will be used as WHERE argument. This can lead to multiple row updates.  
    - `df`: The new data as data.frame.

- `RORMExampleModel$delete(key)`: Method to delete a row by key.
    - `key`: The key value what to delete.

- `RORMExampleModel$get(key)`: Method to load a row by.
    - `key`: The key value for what to filter for.

- `RORMExampleModel$all()`: Method to load the entire table.

 
## Development

### Steps todo before merging

Run these commands inside the R Console:

1. `file.remove("rorm_models.R")`.
1. `devtools::document()`.
1. `devtools::check(document = FALSE)`.
1. `devtools::test()`.
