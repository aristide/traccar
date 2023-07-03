#!/bin/bash 

set -e

wait_for_service() {
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      nc -z $service $port
      result=$?
    done
    echo "[$i/$max_try] $service:${port} is available."
}

wait_for_file() {
    local file_name=$1
    local retry_seconds=5
    local max_try=100
    let i=1

    test -f $file_name
    fresult=$?

    until [ $fresult -eq 0 ]; do
      echo "[$i/$max_try] check for ${file_name}..."
      echo "[$i/$max_try] ${file_name} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${file_name} does still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      test -f $file_name
      fresult=$?

    done
    echo "[$i/$max_try] ${file_name} is available."
}

if [ ! -z "$SERVICE_PRECONDITION" ]; then 
    echo "Wait for service"
    for i in ${SERVICE_PRECONDITION[@]}
    do
        wait_for_service ${i}
    done
fi

if [ ! -z "$FILE_PRECONDITION" ]; then 
    echo "Wait for file"
    for y in ${FILE_PRECONDITION[@]}
    do
        wait_for_file ${y}
    done
fi

exec $@