#lang racket

(define (echo-client port)
  (define-values (in out) (tcp-connect "127.0.0.1" port))
  (define (loop)
    ;; read-bytes-line (and read-line) only seems to block properly
    ;; when running from a command line or DrRacket
    (define echo-text (read-bytes-line (current-input-port)))
    (when (not (eof-object? echo-text))
      (define echo-text-length (bytes-length echo-text))
      (write-bytes-avail echo-text out 0 echo-text-length)
      ;; reads data from a server and stores them inside a buffer
      (define read-buffer (make-bytes 4086))
      (define num-read-bytes (read-bytes-avail! read-buffer in))
      (fprintf (current-output-port) "~A~%" (substring
                                             (bytes->string/utf-8 read-buffer) 0 num-read-bytes))
      (when (not (string=? "exit" (substring
                                   (bytes->string/utf-8 read-buffer) 0 4)))
        (loop))))
  (loop)
  (close-input-port in)
  (close-output-port out))

(echo-client 8081)
