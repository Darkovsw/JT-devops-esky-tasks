#!/bin/bash
# Author: Jan Trojanowski

# Function that prints how to use the script properly
function instruction
{
 echo "You must specify the path to a log file: $0 <path_to_log_file>"
 echo "$0 [-u|--user-agent <user-agent>] <path_to_log_file>"
 echo "$0 [-m|--method] <path_to_log_file>"
 echo "Additional Options:"
 echo "-u|--user-agent allows restricting parsing of logs only to providded user agent."
 echo "$0 <path_to_log_file> --user-agent <user-agent>"
 echo "-m|--method prints in output number of request per method/address instead of just per address."
 echo "$0 <path_to_log_file> --method"
 exit 1
}

# Initializing needed variables
log_file=""
method=false

# Parsing script options
while [ $# -gt 0 ]
do

option="$1"

 case $option in

  --user-agent|-u)
   userAgent="$2"
   shift
  ;;

  --method|-m)
   method=true
  ;;

  --help|-h)
   instruction
  ;;

  *)
   log_file="$1"
  ;;

  esac

shift
done

# Checking if file exists
if [ -z $log_file ]; then
 instruction
fi

# Handling different file types
if [[ "$log_file" == *.tar.bz2 ]]; then
  tar -xjvf "$log_file"
  extracted_file=$(basename "$log_file" .tar.bz2)
  if [ -f "$extracted_file.log" ]; then
    log_file="$extracted_file.log"
  elif [ -d "$extracted_file" ]; then
    log_file=$(find "$extracted_file" -type f -name "*.log")
  fi
elif [[ "$log_file" == *.tar ]]; then
  tar -xvf "$log_file"
  extracted_file=$(basename "$log_file" .tar)
  if [ -f "$extracted_file.log" ]; then
    log_file="$extracted_file.log"
  elif [ -d "$extracted_file" ]; then
    log_file=$(find "$extracted_file" -type f -name "*.log")
  fi
fi

# Launching selected options
if [ -n "$userAgent" ];then

 grep -F "user_agent: \"$userAgent" "$log_file" |
 grep -Eo \
  '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' |
 sort | uniq -c |
 while read -r count ip; do
     printf "%-15s %2s %s\n" "$ip" "$count" "$userAgent"
 done

elif [ "$method" = true ];then

 grep -Eo \
 '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' \
 "$log_file" | sort | uniq |
 while read -r ip; do
    echo "$ip"
    grep "$ip" "$log_file" | grep -o 'method: "[A-Z]\+"' | sort | uniq -c
    echo ""
 done

else

 grep -Eo \
 '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' \
 "$log_file" | sort | uniq -c | sort -nr

fi

