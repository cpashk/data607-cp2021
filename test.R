library(tidyverse)
library(nycflights13)

by_dest <- group_by(flights, dest)
delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)
delay

diamonds <- ggplot2::diamonds
diamonds
??openintro



??patrn
?rep
rep(c(rep(c(1,2,3), 2), 4), 3)
?pnorm
