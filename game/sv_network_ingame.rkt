#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sv_network_ingame_bomb.rkt")
(require "sv_network_ingame_move.rkt")
(require "sv_network_ingame_respawn.rkt")
(require "sv_network_ingame_latejoin.rkt")

(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [messageIngame] calls the right ingame networking function for the current messagetype
(define (messageIngame currentWorld client msg)
  (define msgHeader (car msg))

  (case msgHeader
    [("movedto") (messageIngamePlayerMovedTo currentWorld client (cdr msg))]
    [("bomb") (messageIngamePlayerLayedBomb currentWorld client (cdr msg))]
    [("respawn") (messageIngamePlayerRespawn currentWorld client (cdr msg))]
    [("imready") (messageIngamePlayerLateJoin currentWorld client (cdr msg))]

    [else (saveWorldState currentWorld)]
  )
)