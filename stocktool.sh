#!/bin/bash

# Script: stocktool.sh
# Description: This script monitors stock prices
# Author: Will Kibbe, Ishaan Singh, and Weifeng Guo
# Date: March 17, 2023

# first step in the code: ask the user which stocks they wish to track

# note: to record current time and date, use this command: date +"%Y-%m-%d %T"
# for just time, use: date +"%T"
# for just date, use: date +"%Y-%m-%d"

# program overview:
# step 1: ask user what they want to do (either stock price tracking or trading simulation)
# step 2: collect list of stocks that the user wants to trade and store them into a line-seperated text file (with no header because that's just a headache)

# Function 1: tracks stock prices over time
function function1 
{

    # Prompt user for list of names
    echo "Please enter a comma-separated list of stock tickers:"
    read name_list

    # Remove spaces and convert to array
    IFS=',' read -ra names <<< "$(echo -e "${name_list// /\\n}" | tr -d '[:space:]')"

    # Write names to file with each name being stored on a new line (make sure the file is empty before filling it though!)
    # rm -f is used to delete the file if it exists without throwing an error message if the file does not exist
    rm -f stocklist.txt
    echo "stock list cleared"
    # now fill in the list

    for name in "${names[@]}"; do
        echo -e "$name" >> stocklist.txt
    done

    # Confirm success to user
    echo "Names have been stored in stocklist.txt."
    #make sure the stock results text file is empty
    rm -f stockresults.txt
    echo "Enter time interval in seconds (e.g., 60 for 1 minute):" # asks the user to provide an interval for recording the stock prices
    read interval
    #tell user that the stocks are now being recorded in a file called stockresults.txt
    echo "stock performance information is now being recorded in stockresults.txt"

    echo "cleaned data is recorded in cleanresults.txt"

    # now start recording stock performance in stockresults.txt

    # Record stock prices every interval seconds
    while true; do
        # Get current date and time
        timestamp=$(date +"%Y-%m-%d %T")

        # Get stock prices for each symbol in stocklist.txt
        while read stock; do
            tickerdata=$(PATH_TO_TICKER_SCRIPT $stock)
            echo "$timestamp $tickerdata" >> stockresults.txt
        done < stocklist.txt

        # now, let's also store a cleaned version of the data in stockresults.txt into a new text file called cleanresults.txt
        rm -f cleanresults.txt
        ./cleanfile.sh <stockresults.txt> cleanresults.txt
        # Print the dashboard
        print_dashboard
        # Wait for interval seconds before recording prices again
        sleep $interval
    done
    
    # while recording this to stockresults.txt show updates to the stock prices to the user in terminal

}

function print_dashboard 
{
    clear
    echo "--------------------------------------------------"
    echo "                    STOCK PORTFOLIO                "
    echo "--------------------------------------------------"
    echo ""
    while read stock; do
        ticker=$(echo $stock | awk '{print $3}')
        price=$(echo $stock | awk '{print $4}')
        date=$(echo $stock | awk '{print $1}')
        time=$(echo $stock | awk '{print $2}')
        echo "$ticker: $price $date $time"
    done < cleanresults.txt
    echo ""
    echo "--------------------------------------------------"
    echo "         Last updated: $(date +"%Y-%m-%d %T")        "
    echo "--------------------------------------------------"
}



# Function 2: 
function function2 
{
    touch portfolio.txt && echo "" > portfolio.txt
    touch stockresults.txt && echo "" > stockresults.txt
    touch cleanresults.txt && echo "" > cleanresults.txt

    echo "let's start trading stocks. how much money do you want to start out with"
    read cash

    echo "Enter price refresh interval in seconds (e.g., 60 for 1 minute):" # asks the user to provide an interval for recording the stock prices
    read interval

    echo "It is now time to start investing in stocks!"

    while true; do
    # Ask user to choose function
    echo "Please choose a function:"
    echo "1. retrieve a current stock price"
    echo "2. Stock trading simulation - buy"
    echo "3. Stock trading simulation - sell"
    echo "4. View portfolio"
    read choice

    # Call chosen function
    case $choice in
        1) getprice;;
        2) buy;;
        3) sell;;
        4) portfolio;;
        *) echo "Invalid choice. Please enter 1, 2, 3, or 4.";;
    esac

    # Check if user wants to continue
    echo "Do you want to continue? (yes/no)"
    read answer
    if [[ "${answer}" != "yes" ]]; then
        break
    fi
