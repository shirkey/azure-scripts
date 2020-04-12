#!/usr/bin/env bash
IFS=","
declare -a sub_names
declare -a sub_ids

declare subscription_file="/tmp/subscriptions.json"
declare selected_subscription

function get_subscriptions()
{
IFS=","
if [ ! -f "${subscription_file}" ]; then
    echo "Retrieving subscriptions, caching to ${subscription_file}"
    $(az account list > ${subscription_file})
else
    echo "Retrieving subscriptions from cache (${subscription_file})"
fi
sub_names=($(jq -s '[ .[][].name ] | join(",")' ${subscription_file} | tr -d "\"" ))
sub_ids=($(jq -s '[ .[][].id ] | join(",")' ${subscription_file} | tr -d "\"" ))
}

function select_subscription() 
{
PS3="Select subscription: "
get_subscriptions
select sub_name in ${sub_names[@]}
do 
selected_subscription=${sub_ids[${REPLY}-1]}
echo "Selected: ${sub_name} (Subscription: ${selected_subscription})"
break
done
}
