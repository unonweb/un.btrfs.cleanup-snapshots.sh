#!/bin/bash

# STATIC
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE}")"
SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
SCRIPT_DIR_NAME=$(dirname -- "$(readlink -f "${SCRIPT_DIR}")")
SCRIPT_NAME=$(basename -- "$(readlink -f "${BASH_SOURCE}")")
SCRIPT_PARENT=$(dirname "${SCRIPT_DIR}")

function validate_snap_name { # ${name}

    local snapshot_name="${1}"

    if [[ ! "${snapshot_name}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}$ ]]; then
        return 1
    else
		return 0
	fi
}

function main { # ${snapshots_dir} ${snapshots_max_num}
	
	if [ "${UID}" -ne 0 ]; then
		echo "<3>ERROR: This script must be run as root."
		exit 1
	fi

	if [[ -z "${1}" ]]; then
		echo "<3>ERROR: Argument missing: snapshots_dir"
		exit 1
	fi

	if [[ -z "${2}" ]]; then
		echo "<3>ERROR: Argument missing: snapshots_max_num"
		exit 1
	fi

	local snapshots_dir="${1}"
	local snapshots_max_num="${2}"
	local snapshots=("${snapshots_dir}/"*)
    local snapshot

	echo "<6>Checking: ${snapshots_dir}"
	echo "<6>Snapshots found: ${#snapshots[@]}. Threshold: ${snapshots_max_num}."

	# exit
	if [[ ${#snapshots[@]} -eq 0 ]]; then
		echo "<3>ERROR: No snapshots found in ${snapshots_dir}"
		exit 1
	fi
	
	# exit
    if [ ${#snapshots[@]} -le ${snapshots_max_num} ]; then
		echo "<6>Snapshots are below threshold. Exiting ..."
		exit 0
	fi

	# exit
	for snap in "${snapshots[@]}"; do
		local name=$(basename "${snap}")
		validate_snap_name "${name}"
		if [[ ! ${?} -eq 0 ]]; then
			echo "<3>ERROR: Invalid snapshot name format: ${name}. Exiting ..."
			exit 1
		fi
	done

	# cleanup
	for snapshot in $(printf "%s\n" "${snapshots[@]}" | sort | head -n -${snapshots_max_num}); do
		# sort: oldest up, newest down
		# head -n -3: exclude the last/the newest <num> files
		echo "<6>Removing surplus snapshot: ${snapshot}"
		btrfs subvolume delete "${snapshot}"
	done
}

main ${@}