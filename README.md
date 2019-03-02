# SUNSHINE utilities

A set of functions used to interact with SUNSHINE - Internet Service Login which can found in Chinese colleges.

If your school uses a [captive portal](https://en.wikipedia.org/wiki/Captive_portal "Captive portal - Wikipedia") looked like this for authenication, you can use this script to make your [OpenWRT](https://openwrt.org/ "OpenWrt Project: Welcome to the OpenWrt Project") driven router automatically log into it for you.

![Screenshot](https://user-images.githubusercontent.com/8053733/53685814-92c13f80-3d5a-11e9-9f23-8561eda08a45.png)

After installing this package, create a [hotplug](https://openwrt.org/docs/guide-user/base-system/hotplug_lede "OpenWrt Project: Hotplug") script like this in `/etc/hotplug.d/iface/` so the router would try to log in after `wan` is up.

```bash
#!/bin/sh

# nwk_login.sh
# login to sunshine
# Version		: 2.2.0
# Author		: xymopen <xuyiming.open@outlook.com>
# Licensed		: BSD-2-Clause

WAN_IF="wan"
PORTAL="YOUR_CAPTIVE_PORTAL"
CURL_ARGS="\
	--interface ${DEVICE}\
	-H 'Accept-Language: zh-CN;q=0.9,zh;q=0.8'\
	-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.62 Safari/537.36'\
	-H 'Pragma: no-cache'\
	-H 'Cache-Control: no-cache'\
	-H 'Origin: http://$PORTAL/'\
	-H 'Referer: http://$PORTAL/index.php'\
"

if [[ "${INTERFACE}" = "$WAN_IF" ]]; then
	. /usr/share/libubox/jshn.sh
	. /usr/lib/sunshine/functions.sh

	case "${ACTION}" in
		"ifup")
			logger -t "nwk_login" -s "$WAN_IF is up. try login..."

			i=1

			while true; do
				sunshine_login "$PORTAL" $CURL_ARGS "YOUR_USERNAME" "YOUR_ISP" "YOUR_PASSWORD"

				if [ $i -lt 5 ] && sunshine_loadstatus "$PORTAL" $CURL_ARGS && sunshine_checkstatus; then
					logger -t "nwk_login" -s "login succeed."
					json_get_var username logout_username

					if [ "$username" = "YOUR_USERNAME" ]; then
						logger -t "nwk_login" -s "username match."
						break
					else
						sunshine_logout "$PORTAL" $CURL_ARGS
						logger -t "nwk_login" -s "username mismatch."
					fi
				else
					logger -t "nwk_login" -s "login failed."
					i=$(expr "$i" + 1)
					sleep 5
				fi
			done
		;;
	esac
fi
```
