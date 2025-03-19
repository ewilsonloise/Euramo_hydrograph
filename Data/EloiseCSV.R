library(dplyr)
library(data.table)

WMIP_Extract <- function (WMIPID, START, param = "level", datasource = "AT",
                          END = format(Sys.Date() + 1, "%Y%m%d"),
                          type = "mean", interval = "hour", report = "start", multiplier = 1) {
  
  stopifnot("type must be max, min, mean, end, tot, cum, inst, point" =
              type %in% c( "max", "min", "mean", "end", "tot", "cum", "inst", "point" ) )
  
  stopifnot("interval must be year, month, day, hour, minute, second" =
              interval %in% c( "year", "month", "day", "hour", "minute", "second" ) )
  
  stopifnot("report must be start or end" =
              report %in% c( "start", "end") )
  
  param <- dplyr::case_when(
    param == "level" ~ "varfrom=100.00&varto=100.00",
    param == "discharge" ~ "varfrom=100.00&varto=140.00",
    param == "preservedQ" ~ "varfrom=140.00&varto=140.00",
    param == "rainfall" ~ "varfrom=10.00&varto=10.00",
    param == "temperature" ~ "varfrom=2080.00&varto=2080.00",
    param == "conductivity" ~ "varfrom=2010.00&varto=2010.00",
    param == "pH" ~ "varfrom=2100.00&varto=2100.00",
    param == "turbidity" ~ "varfrom=2030.00&varto=2030.00"
  )
  
  WMIP_URL <- paste("https://water-monitoring.information.qld.gov.au/cgi/webservice.pl?function=get_ts_traces&site_list=",
                    WMIPID, "&datasource=", datasource, "&",
                    param, "&start_time=", START, "&end_time=",
                    END, "&data_type=",type,"&interval=",interval,
                    "&report_time=",report,"&multiplier=",multiplier,"&format=csv", sep = "")
  
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

#Rainfall
df <- WMIP_Extract("113006A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                           param = "rainfall", type = "tot", interval = "hour", report = "start")


df2 <- df
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113006A.R.CSV", row.names = FALSE)

df <- WMIP_Extract("113015A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                          param = "rainfall", type = "tot", interval = "hour", report = "start")

df2 <- bind_rows(df2, df)

write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113015A.R.CSV", row.names = FALSE)


df <- WMIP_Extract("114001A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                   param = "rainfall", type = "tot", interval = "hour", report = "start")

df2 <- bind_rows(df2, df)

write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "114001A.R.CSV", row.names = FALSE)

#Discharge
df <- WMIP_Extract("113006A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                            param = "discharge", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113006A.Q.CSV", row.names = FALSE)



df <- WMIP_Extract("113004A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                          param = "discharge", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113004A.Q.CSV", row.names = FALSE)

df <- WMIP_Extract("113015A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                        param = "discharge", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113015A.Q.CSV", row.names = FALSE)

# Height
df <- WMIP_Extract("113006A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                        param = "level", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113006A.H.CSV", row.names = FALSE)


df <- WMIP_Extract("113015A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                         param = "level", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113015A.H.CSV", row.names = FALSE)


df <- WMIP_Extract("113004A", START = format(as.POSIXct("2008-11-01 00:00"), "%Y%m%d"),
                         param = "level", type = "mean", interval = "hour")
df2 <- bind_rows(df2, df)
write.csv(df %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S")),
          "113004A.H.CSV", row.names = FALSE)



# a long list
#write.csv(df2 %>% dplyr::select(-varname) %>% mutate(time=format(time, "%Y-%m-%d %H:%M:%S") ),
#          "TullyData.CSV", row.names = FALSE
#          )

# wide format
df2 %>% dplyr::select(-varname) %>% as.data.frame  %>% 
  melt(id.vars = c("time", "var", "site"), measure.vars = c("value", "quality")) %>%
  dcast(time ~ site + var + variable, value.var = "value", drop = FALSE) %>%
  mutate(time=format(time, "%Y-%m-%d %H:%M:%S")) %>%
  write.csv("TullyDataWide.CSV", row.names = FALSE)




