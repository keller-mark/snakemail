#!/bin/bash
AHA_DIR="$(dirname "$0")/aha"
AHA_FILE="$AHA_DIR/aha"

# Compile aha if necessary
if [ ! -f $AHA_FILE ]; then
  git submodule update --init
  cd $AHA_DIR && make && cd -
fi

email_regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
email=$1

SNAKEMAKE_COMMAND="${@:2}"

HTML_FILE="snakemake.htm"
LOG_FILE="snakemake.log"

if [[ $email =~ $email_regex ]] ; then
  echo "Emailing to ${email}"
  echo "Running script $SNAKEMAKE_COMMAND"
  script -q -c "$SNAKEMAKE_COMMAND" $LOG_FILE
  cat $LOG_FILE | $AHA_FILE > $HTML_FILE
  # Set mail headers and send email
  cat $HTML_FILE | mail -s "$(echo -e "Snakemake finished\nContent-Type: text/html")" $email
  rm $LOG_FILE
  rm $HTML_FILE
else
  echo "Invalid email provided."
fi


