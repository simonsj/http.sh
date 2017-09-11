## http.sh

`http.sh` is a POSIX shell script HTTP/1.1 web server.

Use it together with [`socat`](http://www.dest-unreach.org/socat/doc/socat.html) like this example:

    socat TCP4-LISTEN:4327,fork,reuseaddr,bind=127.0.0.1 EXEC:"$PWD/http.sh"

## License

See the [UNLICENSE](https://github.com/simonsj/http.sh/blob/master/UNLICENSE) file for license rights and limitations.
