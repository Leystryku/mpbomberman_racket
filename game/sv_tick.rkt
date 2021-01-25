#lang racket

;; import
(require 2htdp/image)
(require "cl_network.rkt")
(require "sh_config.rkt")
(require "cl_helper.rkt")
(require "cl_sound.rkt")
(require "sh_structs.rkt")
(require "sh_collisions.rkt")
(require "cl_input.rkt")
(require "sh_tick.rkt")
(require "sh_helper.rkt")
(require "sv_helper.rkt")

;; exports
(provide (all-defined-out))


;; [queuePlayerKill] Called whenever a bomb explosion should kill a player. We can not call make package here because bomb spawns in all 4 directions simultaniously so all 4 could kill, thus we use a queue
(define (queuePlayerKill currentWorld playerKilled byUser)
  (define currentKillQueue (serversideWorld-killQueue currentWorld))
  (set-serversideWorld-killQueue!
    currentWorld
    (append
      currentKillQueue
      (list
        (list
          playerKilled
          byUser
          (current-inexact-milliseconds)
        )
      )
    )
  )
)

;; [unqueuePlayerKill] Removes a player from the kill queue
(define (unqueuePlayerKill currentWorld currentKillQueue killQueueElement)
  (set-serversideWorld-killQueue! currentWorld
    (remove
      killQueueElement
      currentKillQueue
    )
  )
)


;; [onGameTickSharedTick] Calls the shared tick function
(define (onGameTickSharedTick currentWorld tickCount)
    (doSharedTick
      (list
        set-serversideWorld-gameField!
        serversideWorld-gameField
        queuePlayerKill
      )
      currentWorld
      (serversideWorld-gameField currentWorld)
      (getClientDatas currentWorld)
      tickCount
      #t
    )
)

;; [onGameTickProcessKills] Calls the functions to process queued kills
(define (onGameTickProcessKills currentWorld tickCount)
  (define currentKillQueue (serversideWorld-killQueue currentWorld))

  (if (empty? currentKillQueue)
    #f    
    (onGameTickProcessKill currentWorld currentKillQueue tickCount (car currentKillQueue))
  )
)


;; [onGameTickProcessKill] Processes a queued kill
(define (onGameTickProcessKill currentWorld currentKillQueue tickCount killQueueElement)
  (and
    (unqueuePlayerKill
      currentWorld
      currentKillQueue
      killQueueElement
    )
    (doPlayerKill
      currentWorld
      (first killQueueElement)
      (second killQueueElement)
    )
  )
)

;; [resetToWaitingStep1] is the first step in resetting the world
(define (resetToWaitingStep1 currentWorld)
  (and
    (println
      "Not enough players, resetting world"
    )
    (set-serversideWorld-tickCount!
      currentWorld
      -1000
    )
    (sendToAllClients
      currentWorld
      (list "game_reset")
    )
  )
)

;; [resetToWaitingStep2] is seocnd step in resetting the world
(define (resetToWaitingStep2 currentWorld)
  (serversideWorld '() #t 0 "" '() '() -50) ;wait a few ticks for network lib to stabilize
)

(define (resetToWaiting currentWorld tickCount)
  (cond
    [(> tickCount 0)
      (resetToWaitingStep1 currentWorld)
    ]
    [(> -100 tickCount)
      (and
        (resetToWaitingStep2 currentWorld)
      )
    ]
    [else 
      currentWorld
    ]
  )
)

;; fix for racket bug where universe reset doesnt properly reset universe
(define (resetToWaitingIfShould currentWorld tickCount)
  (define clients (serversideWorld-clients currentWorld))

  (if
    (or
      (> 0 tickCount)
      (and
        (= 1 (length clients))
        (not (serversideWorld-isInWaitingStage currentWorld))
      )
    )
    (resetToWaiting currentWorld tickCount)
    #f
  )
)

;; [onGameTickEnd] is called to check whether the games time is over or only one guy is left alive
(define (onGameTickGameEnd currentWorld)
  (define timeLeft (- (serversideWorld-endTime currentWorld) (current-seconds)))

  (if (>= 0 timeLeft)
    (doGameOver currentWorld)
    (saveWorldState currentWorld)
  )
)

;; [onGameTick] Logic for the server
(define (onGameTick currentWorld tickCount)
  (or
    (resetToWaitingIfShould currentWorld tickCount)
    (processTickOrder currentWorld tickCount)   
  )
)

;; [processTickOrder] Calls the tick functions in the correct order. We have to do this to make sure that only one bundle gets returned
(define (processTickOrder currentWorld tickCount)
  (define killsBundle (onGameTickProcessKills (onGameTickSharedTick currentWorld tickCount) tickCount))
  
  (if killsBundle
    killsBundle
    (onGameTickGameEnd currentWorld)
  )
)

;; [gameTick] Logic for when we the tickCount is 0 (happens whenever there's a new stage)
(define (gameTick currentWorld)
  (define tickCount (serversideWorld-tickCount currentWorld))

  (and
    (set-serversideWorld-tickCount!
      currentWorld
      (+ tickCount 1)
    )
    (onGameTick currentWorld tickCount)
  )
)