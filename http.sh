#!/bin/sh
#
# http.sh -- HTTP/1.1 webserver
#
# Single-file server a mock response fixtures.
#
# XXX requires socat.
# XXX TCP port number and bind address
# XXX logs to stderr
# XXX depends on grep, awk, sed
#
# Note this file uses hardtabs throughout for '<<-' heredocs.
# Run with ./mock-world.sh to self-serve using `socat`.
#
#
# 2016-2018 Jon Simons <jon@jonsimons.org>

if [ -z "$RUN_HTTP_SH" ]; then
  export RUN_HTTP_SH=1
  server_bin="$PWD/$(dirname $0)/$(basename $0)"
  exec socat TCP4-LISTEN:1235,fork,reuseaddr,bind=127.0.0.1 EXEC:"$server_bin"
fi

IFS='
'

#
# First consume the HTTP request, saving interesting fields here.
#
get_uri=""
post_uri=""
other=""
while read http_header; do
	line=$(echo "$http_header" | tr -d "\r")

	if [ -z "$line" ]; then break; fi # HTTP request completely consumed

	escaped_line=$(echo "$line" | sed -e 's-%2F-/-g' | sed -e 's-%20- -g')
	uri=$(echo "$escaped_line" | awk '{ print $2 }')

	case $escaped_line in
	GET*)
		get_uri=$escaped_line
		;;
	POST*)
		post_uri=$escaped_line
		;;
	'X-Forwarded-For'*)
		echo "xff_ip=$escaped_line" >&2
		;;
	'X-GitHub-Request-Id'*)
		echo "request_id=$(echo "$escaped_line" | grep -o -e '[^ ][^ ]*$')"
		;;
	*)
		other="$other\n$escaped_line"
		;;
	esac
done

echo "get_uri:  '$get_uri'" 1>&2
echo "post_uri: '$post_uri'" 1>&2
#if [ -z "$get_uri" -a -z "$post_uri" ]; then
  echo "other:    '$other'" 1>&2
#fi
echo "----" 1>&2

uri="$get_uri"
if [ -z "$uri" ]; then
  uri="$post_uri"
fi

#
# Dispatch the request according to what we consumed.
#
case $uri in
'GET /_ping HTTP/1.1')
	cat - <<-200
	HTTP/1.1 200 OK
	Connection: close
	
	PONG
	200
	break
	;;

*)
	cat - <<-500
	HTTP/1.1 500 Internal Server Error
	Connection: close
	
	500
	break
	;;

esac

# vim:noet:ts=8:sw=8
