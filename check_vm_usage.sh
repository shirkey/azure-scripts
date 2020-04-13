#!/usr/bin/env bash
source src/get_subscription.sh
source src/get_region.sh
source src/get_usage.sh

select_subscription
select_region
select_vm_type ${selected_region}
get_vm_usage_by_region_and_id ${selected_region} ${selected_vm}
