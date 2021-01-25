#lang racket

;; import
(require 2htdp/universe)
(require "game/sv_network_waiting.rkt")
(require "game/sv_network_ingame.rkt")
(require "game/sv_connect.rkt")
(require "game/sv_disconnect.rkt")
(require "game/sh_structs.rkt")
(require "game/sv_tick.rkt")
(require "game/sh_config.rkt")

;; exports
(provide launch-server)

;; [message] is called whenever we receive a message f rom a client
(define (message currentWorld connection msg)
  (if (worldWaitingForPlayers currentWorld)
    (messageWaiting currentWorld connection msg)
    (messageIngame currentWorld connection msg)
  )
)



;;[launch-server] calls universe to create the server
(define (launch-server) 
  (universe (serversideWorld '() #t (+ (current-seconds) (* 60 5)) "" '() '() 0)
    (on-new connect-client)
    (on-disconnect disconnect-client)
    (on-msg message)
    (on-tick gameTick (/ 1 gameServerFPS))
  )
)

;;[launch-server] calls universe to create the server with port
(define (launch-server-withport ourport) 
  (universe (serversideWorld '() #t (+ (current-seconds) (* 60 5)) "" '() '() 0)
    (on-new connect-client)
    (on-disconnect disconnect-client)
    (on-msg message)
                (port ourport)
    (on-tick gameTick (/ 1 gameServerFPS))
  )
)

(define (launch-server-cmdline)
  (define cmdline (current-command-line-arguments))

  (if (vector-empty? cmdline)
      (and
       (println "Launching server for local playing")
       (launch-server)
      )
      (and
       (println "Launching server with port")
       (println (vector-ref cmdline 0))
       (launch-server-withport (string->number (vector-ref cmdline 0)))
      )
  )
)

;(launch-server-cmdline)

;(launch-server-withport 27015) 