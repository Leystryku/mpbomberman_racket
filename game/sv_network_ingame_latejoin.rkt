#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [messageIngamePlayerLateJoin] is called whenever someone joins while the game is not in waiting stage and sends the late joiner the gamefield
(define (messageIngamePlayerLateJoin currentWorld connection message)
  (sendToClient currentWorld connection
    (append
      (list "game_start")
      (map fieldElementToList (serversideWorld-gameField currentWorld))
    )
  )
)