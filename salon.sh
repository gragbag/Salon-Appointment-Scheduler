#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Welcome To The Salon ~~~~~\n"

DISPLAY_SERVICES() {
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

MAIN_MENU() {
  
  if [[ $1 ]]; then
    echo -e "$1"
  fi

  #display services
  DISPLAY_SERVICES

  #read service_id_selected
  echo -e "\nPlease select a service"
  read SERVICE_ID_SELECTED

  while [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]; do
    echo -e "\nPlease select a valid number"
    DISPLAY_SERVICES
    read SERVICE_ID_SELECTED
  done

  #read customer_phone
  echo -e "\nEnter your phone number"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if phone is not registered
  if [[ -z $CUSTOMER_NAME ]]; then
    #then ask for a name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  #read time
  echo -e "\nEnter a time"
  read SERVICE_TIME

  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #insert into appointments
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  #get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  #print result
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."
  

  
}


MAIN_MENU "Welcome to my Salon, how may I help you?"
