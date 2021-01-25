#lang racket

;; import
(require 2htdp/image)
(require "cl_sound.rkt")
(require "cl_helper.rkt")
(require "cl_input.rkt")
(require "cl_network.rkt")
(require "sh_config.rkt")
(require "sh_structs.rkt")
(require "sh_collisions.rkt")
(require "sh_tick.rkt")
(require "sh_helper.rkt")
(require "sh_config_snds.rkt")

;; exports
(provide (all-defined-out))


;; [onGameStage] Does the initial setup for when tickCount is 0 (currently just playing the background music)
(define (onGameStage currentStage currentWorld)
  (cond
    [(equal? currentStage "titlescreen") (and (stop-our-sound) (play-our-sound sndTitlescreen) currentWorld)]
    [(equal? currentStage "loadingscreen") (and (stop-our-sound) (play-our-sound sndLoadingscreen) currentWorld)]
    [(equal? currentStage "ingame") (and (stop-our-sound) (play-our-sound sndIngame) currentWorld)]
    [#t]
  )
)

;; [onGameTickTitlescreen] Logic for titlescreen which should run every tick (just return world rn)
(define (onGameTickTitlescreen currentWorld)
  currentWorld
)

;; [onGameTickLoadingscreenGameReady] Logic for loadingscreen which should run when the user wants to start the game and certain amounts of ticks have passed
;; we do this intentionally so that you don't instantly enter the game and instead watch our epic loadingscreen for some seconds
(define (onGameTickLoadingscreenGameReady currentWorld)
  (sendToServer currentWorld "gameready" '("imready"))
)

;; [onGameTickLoadingscreen] Logic for loadingscreen
(define (onGameTickLoadingscreen currentWorld)
  (if (equal? (clientsideWorld-tickCount currentWorld) 150) ;we want to ensure the loadingscreen always displays so we send that we want the game to start only after these many ticks
    (onGameTickLoadingscreenGameReady currentWorld)
    currentWorld
  )
)

;; [onGameTickIngame] Logic for when we're ingame
(define (onGameTickIngame currentWorld tickCount)
  (define timeLeft (- (clientsideWorld-endTime currentWorld) (current-seconds)))
  (set-clientsideWorld-timeLeft! currentWorld timeLeft)
    (if (divisible? tickCount gameSharedTicksEvery)
      (doSharedTick (list set-clientsideWorld-gameField! clientsideWorld-gameField) currentWorld (clientsideWorld-gameField currentWorld) (clientsideWorld-players currentWorld) tickCount #f)
      currentWorld
    )
)

;; [onGameTick] Logic for when we're ingame
(define (onGameTick currentStage currentWorld tickCount)
  (case currentStage
    [("titlescreen") (onGameTickTitlescreen currentWorld)]
    [("loadingscreen") (onGameTickLoadingscreen currentWorld)]
    [("ingame") (onGameTickIngame currentWorld tickCount)]
    [("gameover") (onGameTickIngame currentWorld tickCount)]
    [else (error 'INVALID_STAGE)]
  )
)

;; [gameTickZero] Logic for when we the tickCount is 0 (happens whenever there's a new stage)
(define (gameTickZero currentStage currentWorld)
  (onGameStage currentStage currentWorld)
)

;; [gameTick] Logic for calling all the other functions responsible for handling logic when game running
(define (gameTickRunning currentWorld)

  (define setter (set-clientsideWorld-tickCount! currentWorld (+ (clientsideWorld-tickCount currentWorld) 1)))
  (define currentStage (clientsideWorld-curState currentWorld))
  (define tickCount (- (clientsideWorld-tickCount currentWorld) 1))
  (define currentWorldKeyTick (keyTick currentWorld (clientsideWorld-user currentWorld)))
  (define forceKeySend (clientsideWorld-forceKeySend currentWorld))

  (if (or forceKeySend (and currentWorldKeyTick (divisible? tickCount gameMoveTicksEvery)))
    (if forceKeySend ; fixes some weird bug where world gets overwritten even though the if should make sure it cant be
      (or (and (set-clientsideWorld-forceKeySend! currentWorld #f) currentWorldKeyTick) currentWorld)
      (or currentWorldKeyTick currentWorld)
    )
    (if (equal? tickCount 0)
      (onGameStage currentStage currentWorld)
      (onGameTick currentStage currentWorld tickCount)
    )
  )

)

;; [gameTick] Logic for calling all the other functions responsible for handling logic
(define (gameTick currentWorld)
  (if (equal? (clientsideWorld-curState currentWorld) "resetscreen")
    currentWorld
    (gameTickRunning currentWorld)
  )
)
