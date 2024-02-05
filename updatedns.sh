#!/bin/bash

InstanceID="i-0f060ac92e3f4a8ba"
HOSTEDZONENAME="prod.flowhealthlabs.com"
InstanceHost="t-ssh.$HOSTEDZONENAME"
InstanceExtIP="$(aws ec2 describe-instances --instance-ids ${InstanceID} --query 'Reservations[*].Instances[*].PublicIpAddress' --output
 text)"
HOSTEDZONEID=$(aws route53 list-hosted-zones --output json  | jq -r ".HostedZones[]|select(.Name==\"${HOSTEDZONENAME}.\").Id")
HOSTEDZONEID=${HOSTEDZONEID##*/}
echo "IP=$InstanceExtIP"
echo "HOSTEDZONEID=$HOSTEDZONEID"

JSON_DATA="{
\"Action\": \"UPSERT\",
\"ResourceRecordSet\": {
   \"Name\": \"$InstanceHost.\",
   \"Type\": \"A\",
   \"TTL\": 60,
   \"ResourceRecords\": [ { \"Value\": \"$InstanceExtIP\" } ]
   }
}
"
#JSON_DATA=${JSON_DATA%,*}
#echo $JSON_DATA
JSON_DATA="
{
\"Comment\": \"Update hostname in zone $HOSTEDZONEID\",
\"Changes\": [
  ${JSON_DATA}
  ]
}
"
echo $JSON_DATA > /tmp/$HOSTEDZONEID-update.json
sed -i "s/\\\052/*/g" /tmp/$HOSTEDZONEID-update.json #Replace \052 with * inside JSON
aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/$HOSTEDZONEID-update.json && echo "Rec
ords Updated"


