#Este cdóigo fue obtenido de https://github.com/tereom/quickcountmx/blob/master/R/select_sample.R

select_sample_prop <- function(sampling_frame, stratum = stratum, frac,
                               seed = NA, replace = FALSE){
  if (!is.na(seed)) set.seed(seed)
  if (missing(stratum)){
    sample <- dplyr::sample_frac(sampling_frame, size = frac,
                                 replace = replace)
  } else {
    stratum <- dplyr::enquo(stratum)
    sample <- sampling_frame %>%
      dplyr::group_by(!!stratum) %>%
      dplyr::sample_frac(size = frac, replace = replace) %>% 
      dplyr::ungroup()
  }
  return(sample)
}