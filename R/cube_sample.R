
#' Sample hyperspectral cube with points or lines
#'
#' @param n      The number of samples to take.
#' @param cube   The hyperspectra cube returned by the function \code{cube_read}
#' @param type   The type of sample. One of "points" or "lines".
#' @param buffer Buffer to be used if type == "points". Defaults to 0.
#' @param dir    Direction to be sampled if type == "lines". One of "x" or "y". 
#'               Defaults to "y".
#' @param reuse  an object previously returned by this function. See Details.
#' @param ...    Arguments to be passed to \code{cube_rgb} 
#'
#' @details This is an interactive function to sample per points of lines an
#' hyperspectral cube. If sampling per points it is possible to define the 
#' buffer radius (in pixel units) to expand the point before sampling.
#'
#' If sampling per lines, it is necessary to define a direction of sampling. If
#' dir == "y" sample will be enforced to be a vertical line. If 
#' dir == "x", it will be enforced to an horizontal line.
#'
#' It is possible to reuse information from a previous sample for a new sample.
#' This is because the object returned by this function contain data on the 
#' positions and Spatial* objects used for sampling, with positions relative to 
#' the xy origin of the original image. This can be useful if testing different 
#' processing methods and is wished to apply the same sampling, or if working 
#' with data collected in a measurement setup that ensure the same position on 
#' the image frame.
#'
#' @return
#' A list with components type and n from the arguments, sp with the Spatial* 
#' object used for sampling and data with a matrix per sample organized in a 
#' list. Additionally, if type == "points", xy is a data frame with the original
#' points and buffer copies the argument.
#'
#' @export

cube_sample <- function(n, cube, type = c("points", "lines"), buffer = 0, 
  dir = "y", reuse, ...) {

  argsl <- as.list(match.call()[-1])
  if(type == "points") {
    sample <- do.call(".cube_sample_points", argsl)
  } else if(type == "lines") {
    sample <- do.call(".cube_sample_lines", argsl)
  } else {
    stop("type must be one of 'points' or 'lines'", call = FALSE)
  }

}

.cube_sample_points <- function(n, cube, buffer = 0, reuse, ...) {

  cube_rgb(cube, ...)

  cols      <- rev(rainbow(n, start = 0, end = 0.8))
  xyl       <- list()
  sample.sp <- list()
  if(missing(reuse)) {
    for(i in 1:n) {
      xyl[[i]]       <- as.data.frame(locator(1))
      sample.sp[[i]] <- SpatialPoints(xyl[[i]])
      if(buffer > 0) {
        sample.sp[[i]] <- buffer(sample.sp[[i]], buffer, dissolve = F)
        sample.sp[[i]]@polygons[[1]]@ID <- as.character(i)
        plot(sample.sp[[i]], add = TRUE, lwd = 2, border = cols[i])
      } else {
        plot(sample.sp[[i]], add = TRUE, col = cols[i])
      }
    }
    sample.sp <- do.call(rbind, sample.sp)
    xy        <- do.call(rbind, xyl)
  } else {
    type      <- reuse$type
    if(type != "points")
      stop("Cannot reuse lines to sample points", call. = FALSE)
    n         <- reuse$n
    xy        <- reuse$xy
    buffer    <- reuse$buffer
    sample.sp <- reuse$sp

    if(buffer > 0) {
      plot(sample.sp, add = TRUE, lwd = 2, border = cols)
    } else {
      plot(sample.sp, add = TRUE, col = cols)
    }
  }

  sample <- extract(cube, sample.sp)
  if(!is.list(sample)) {
    sl <- list()
    for(i in 1:nrow(sample)) {
      sl[[i]] <- sample[i, , drop = FALSE]
    }
    sample <- sl
  }
  
  sample <- list(
    type = "points",
    n  = n,
    xy = as.data.frame(xy),
    buffer = buffer,
    sp = sample.sp,
    data = sample
  )

  sample

}

.cube_sample_lines <- function(n, cube, dir = "y", reuse, ...) {

  cube_rgb(cube, ...)

  if(missing(reuse)) {
    cols      <- rev(rainbow(n, start = 0, end = 0.8)) 
    sample.sp <- list()
    for(i in 1:n) {
      xy <- locator(2)
      if(dir == "y") {
        xy$x[2] <- xy$x[1]
      } else {
        xy$y[2] <- xy$y[1]
      }
      sample.sp[[i]] <- SpatialLines(list(Lines(list(Line(xy)), 
        ID = as.character(i))))
      plot(sample.sp[[i]], add = T, lwd = 2, col = cols[i])
    }
    sample.sp <- do.call(rbind, sample.sp)
  } else {
    type      <- reuse$type
    if(type != "lines")
      stop("Cannot reuse points to sample lines", call. = FALSE)
    n         <- reuse$n
    sample.sp <- reuse$sp
  }

  sample <- extract(cube, sample.sp)

  sample <- list(
    type = "lines",
    n  = n,
    sp = sample.sp,
    data = sample
  )

  sample

}
