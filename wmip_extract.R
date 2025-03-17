library(dplyr)

WMIP_Extract <- function (WMIPID, START, param = "level", datasource = "AT",
                          END = format(Sys.Date() + 1, "%Y%m%d"),
                          type = "mean", interval = "hour", report = "start") {
  
  stopifnot("type must be max, min, mean, end, tot, cum, inst, point" =
              type %in% c( "max", "min", "mean", "end", "tot", "cum", "inst", "point" ) )
  
  stopifnot("interval must be year, month, day, hour, minute, second" =
              interval %in% c( "year", "month", "day", "hour", "minute", "second" ) )
  
  stopifnot("report must be start or end" =
              report %in% c( "start", "end") )
  
  param <- dplyr::case_when(
    param == "level" ~ "varfrom=100.00&varto=100.00",
    param == "discharge" ~ "varfrom=100.00&varto=140.00",
    # param == "preservedQ" ~ "varfrom=140.00&varto=140.00",
    param == "rainfall" ~ "varfrom=10.00&varto=10.00",
    # param == "temperature" ~ "varfrom=2080.00&varto=2080.00",
    # param == "conductivity" ~ "varfrom=2010.00&varto=2010.00",
    # param == "pH" ~ "varfrom=2100.00&varto=2100.00",
    # param == "turbidity" ~ "varfrom=2030.00&varto=2030.00"
  )
  
  WMIP_URL <- paste("https://water-monitoring.information.qld.gov.au/cgi/webservice.pl?function=get_ts_traces&site_list=",
                    WMIPID, "&datasource=", datasource, "&",
                    param, "&start_time=", START, "&end_time=",
                    END, "&data_type=",type,"&interval=",interval,
                    "&report_time=",report,"&multiplier=1&format=csv", sep = "")
  
  API <- httr::GET(WMIP_URL, timeout = 30)
  WMIPData <- readr::read_csv(rawToChar(API$content))
  
  if (grepl("error", names(WMIPData)[1])) {
    WMIPData <- tibble::tibble("site" = WMIPID,
                               "varname" = param,
                               "var" = "error",
                               "time" = NA,
                               "value" = NA,
                               "quality" = NA,
    )
  } else {
    WMIPData$time <- as.POSIXct(sprintf("%1.0f", WMIPData$time), format="%Y%m%d%H%M%S", origin = "1970-01-01")
  }
  
  
  return(WMIPData)
}
