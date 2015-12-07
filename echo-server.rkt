#lang racket

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

(define (accept-and-handle listener)
  (define cust (make-custodian))
  (parameterize ([current-custodian cust])
    (define-values (in out) (tcp-accept listener))
    (thread
     (λ ()
       (handle in out)
       (close-input-port in)
       (close-output-port out))))
  (thread (λ ()
            (sleep 10)
            (custodian-shutdown-all cust))))

;; A "simplified" version of Racket's copy-port, with some modifications
;; so that it recognizes an exit command.
(define (handle in out)
  (define buffer (make-bytes 4086))
  (define (read-write-loop)
    (define num-read-bytes (read-bytes-avail! buffer in))
    (when (and (not (eof-object? num-read-bytes))
               (not (string=? "exit\r\n"
                              ; converts to string and trims off garbage bytes
                              (substring
                               (bytes->string/utf-8 buffer) 0 6))))
      ;; using write-bytes-avail, we don't need to call flush-output
      ;; or close-output-port in order to send data
      (write-bytes-avail buffer out 0 num-read-bytes)
      (read-write-loop)))
  ;; now, we loop forever until user disconnects, issues the "exit" command,
  ;; or we explicitly stop the server ourselves
  (read-write-loop))
