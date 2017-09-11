#!/bin/sh
#
# http.sh -- HTTP/1.1 webserver
#
# Usage with socat:
#   socat TCP4-LISTEN:4327,fork,reuseaddr,bind=127.0.0.1 EXEC:"$PWD/http.sh"
#
# 2016 Jon Simons <jon@jonsimons.org>

IFS='
'

#
# First consume the HTTP request, saving interesting fields here.
#
get_uri=""
while read http_header; do
	line=$(echo "$http_header" | tr -d "\r")

	if [ -z "$line" ]; then break; fi # HTTP request completely consumed

	escaped_line=$(echo "$line" | sed -e 's-%2F-/-g' | sed -e 's-%20- -g')
	uri=$(echo "$escaped_line" | awk '{ print $2 }')

	case $escaped_line in
	GET*)
		get_uri=$escaped_line
		;;
	'X-Forwarded-For'*)
		echo "xff_ip=$escaped_line" >&2
		;;
	esac
done

#
# Dispatch the request according to what we consumed.
#
case $get_uri in
'GET /_ping HTTP/1.1')
	cat - <<-200
	HTTP/1.1 200 OK
	
	PONG
	200
	break
	;;

*)
	cat - <<-500
	HTTP/1.1 500 Internal Server Error
	
	500
	break
	;;

esac

# vim:noet:ts=8:sw=8
