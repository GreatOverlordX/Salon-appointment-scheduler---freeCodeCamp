#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ BEAUTY SALON ~~~~~\n"

echo -e "Welcome to Beauty Salon, how may I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry, we do not have any service available at this moment."
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a number"
  else
    SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    NAME_SERV=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    if [[ -z $SERVICE_AVAILABLE ]]
      then
      MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

          fi
        echo -e "\nWhat time would you like your $NAME_SERV, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_SERVICE_RESULT ]]
          then
            echo -e "\nI have put you down for a $NAME_SERV at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
         fi
      fi
    fi
  fi
fi
}

MAIN_MENU