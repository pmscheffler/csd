# csd

This repos contains an iRule and a Datagroup config (via AS3) which will allow you to add your CSD tag to an existing virtual server.  

Note that since AS3 posts to a Partition, you'll need to create a new VIP in that Partition and add the iRule.

To run this, you'll need to get an access token from your BIG-IP (out of scope here)

Then you run your command:

curl --location --request POST 'https://{{Management IP}}/mgmt/shared/appsvcs/declare' \
--header 'X-F5-Auth-Token: YOUWOULDLIKETOKNOW' \
--header 'Content-Type: application/json' \
--data-raw 'contents of the JSON file'

