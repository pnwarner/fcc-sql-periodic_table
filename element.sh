#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

NOT_FOUND_ERR() {
  echo I could not find that element in the database.
}

OUTPUT_MESSAGE() {
    # 1 atomic number
    # 2 name
    # 3 symbol
    # 4 type
    # 5 atomic mass
    # 6 melting point
    # 7 boiling point
    echo "The element with atomic number $1 is $2 ($3). It's a $4, with a mass of $5 amu. $2 has a melting point of $6 celsius and a boiling point of $7 celsius."  
}

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO_QUERY="$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $1;")"
  elif [[ $(echo "$1" | wc -m) -le 3 ]]
  then
    ELEMENT_INFO_QUERY="$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol ILIKE '$1';")"
  else
    ELEMENT_INFO_QUERY="$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name ILIKE '$1';")"
  fi
  if [[ -z $ELEMENT_INFO_QUERY ]]
  then
    echo I could not find that element in the database.
  else
    echo $ELEMENT_INFO_QUERY | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME
    do
       ELEMENT_PROPERTIES="$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER;")"
       echo "$ELEMENT_PROPERTIES" | while IFS="|" read TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
       do
          OUTPUT_MESSAGE $ATOMIC_NUMBER $NAME $SYMBOL $TYPE $ATOMIC_MASS $MELTING_POINT $BOILING_POINT
       done
    done
  fi
fi
