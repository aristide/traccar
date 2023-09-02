#!/bin/bash


# update admin user


# Update server
curl --request PUT \
  --url http://localhost:8082/api/server \
  --header "accept: application/json" \
  --header "authorization: Basic $INIT_ADMIN_USERNAME:$INIT_ADMIN_PASSWORD" \
  --header 'content-type: application/json' \
  --header 'user-agent: vscode-restclient' \
  --data '{"id": 1,"registration": false,"readonly": false,"deviceReadonly": false,"limitCommands": false,"map": "googleRoad","bingKey": null,"mapUrl": null,"poiLayer": null,"latitude": 14.720471,"longitude": -17.4587,"zoom": 17,"twelveHourFormat": false,"version": "5.8","forceSettings": false,"coordinateFormat": null,"openIdEnabled": false,"openIdForce": false,"attributes": {"timezone": "Africa/Dakar"}}'

