#' Get / Set SPSS missing values
#'
#' @param x A vector.
#' @param value A vector of values that should also be considered as missing
#' (for \code{na_values}) or a numeric vector of length two giving the (inclusive)
#' extents of the range (for \code{na_values}, use \code{-Inf} and \code{Inf} if you
#' want the range to be open ended).
#' @details
#' See \code{\link{labelled_spss}} for a presentation of SPSS's user defined missing values.
#' Note that it is mandatory to define value labels before defining missing values.
#' You can use \code{\link{user_na_to_na}} to convert user defined missing values to \code{NA}.
#' @return
#'   \code{na_values} will return a vector of values that should also be considered as missing.
#'   \code{na_range} will return a numeric vector of length two giving the (inclusive)
#'     extents of the range.
#' @seealso \code{\link{labelled_spss}}, \code{\link{user_na_to_na}}
#' @examples
#' v <- labelled(c(1,2,2,2,3,9,1,3,2,NA), c(yes = 1, no = 3, "don't know" = 9))
#' v
#' na_values(v) <- 9
#' na_values(v)
#' v
#' na_values(v) <- NULL
#' v
#' na_range(v) <- c(5, Inf)
#' na_range(v)
#' v
#' @export
na_values <- function(x) {
  UseMethod("na_values")
}

#' @export
na_values.default <- function(x) {
  # return nothing
  NULL
}

#' @export
na_values.labelled_spss <- function(x) {
  attr(x, "na_values", exact = TRUE)
}

#' @export
na_values.data.frame <- function(x) {
  lapply(x, na_values)
}

#' @rdname na_values
#' @export
`na_values<-` <- function(x, value) {
  UseMethod("na_values<-")
}

#' @export
`na_values<-.default` <- function(x, value) {
  if (is.null(val_labels(x)) & !is.null(value))
    stop("Value labels need to be defined first. Please use val_labels().")
  # else do nothing
  x
}

#' @export
`na_values<-.labelled` <- function(x, value) {
  if (is.null(value)) {
    attr(x, "na_values") <- NULL
    if (is.null(attr(x, "na_range")))
      class(x) <- "labelled"
  } else {
    if (is.null(val_labels(x)))
      stop("Value labels need to be defined first. Please use val_labels().")
    x <- labelled_spss(x, val_labels(x), na_values = value, na_range = attr(x, "na_range"))
  }
  x
}

#' @rdname na_values
#' @export
na_range <- function(x) {
  UseMethod("na_range")
}

#' @export
na_range.default <- function(x) {
  # return nothing
  NULL
}

#' @export
na_range.labelled_spss <- function(x) {
  attr(x, "na_range", exact = TRUE)
}

#' @export
na_range.data.frame <- function(x) {
  lapply(x, na_range)
}

#' @rdname na_values
#' @export
`na_range<-` <- function(x, value) {
  UseMethod("na_range<-")
}

#' @export
`na_range<-.default` <- function(x, value) {
  if (is.null(val_labels(x)) & !is.null(value))
    stop("Value labels need to be defined first. Please use val_labels().")
  # else do nothing
  x
}

#' @export
`na_range<-.labelled` <- function(x, value) {
  if (is.null(value)) {
    attr(x, "na_range") <- NULL
    if (is.null(attr(x, "na_values")))
      class(x) <- "labelled"
  } else {
    if (is.null(val_labels(x)))
      stop("Value labels need to be defined first. Please use val_labels().")
    x <- labelled_spss(x, val_labels(x), na_values = attr(x, "na_values"), na_range = value)
  }
  x
}


#' @rdname na_values
#' @param .data a data frame
#' @param ... name-value pairs of missing values (see examples)
#' @note
#'   \code{set_na_values} and \code{set_na_range} could be used with \code{dplyr}.
#' @return
#'  \code{set_na_values} and \code{set_na_range} will return an updated
#'  copy of \code{.data}.
#' @examples
#' if (require(dplyr)) {
#'   # setting value labels
#'   df <- data_frame(s1 = c("M", "M", "F", "F"), s2 = c(1, 1, 2, 9)) %>%
#'     set_value_labels(s2 = c(yes = 1, no = 2)) %>%
#'     set_na_values(s2 = 9)
#'   na_values(df)
#'
#'   # removing missing values
#'   df <- df %>% set_na_values(s2 = NULL)
#'   df$s2
#' }
#' @export
set_na_values <- function(.data, ...) {
  values <- list(...)
  if (!all(names(values) %in% names(.data)))
    stop("some variables not found in .data")

  for (v in names(values))
    na_values(.data[[v]]) <- values[[v]]

  .data
}

#' @rdname na_values
#' @export
set_na_range <- function(.data, ...) {
  values <- list(...)
  if (!all(names(values) %in% names(.data)))
    stop("some variables not found in .data")

  for (v in names(values))
    na_range(.data[[v]]) <- values[[v]]

  .data
}
