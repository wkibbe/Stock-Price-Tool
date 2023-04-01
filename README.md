# Stock Tool

This is a Bash script called `stocktool.sh` that allows users to track stock prices over time and perform a stock trading simulation. The script was developed by Will Kibbe, Ishaan Singh, and Weifeng Guo on March 17, 2023.

## Features

The script has two main features:

1. **Track stock prices over time**: Monitor stock prices and save them to a file at specified time intervals.
2. **Stock trading simulation**: Simulate buying and selling stocks, track your portfolio, and view your cash balance.

## Dependencies

This script requires the `ticker.sh` script to fetch stock prices. You can download it from [https://github.com/pstadler/ticker.sh](https://github.com/pstadler/ticker.sh).
This script also requires the `cleanfile.sh` script. This script is included in this project.

## Setup

Before running the `stocktool.sh` script, follow these steps:

1. Download the `ticker.sh` script from [https://github.com/pstadler/ticker.sh](https://github.com/pstadler/ticker.sh).
2. Make sure the `ticker.sh` script is executable by running `chmod +x ticker.sh`.
3. Replace the placeholder `PATH_TO_TICKER_SCRIPT` in the `stocktool.sh` script with the actual path to the `ticker.sh` script you downloaded. In addition, you may have to change the file path for `cleanfile.sh`.
4. Make sure the `cleanfile.sh` script is executable by running `chmod +x cleanfile.sh`.

Example:

Replace this line:
tickerdata=$(PATH_TO_TICKER_SCRIPT $stock)

with the correct path information for ticker:
tickerdata=$(path/to/your/ticker.sh $stock)