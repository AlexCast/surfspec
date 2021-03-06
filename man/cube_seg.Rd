% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cube_seg.R
\name{cube_seg}
\alias{cube_seg}
\title{Image segmentation}
\usage{
cube_seg(cube, type = "kmeans", lclump = TRUE, plot = TRUE, ...)
}
\arguments{
\item{cube}{The hyperspectral cube returned by the function \code{cube_read}}

\item{type}{Type of image segmentation. 'kmeans' is the only accepted value.}

\item{lclump}{Logical. Keep only the largest clump? See Details.}

\item{...}{Arguments to be passed to \code{kmeans}.}
}
\value{
The same cube as the input, with the clusters as a raster layer in 
the attribute 'metadata'.
}
\description{
Performs image segmentation with the kmeans algorithm.
}
\details{
This function provides an interactive too to classify and reclassify 
(aggregate) the image in clusters.

If lclump is TRUE, after image classification and possibly reclassification, 
the \code{clump} function of the raster package is called to identify clumps
of contiguous pixels. This is a spatial classification. Only the largerst 
clump will be kept. This is a fine tune aid to the spectral classification 
when trying to extract a single contigous region (target surface) and the 
spectral classification results in isolated pixels or small clumps of pixels
}
