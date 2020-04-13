#!/usr/bin/env bash
source src/get_subscription.sh
source src/get_region.sh
source src/get_usage.sh

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

# display usage
clear
echo -e $header
# display

# VM type name / in use / limit / capacity / capacity%
# vm_name[vm_id] vm_in_use[vm_id] vm_limit[vm_id] vm_avail[vm_id] vm_avail_per[vm_id]

exit

while :
do
	clear
	echo -e $header
	echo ""
	echo "1) Check VM quota"
	echo "2) Quit"
	echo ""
	read -p "Enter option: " opt

	case $opt in
	1)
		select_vm_type ${selected_region}
		read -p "Press [Enter] key to continue..." readEnterKey
		;;
	2)
		echo "Exiting..."
		exit 0
	esac
done
