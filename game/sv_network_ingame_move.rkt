#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [processPlayerMoved] updates the players x,y,facingDir and facingSince on the server
(define (processPlayerMoved currentWorld connection newDirPos)
  (let ([clientData (getClientData (getClientByConnection currentWorld connection))])
    (and
      (set-player-x! clientData (first (first newDirPos)))
      (set-player-y! clientData (second (first newDirPos)))
      (set-player-facingDir! clientData (third newDirPos))
      (set-player-facingSince! clientData (current-inexact-milliseconds))

      currentWorld
    )
  )
)

;; [messageIngamePlayerMovedTo] calls the functions to process a client has moved and the funcs to send it to all clients
(define (messageIngamePlayerMovedTo currentWorld connection newDirPos)
  (define clientDatas (getClientDatas currentWorld))
  
  (sendToAllClients
    (processPlayerMoved currentWorld connection newDirPos)
    (append
      (list "player_move" (iworld-name connection))
      newDirPos
    )
  )
)