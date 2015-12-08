#lang racket

(require racket/cmdline)

;; A simple echo client, using the read & write bytes functions
;; to transfer data (which seems to be the most reliable means of
;; transferring data through TCP ports in Racket.
(define (echo-client hostname port)
  (define-values (in out) (tcp-connect hostname port))
  (define (loop)
    ;; *note* read-bytes-line (and read-line) only seems to properly
    ;; block for user inputs when running from a command line or DrRacket
    (define echo-text (read-bytes-line (current-input-port)))
    (when (not (eof-object? echo-text))
      (define echo-text-length (bytes-length echo-text))
      ;; writes data to a server
      (write-bytes-avail echo-text out 0 echo-text-length)
      ;; reads data from a server and stores them inside a buffer
      (define read-buffer (make-bytes 4086))
      (define num-read-bytes (read-bytes-avail! read-buffer in))
      (fprintf (current-output-port) "~A~%"
               ; converts to string and trims off garbage bytes
               (substring
                (bytes->string/utf-8 read-buffer) 0 num-read-bytes))
      (when (not (string=? "exit"
                           (substring
                            (bytes->string/utf-8 read-buffer) 0 4)))
        (loop))))
  (loop)
  (close-input-port in)
  (close-output-port out))

;; stuffs related to command-line parsing
(define host-name (make-parameter "127.0.0.1"))
(define port-num
  (command-line
   #:program "echo-client"
   #:once-each
   ;; yeah, you can't use "-h" flag
   [("-H" "--host-name") hn
                         "The hostname to connect to"
                         (host-name hn)]
   #:args (port-num)
   port-num))

(echo-client (host-name) (string->number port-num))
