#' Title
#'
#' @param string
#'
#' @return
#' @export
#'
#' @examples
str_camel_case <- function(string) {
  parts <- unlist(stringi::stri_split(string, regex =  "_|\\-"))

  string <- stringi::stri_trans_tolower(parts)
  first_char <- stringi::stri_trans_toupper(substr(string, 1, 1))
  remaining_chars <- substr(string, 2, nchar(string))
  return(paste(paste0(first_char, remaining_chars), collapse = ""))
}


#' Title
#'
#' @param vector
#'
#' @return
#' @export
#'
#' @examples
vector_to_R_code <- function(vector) {
  return(
    paste0('c("',paste(stringr::str_replace_all(string = vector, pattern = '"', replacement = '\\\\\"'), collapse = '", "'), '")')
  )
}
