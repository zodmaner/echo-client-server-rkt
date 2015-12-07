#lang racket

;; A simple multi-threaded echo server. Returns a function
;; that can be used to properly shutdown the server.
(define (echo-server port)
  (define server-cust (make-custodian))
  (parameterize ([current-custodian server-cust])
    (define listener (tcp-listen port))
    (define (loop)
      (accept-and-handle listener)
      (loop))
    (thread loop))
  (λ ()
    (custodian-shutdown-all server-cust)))

;; A simple multi-threaded accept and handle function.
(define (accept-and-handle listener)
  (define-values (in out) (tcp-accept listener))
  (thread
   (λ ()
     (handle in out)
     (close-input-port in)
     (close-output-port out))))

;; A handle function, which implements a "simplified" version of
;; Racket's copy-port (which seems to be the best and most reliable
;; way of reading and writing data to and from TCP ports in Racket).
(define (handle in out)
  (define buffer (make-bytes 4086))
  (define (read-write-loop)
    (define num-read-bytes (read-bytes-avail! buffer in))
    (when (not (eof-object? num-read-bytes))
      ;; using write-bytes-avail, we don't need to call flush-output
      ;; or close-output-port in order to send data
      (write-bytes-avail buffer out 0 num-read-bytes)
      (read-write-loop)))
  ;; now, we loop forever until user disconnects
  ;; or we explicitly stop the server ourselves
  (read-write-loop))
