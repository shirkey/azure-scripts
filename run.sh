#!/usr/bin/env bash
declare -a region_names
declare -a region_ids

declare region_file="/tmp/regions.json"

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

declare selected_region
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
IFS=","
declare -a sub_names
declare -a sub_ids

declare subscription_file="/tmp/subscriptions.json"

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

declare selected_subscription
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

declare -a vm_ids
declare -A vm_name
declare -A vm_limit
declare -A vm_capacity
declare -A vm_usage
declare -A vm_usage_percent

function load_vm_data()
{
	IFS=","
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"

        if [ ! -f "${vm_usage_file}" ]; then
            echo "Retrieving VM usage and limits for ${selected_region}, caching to ${vm_usage_file}"
            $(az vm list-usage --location ${selected_region} > ${vm_usage_file})
        else
            echo "Retrieving VM usage and limits for ${selected_region} from cache (${vm_usage_file})"
        fi
	echo "Data loaded"
}

function get_vm_usage()
{
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"
	local vm_usage_file_ext="/tmp/usage_${selected_region}_vm_ext.json"

	load_vm_data ${selected_region} 
	$(jq -s '.[][] | { "id": .name.value, "name": .localName, "limit": (.limit | tonumber), "usage": (.currentValue | tonumber), "capacity": ((.limit | tonumber) - (.currentValue | tonumber)) } | {"id": .id, "name": .name, "limit": .limit, "capacity": .capacity, "usage": .usage, "usagePercent": ( if .limit > 0 then 100*(.usage / .limit) else 0 end)}' ${vm_usage_file} > ${vm_usage_file_ext})

	vm_ids=($(jq -s '.[][] | select(.localName | contains("Family"))? | .name.value' ${vm_usage_file} | tr -d "\"" | tr "\r\n" "," ))
	declare -a vm_names=($(jq -s '.[][] | select(.localName | contains("Family"))? | .localName' ${vm_usage_file} | tr -d "\"" | tr "\r\n" ","))
	declare -a vm_limits=($(jq -s '.[][] | select(.localName | contains("Family"))? | .limit' ${vm_usage_file} | tr -d "\"" | tr "\r\n" "," ))
	declare -a vm_capacities=($(jq -s '.[] | select(.id | contains("Family"))? | .capacity' ${vm_usage_file_ext} | tr -d "\"" | tr "\r\n" ","))
	declare -a vm_usages=($(jq -s '.[] | select(.id | contains("Family"))? | .usage' ${vm_usage_file_ext} | tr -d "\"" | tr "\r\n" ","))
	declare -a vm_usages_percent=($(jq -s '.[] | select(.id | contains("Family"))? | .usagePercent' ${vm_usage_file_ext} | tr -d "\"" | tr "\r\n" ","))
	
	for idx in ${!vm_ids[@]}
	do 
		vm_name[${vm_ids[${idx}]}]="${vm_names[${idx}]}"
		vm_limit[${vm_ids[${idx}]}]="${vm_limits[${idx}]}"
		vm_capacity[${vm_ids[${idx}]}]="${vm_capacities[${idx}]}"
		vm_usage[${vm_ids[${idx}]}]="${vm_usages[${idx}]}"
		vm_usage_percent[${vm_ids[${idx}]}]="${vm_usages_percent[${idx}]}"
	done
}

declare selected_vm

function select_vm_type()
{ 
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"
	get_vm_usage ${selected_region} 

	#IFS=","
	declare -a vm_names=($(jq -s '.[][] | select(.localName | contains("Family"))? | .localName' ${vm_usage_file} | tr -d "\"" | tr "\r\n" ","))
	declare -a vm_ids=($(jq -s '.[][] | select(.localName | contains("Family"))? | .name.value' ${vm_usage_file} | tr -d "\"" | tr "\r\n" "," ))

	PS3="Select VM type: "
	select vm_name in ${vm_names[@]}
	do
		selected_vm=${vm_ids[${REPLY}-1]}
		echo "You selected: ${vm_name} (VM ID: ${selected_vm})"
		get_vm_usage_by_region_and_id ${selected_region} ${selected_vm}
		break
	done
}

function get_vm_usage_by_region_and_id()
{
        local selected_region="${1:?Please provide a region name as argument}"
	local selected_vm="${2:?Please provide the vm type id}"
	local vm_usage_file_ext="/tmp/usage_${selected_region}_vm_ext.json"
	get_vm_usage ${selected_region}

	filter=".[] | select(.id | contains(\"${selected_vm}\"))?"
	echo "Usage information for ${selected_vm} in region ${selected_region}"
	echo $(jq -s ${filter} ${vm_usage_file_ext})
	echo "Usage information (from associative array):"
	echo "Name: ${vm_name[${selected_vm}]}"
	echo "Limit: ${vm_limit[${selected_vm}]}"
	echo "Capacity: ${vm_capacity[${selected_vm}]}"
	echo "Usage: ${vm_usage[${selected_vm}]}"
	echo "Usage Percent: ${vm_usage_percent[${selected_vm}]}"
}

function show_vm_usage_by_region()
{
        local selected_region="${1:?Please provide a region name as argument}"
	get_vm_usage ${selected_region}

	IFS=$'\n' sorted=($(sort <<<"${vm_ids[*]}"))
	for vmid in ${sorted[@]}
	do
		#echo ${vmid}
		vmname=${vm_name[${vmid}]}
		vmlimit=${vm_limit[${vmid}]}
		if [ $vmlimit -gt 0 ]; then
			vmusagepercent=${vm_usage_percent[${vmid}]}
			if [ ${vmusagepercent} -lt 80 ]; then
				vmname="\e[1;32m${vmname}"
			else
				vmname="\e[1;31m${vmname}"
			fi
			vmusage=${vm_usage[${vmid}]}
			vmcapacity=${vm_capacity[${vmid}]}
		else
			vmname="\e[1;30m${vmname}"
			vmusagepercent="n/a"
			vmcapacity="n/a"
			vmusage="n/a"
		fi
		printf "%50b: %3b%% (%4b of %4b)\e[0m\n" $vmname $vmusagepercent ${vmusage} ${vmlimit}
	done
}

slug="*************************************"
header=$"${slug}\n     Azure Usage Checker\n${slug}\n"

clear
echo -e ${header}
select_subscription

header+=" - Subscription: ${selected_subscription}\n"
clear
echo -e ${header}
select_region
header+=" - Region: ${selected_region}\n"

while :
do
	clear
	echo -e $header
	echo ""
	echo "1) Show VM usage"
	echo "2) Quit"
	echo ""
	read -p "Enter option: " opt

	case $opt in
	1)
		show_vm_usage_by_region ${selected_region}
		read -p "Press [Enter] key to continue..." readEnterKey
		;;
	2)
		echo "Exiting..."
		exit 0
	esac
done
