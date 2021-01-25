#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [messageIngamePlayerSpawn] calls the functions to for respawning a player has respawned, if he has not enough lives just saves the world
(define (messageIngamePlayerRespawn currentWorld connection message)
  (define canRespawnWhen (+ (current-inexact-milliseconds) (random bombMinimumExplodeDelay bombMaximumExplodeDelay)))
  (define player (getClientData (getClientByConnection currentWorld connection)))

  (if (> (player-lives player) 0)
    (doPlayerSpawn currentWorld player (iworld-name connection))
    (saveWorldState currentWorld)
  )
)