done

}

function getprice
{
  #ask for a stock symbol and return the details
  echo "Please enter stock symbol: "
  read symbol
  echo "$(PATH_TO_TICKER_SCRIPT $symbol)"
}

function buy {
    #add a stock to their portfolio and subtract the appropriate amount from cash
    echo "Enter stock symbol to buy:"
    read symbol
    echo "Enter amount to buy:"
    read amount
    # Get stock prices for the symbol
    tickerdata=$(PATH_TO_TICKER_SCRIPT $symbol)
    touch stockresults.txt && echo "" > stockresults.txt
    echo "$tickerdata" >> stockresults.txt
    echo "$tickerdata"
    # now, let's also store a cleaned version of the data in stockresults.txt into a new text file called cleanresults.txt
    touch cleanresults.txt && echo "" > cleanresults.txt
    ./cleanfile.sh <stockresults.txt> cleanresults.txt
    price=$(awk '{print $2}' cleanresults.txt)
    cost=$(echo "$price * $amount" | bc -l)
    echo "cost: $cost"

    if [ $(echo "$cost > $cash" | bc -l) -eq 1 ]; then
        echo "Insufficient cash to buy $amount shares of $symbol at $price per share."
    else
        echo "Buying $amount shares of $symbol for $cost. Cash remaining: $(echo "$cash - $cost" | bc -l)"
        cash=$(echo "$cash - $cost" | bc -l)
        echo "$symbol $amount $date" >> portfolio.txt
    fi
    

}



function sell 
{
    # Get the list of stocks in the portfolio
    stocks=$(awk '{print $1}' portfolio.txt)
    echo "Enter stock symbol to sell:"
    read symbol
    # Check if the stock is in the portfolio
    if ! echo "$stocks" | grep -wq "$symbol"; then
        echo "You don't have any shares of $symbol in your portfolio."
        return
    fi
    echo "Enter amount to sell:"
    read amount
    # Get the number of shares of the stock in the portfolio
    shares=$(awk -v sym="$symbol" '$1==sym {print $2}' portfolio.txt)
    # Check if the user has enough shares to sell
    if [ "$amount" -gt "$shares" ]; then
        echo "You only have $shares shares of $symbol in your portfolio."
        return
    fi
    # Get the current stock price
    tickerdata=$(PATH_TO_TICKER_SCRIPT $symbol)
    touch stockresults.txt && echo "" > stockresults.txt
    echo "$tickerdata" >> stockresults.txt
    echo "$tickerdata"
    # Store a cleaned version of the data in stockresults.txt into a new text file called cleanresults.txt
    touch cleanresults.txt && echo "" > cleanresults.txt
    ./cleanfile.sh <stockresults.txt> cleanresults.txt
    price=$(awk '{print $2}' cleanresults.txt)
    revenue=$(echo "$price * $amount" | bc -l)
    echo "revenue: $revenue"
    # Update the portfolio file
    cash=$(echo "$cash + $revenue" | bc -l)
    sed -i "s/^$symbol $shares/$symbol $(($shares - $amount))/" portfolio.txt
    echo "Sold $amount shares of $symbol for $revenue. Cash balance: $cash"
}

function portfolio
{
    #give some information about the stocks the user currently holds as well as their cash situation
    echo "this is debugging code :)"
    echo "Cash: $cash"
    echo "Symbol : price : change in price : % change in price : number of shares held"
    while read line; do
        stock=$(echo $line | awk '{print $1}')
        touch stockresults.txt && echo "" > stockresults.txt
        touch cleanresults.txt && echo "" > cleanresults.txt
        tickerdata=$(PATH_TO_TICKER_SCRIPT $stock)
        #let's add the ticker data as well as everything else to the stock results txt
        echo "$(echo "$tickerdata") $(echo "$line" | awk '{print $2}')" >> stockresults.txt
        # now, let's also store a cleaned version of the data in stockresults.txt into a new text file called cleanresults.txt
        ./cleanfile.sh <stockresults.txt> cleanresults.txt
        #print to console
        cat cleanresults.txt
    done < portfolio.txt
}


# Ask user to choose function
echo "Please choose a function:"
echo "1. track stock prices over time"
echo "2. Stock trading simulation"
read choice

# Call chosen function
case $choice in
    1) function1;;
    2) function2;;
    *) echo "Invalid choice. Please enter 1 for stock price tracking or 2 for stock trading simulation."
esac



