#lang racket

;; import
(require 2htdp/universe)
(require "bomberman_server.rkt")
(require "bomberman_client.rkt")
(require "game/cl_sound.rkt")


;; [run] calls launch-many-worlds to start the game and stops sound execution when closing
(define (run)
  (launch-many-worlds
   (and (create-world "1")
        (stop-our-sound))
   (and (create-world "2")
        (stop-our-sound))
   (and (launch-server)
        (stop-our-sound))
   ) 
  )

;;call run
(run)
