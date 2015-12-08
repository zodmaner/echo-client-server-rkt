# echo-client-server-rkt
A simple echo client and server in Racket that I created in order to learn TCP socket programming in Racket.

#### Usage 
###### Server
To start the server, open the echo-server.rkt file in Emacs Geiser, then enter the module and issue the following command in Geiser's REPL:

```racket
(define stop (echo-server 8080))
```

replace 8080 with your desired port.

To shutdown the server, invoke the `stop` function.

```racket
(stop)
```

###### Client
In order to start the client, issue the following command from the terminal:

```
$ racket echo-client.rkt 8080
```

again, replace 8080 with the port that your server use.

To shutdown the client, just type `exit` and press enter.

#### Known Issues
* For some reason, the `read-line` and `read-bytes-line` functions do not block and wait for user input when invoke in Geiser's REPL.
