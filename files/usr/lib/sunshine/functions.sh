#!/bin/sh

. /usr/share/libubox/jshn.sh

# sunshine_loadstatus portal [curl_args]
sunshine_loadstatus() {
	local portal
	local res

	if [[ -z "$1" ]]; then
		return 2 # ENOENT
	else
		portal="$1"
		shift
	fi

	res=$(curl -s "http://$portal/index.php/index/init" \
		-H 'Accept: application/json, text/javascript, */*; q=0.01' \
		-H 'X-Requested-With: XMLHttpRequest' \
		"$@")

	status=$?

	if  [[ $status -eq 0 && -n "$res" ]]; then
		json_cleanup
		json_load "$res"
	else
		return $status
	fi
}

sunshine_checkstatus() {
	local status info

	json_get_var status status
	json_get_var info info

	echo $info

	if [[ $status -eq 1 ]]; then
		return 0
	elif [[ $status -eq 0 ]]; then
		return 1 # EPERM
	else
		return $status
	fi
}

# sunshine_status portal [curl_args]
sunshine_status() {
	local status

	sunshine_loadstatus "$@" && sunshine_checkstatus

	status=$?

	json_cleanup

	return $status
}

# sunshine_login portal username domain password [enablemacauth] [curl_args]
sunshine_login() {
	local porta username domain password enablemacauth
	local res status info

	if [[ -z "$1" ]]; then
		return 2 # ENOENT
	else
		portal="$1"
		shift
	fi

	if [[ -z "$1" ]]; then
		return 1 # EPERM
	else
		username="$1"
		shift
	fi

	if [[ -z "$1" ]]; then
		return 1 # EPERM
	elif [[ "$1" = "internet" ]]; then
		domain=""
		shift
	else
		domain="$1"
		shift
	fi

	if [[ -z "$1" ]]; then
		return 1 # EPERM
	else
		password="$(echo -n "$1" | base64 -)"
		shift
	fi

	if [[ -z "$1" ]]; then
		enablemacauth="0"
	elif [[ "$1" = "1" -o "$1" = "0" ]]; then
		enablemacauth="$1"
		shift
	fi

	res=$(curl -s "http://$portal/index.php/index/login" \
		-X POST \
		-H 'Accept: application/json, text/javascript, */*; q=0.01' \
		-H 'Content-Type: application/x-www-form-urlencoded' \
		-H 'X-Requested-With: XMLHttpRequest' \
		--data-urlencode "username=$username" \
		--data-urlencode "domain=$domain" \
		--data-urlencode "password=$password" \
		--data-urlencode "enablemacauth=$enablemacauth" \
		"$@")

	status=$?

	if  [[ $status -eq 0 && -n "$res" ]]; then
		json_load "$res"
		json_get_var status status
		json_get_var info info
		json_cleanup

		echo "$info"

		if [[ $status -eq 1 ]]; then
			return 0
		elif [[ $status -eq 0 ]]; then
			return 1 # EPERM
		else
			return $status
		fi
	else
		return $status
	fi
}

# sunshine_logout portal [curl_args]
sunshine_logout() {
	local portal
	local res status info

	if [[ -z "$1" ]]; then
		return 2 # ENOENT
	else
		portal="$1"
		shift
	fi

	res=$(curl -s "http://$portal/index.php/index/logout" \
		-X POST \
		-H 'Accept: application/json, text/javascript, */*; q=0.01' \
		-H 'X-Requested-With: XMLHttpRequest' \
		"$@")

	status=$?

	if  [[ $status -eq 0 && -n "$res" ]]; then
		json_load "$res"
		json_get_var status status
		json_get_var info info
		json_cleanup

		echo "$info"

		if [[ $status -eq 1 ]]; then
			return 0
		elif [[ $status -eq 0 ]]; then
			return 1 # EPERM
		else
			return $status
		fi
	else
		return $status
	fi
}
