#' General string helper function convert mainly snake_case strings which are
#' mainly used in DB tables to a CamelCase format.
#'
#' kebab-case strings are also handles correctly, all other formats will not fails
#' but could lead to unexpected format.
#'
#' @param string string, i.e. better snake_case string
#'
#' @return camel case string.
#' @export
#'
#' @examples
#' str_camel_case("table_name") # snake_case
#' str_camel_case("yet-another-table-name") # kebab-case
#' str_camel_case("CamelCaseTable") # already in CamelCase will be destroyed
#' # Spaces will be handled as snake case, but the assumption is that a DB table
#' # has no spaces.
#' str_camel_case("table name with spaces")
str_camel_case <- function(string) {
  parts <- unlist(stringi::stri_split(string, regex =  "_|\\-|\\ "))

  string <- stringi::stri_trans_tolower(parts)
  first_char <- stringi::stri_trans_toupper(substr(string, 1, 1))
  remaining_chars <- substr(string, 2, nchar(string))
  return(paste(paste0(first_char, remaining_chars), collapse = ""))
}


#' General string helper converting a R vector to correct R code which can be
#' executed.
#'
#' @param vector arbitrary R vector
#'
#' @return string which can be parsed to R code (see examples)
#' @export
#'
#' @examples
#' vector_to_R_code(1:10)
#' vector_to_R_code("Hello World")
#' vector_to_R_code(c(1,2,4,5,"6"))
#' eval(parse(text=paste0(vector_to_R_code(1:10), " + 11")))
vector_to_R_code <- function(vector) {
  if (is.numeric(vector)) {
    return (
      paste0('c(',paste(vector, collapse = ', '), ')')
    )
  }

  return(
    paste0('c("',paste(stringr::str_replace_all(string = vector, pattern = '"', replacement = '\\\\\"'), collapse = '", "'), '")')
  )
}
