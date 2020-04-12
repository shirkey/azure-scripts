#!/usr/bin/env bash
IFS=","
declare -a sub_names

function get_regions()
{
region_names=($(az account list-locations | jq -s '[ .[][].displayName ] | join(",")'  | tr -d "\"" ))
region_ids=($(az account list-locations | jq -s '[ .[][].name ] | join(",")'  | tr -d "\"" ))
}

function select_region() 
{
PS3="Select region: "
get_regions
select region_name in ${region_names[@]}
do 
region=${region_ids[${REPLY}-1]}
echo "Selected: ${region_name} (Region: ${region})"
break
done
}

select_region
echo  ${region}
