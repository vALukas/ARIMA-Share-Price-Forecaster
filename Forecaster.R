# install.packages("tidyverse")
# install.packages("tidyquant")
# install.packages("forecast")

library(tidyverse)
library(tidyquant)
library(forecast)

# Inputs
forecast_horizon <- 30
ticker <- toupper(readline("Ticker: "))

# Fetch and manipulate data
data <- tryCatch(
    {
      tq_get(ticker, from = "2022-01-01", to = Sys.Date())
    },
    error = function(e) {
      message(paste("Error fetching data for ticker:", ticker))
      message("Please check if the ticker symbol is valid")
      return(NULL)
    }
)

if (is.null(data) || nrow(data) == 0) {
  stop("No data found. Exiting")
}
  

PREDICT = TRUE
COMPARE = FALSE


if (PREDICT) {

earliest_date <- min(data$date, na.rm = TRUE)
latest_date <- max(data$date, na.rm = TRUE)
data <- data %>%   
    mutate(
        days = as.integer(difftime(date, earliest_date, units = "days")),
        price_change = close - lag(close),
        price_change_percentage = ((close / lag(close)) - 1) * 100
    )

data <- data %>% 
  drop_na()

# Plot historical share price
historical <- ggplot(data, aes(x = date, y = close, colour = price_change > 0)) +
  geom_point(size = 1, alpha = 0.8) +
  scale_colour_manual(
    values = c("TRUE" = "darkgreen", "FALSE" = "red"),
    labels = c("Down", "Up"),
    name = "Price Movement"
  ) +
  labs(
    title = paste(ticker, "share price ($) since", earliest_date),
    x = "Date",
    y = "Price ($)") +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )
print(historical)

# Fit ARIMA
ts_data <- ts(data$close)

fit <- auto.arima(ts_data, seasonal = FALSE)
summary(fit)

fc <- forecast(fit, h = forecast_horizon)

# Plot ARIMA
arima <- autoplot(fc) +
  labs(
    title = paste("ARIMA forecast of", ticker, "share price ($) from", latest_date),
    x = "Date",
    y = "Price ($)") +
  theme_minimal() +
  theme(
    axis.text.x = element_blank()
  )
print(arima)

# Modify forecast data
latest_day <- tail(data$days, 1)

fc <- as.data.frame(fc)
colnames(fc)[colnames(fc) == "Point Forecast"] <- "Forecast"
fc$Forecast <- round(fc$Forecast, 2)

stop_index <- which(diff(fc$Forecast) == 0)[1]
if (!is.na(stop_index)) {
  fc <- fc[1:stop_index, ]
}

n_fc <- nrow(fc)
all_dates <- seq.Date(from = latest_date, by = "day", length.out = n_fc * 2)
trading_dates <- all_dates[!weekdays(all_dates) %in% c("Saturday", "Sunday")][1:n_fc]
fc$date <- trading_dates
fc$days <- (latest_day + 1):(latest_day + n_fc)

earliest_fc_date = head(fc$date, 1)

# Plot forecasted share price
forecasted <- ggplot(data = data, aes(x = date, y = close)) +
  geom_line(
    linewidth = 1) +
  geom_line(
    data = fc, 
    aes(x = date, y = Forecast), 
    colour = "purple", 
    linewidth = 1) +
  labs(
    title = paste(ticker, "forecasted share price ($) from", earliest_fc_date),
    x = "Date",
    y = "Price ($)") +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )
print(forecasted)

}




if (COMPARE) {

# Compare ARIMA with historical share price

# Manipulate data
start_date <- min(data$date)
end_date <- max(data$date)
middle_date <- as.Date((as.numeric(start_date) + as.numeric(end_date)) / 2, origin = "1970-01-01")

compare <- data %>% 
  filter(date <= middle_date)
  
# Fit ARIMA
ts_data <- ts(compare$close)

fit <- auto.arima(ts_data, seasonal = FALSE)
summary(fit)

fc <- forecast(fit, h = forecast_horizon)

# Plot ARIMA
arima <- autoplot(fc) +
  labs(
    title = paste("ARIMA forecast of", ticker, "share price ($) from", middle_date),
    x = "Date",
    y = "Price ($)") +
  theme_minimal() +
  theme(
    axis.text.x = element_blank()
  )
print(arima)

# Modify forecast data
fc <- as.data.frame(fc)
colnames(fc)[colnames(fc) == "Point Forecast"] <- "Forecast"
fc$Forecast <- round(fc$Forecast, 2)

stop_index <- which(diff(fc$Forecast) == 0)[1]
if (!is.na(stop_index)) {
  fc <- fc[1:stop_index, ]
}

latest_day <- tail(compare$days, 1)

n_fc <- nrow(fc)
all_dates <- seq.Date(from = middle_date, by = "day", length.out = n_fc * 2)
trading_dates <- all_dates[!weekdays(all_dates) %in% c("Saturday", "Sunday")][1:n_fc]
fc$date <- trading_dates
fc$days <- (latest_day + 1):(latest_day + n_fc)

earliest_fc_date = head(fc$date, 1)

window_days <- 45
data_window <- data %>% 
  filter(date >= (middle_date - window_days) & date <= (middle_date + window_days))

# Plot predicted vs actual share price
predicted_vs_actual <- ggplot(data = data_window, aes(x = date, y = close)) +
  geom_line(
    linewidth = 1) +
  geom_line(
    data = fc, 
    aes(x = date, y = Forecast), 
    colour = "purple", 
    linewidth = 1) +
  labs(
    title = paste(ticker, "forecasted share price vs actual share price ($) from", earliest_fc_date),
    x = "Date",
    y = "Price ($)") +
  theme_minimal() +
  theme(
    legend.position = "bottom"
    )
print(predicted_vs_actual)

}

