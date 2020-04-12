#!/usr/bin/env bash
IFS=","
declare -a sub_names

function get_subscriptions()
{
sub_names=($(az account list | jq -s '[ .[][].name ] | join(",")'  | tr -d "\"" ))
sub_ids=($(az account list | jq -s '[ .[][].id ] | join(",")'  | tr -d "\"" ))
}

function select_subscription() 
{
PS3="Select subscription: "
get_subscriptions
select sub_name in ${sub_names[@]}
do 
subscription=${sub_ids[${REPLY}-1]}
echo "Selected: ${sub_name} (Subscription: ${subscription})"
break
done
}

select_subscription
echo  ${subscription}
