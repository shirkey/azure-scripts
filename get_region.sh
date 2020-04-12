#!/usr/bin/env bash
declare -a region_names
declare -a region_ids

declare region_file="/tmp/regions.json"
declare selected_region

function get_regions()
{
IFS=","
if [ ! -f "${region_file}" ]; then
    echo "Retrieving regions, caching to ${region_file}"
    $(az account list-locations > ${region_file})
else
    echo "Retrieving regions from cache (${region_file})"
fi
region_names=($(jq -s '[ .[][].displayName ] | join(",")' ${region_file} | tr -d "\""))
region_ids=($(jq -s '[ .[][].name ] | join(",")' ${region_file} | tr -d "\""))
}

function select_region() 
{
PS3="Select region: "
get_regions
select region_name in ${region_names[@]}
do 
selected_region=${region_ids[${REPLY}-1]}
echo "You selected: ${region_name} (Region: ${selected_region})"
break
done
}
