# ARIMA Share Price Forecaster

A time series pipeline to forecast short-term share prices using historical market data, ARIMA modelling, and data visualisation in R. This project is designed to learn ARIMA mechanics and work with financial datasets rather than to generate trading signals.

## Project Overview

This project demonstrates financial time series modelling by:

- Pulling historical daily share price data from Yahoo Finance (https://nz.finance.yahoo.com/markets/) using `tidyquant`  
- Cleaning and enhancing the dataset with daily prices and other relevant stats  
- Fitting an ARIMA model with `auto.arima()` to model short-term price movements  
- Generating a forecast of up to 30 days and visualising both historical and predicted prices  
- Optionally comparing ARIMA forecasts with actual prices for evaluation  

## Features

- **Automated Data Retrieval**: Downloads historical share price data and stats for a specific ticker directly from Yahoo Finance  
- **ARIMA Forecasting**: Fits an ARIMA model on historical price data to produce short-term forecasts  
- **Data Visualisation**: Plots historical prices, forecasted prices, and optional predicted vs actual comparisons  

## Tech Stack

- **R** - Data processing, modelling, and visualisation  
- **tidyverse / ggplot2** - Data manipulation and plotting  
- **tidyquant** - Financial data retrieval from Yahoo Finance  
- **forecast** - ARIMA modelling and forecasting  

## How It Works

1. **Input Ticker Symbol**  
   User provides a stock ticker symbol. The script fetches historical daily prices and stats from 1 January 2022 to the current date.

2. **Data Preparation**  
   Calculates daily price changes and percentage changes. Missing data is removed.

3. **Fit ARIMA Model**  
   `auto.arima()` automatically selects the best ARIMA parameters to model the historical price series.

4. **Generate Forecast**  
   A forecast of up to 30 days is produced. Only trading days are considered, skipping weekends.

5. **Visualise Results**  
   Historical and forecasted prices are plotted using `ggplot2`. Compare mode allows a visual comparison of predicted vs actual prices.

## Personal Learning & Experiments

This project was primarily designed as a learning exercise to:

- Understand ARIMA parameter selection and differencing  
- Gain hands-on experience manipulating financial time series in R  
- Visualise forecasts and perform basic backtesting  

It acknowledges that share prices behave approximately like a random walk, so ARIMA is not effective for long-term forecasting. The focus is on learning the mechanics of ARIMA and working with real financial data rather than generating reliable trading signals.
