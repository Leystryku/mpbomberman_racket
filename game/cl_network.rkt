#lang racket

;; imports
(require 2htdp/universe)
(require 2htdp/image)
(require "cl_sound.rkt")
(require "cl_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")
(require "sh_config_snds.rkt")

;; exports
(provide (all-defined-out))


;; [sendToServer] Sends the packet contained in msg to the server, with optional logging of msgtype
(define (sendToServer currentWorld msgtype msg)
  (if debugNetwork
      (and
        (println (string-append "SENDING TO SERVER: " msgtype))
        (make-package currentWorld msg)
      )
      (make-package currentWorld msg)
  )
)

;; [onReceiveGameStartParseFieldsParseBreakableTile] Parses a breakable Tile
(define (onReceiveGameStartParseFieldsParseBreakableTile e)
  (and
    (set-fieldElement-animatedTexture! e (animatedBreakableTile))
    e
  )
)

;; [onReceiveGameStartParseFieldsParseElement] Calls the right parsing function depending on the elementName
(define (onReceiveGameStartParseFieldsParseElement e)
  (define elementName (fieldElement-elementName e))

  (cond
    [(equal? elementName 'breakableTile) (onReceiveGameStartParseFieldsParseBreakableTile e)]
    [else e]
  )
)

;; [onReceiveGameStartParseField] Calls the right parsing function depending on the elementName
(define (onReceiveGameStartParseField field)
  (if (empty? field)
    '()
    (append
      (list
        (onReceiveGameStartParseFieldsParseElement (car field))
      )
      (onReceiveGameStartParseField (cdr field))
    )
  )
)

;; [onReceiveGameReset] Is called when the server tells us to reset our game
(define (onReceiveGameReset currentWorld message user)
  
  (and
    (println "game needs reset")
    (clientsideWorld "resetscreen" 0 0 '() '() '() #f #f #f user 0 "")
  )
)

;; [onReceiveGameStart] Sets our current state to ingame and calls the sets our gamefield to the parsed game field from the server
(define (onReceiveGameStart currentWorld message user)
  (define fieldElements (filter list? message))
  (define endTime (last message))
  (and
    (set-clientsideWorld-curState! currentWorld "ingame")
    (set-clientsideWorld-tickCount! currentWorld 0)
    (set-clientsideWorld-timeLeft! currentWorld (- endTime (current-seconds)))
    (set-clientsideWorld-endTime! currentWorld endTime)
    (set-clientsideWorld-gameField! 
    currentWorld
      (onReceiveGameStartParseField
        (map listTofieldElement fieldElements)
      )
    )
    currentWorld
  )
)

(define (onReceiveGameTime currentWorld message user)
    (set-clientsideWorld-timeLeft! currentWorld (cadr message))
    currentWorld
)

(define (onReceiveGameOver currentWorld message user)
    (set-clientsideWorld-curState! currentWorld "gameover")
    (set-clientsideWorld-winner! currentWorld (second message))
  currentWorld
)



;; [onReceiveGamePlayersParseGetTexture] Gets the right animated player texture depending on the user
(define (onReceiveGamePlayersParseGetTexture user)
  (case user
    [("1") animatedTexturesPlayer1]
    [("2") animatedTexturesPlayer2]
    [("3") animatedTexturesPlayer3]
    [("4") animatedTexturesPlayer4]
    [else (animatedTexturesPlayer1)]
  )
)

;; [onReceiveGamePlayersParse] Parses the player
(define (onReceiveGamePlayersParse players)
  (for/list ([player players])
    (define user (player-user player))
    (and 
      (set-player-animatedTextures! player (onReceiveGamePlayersParseGetTexture user))
      player
    )
  )
)

;; [onReceiveGamePlayers] Sets the current players in our world to the ones received from the server
(define (onReceiveGamePlayers currentWorld message user)
  (and 
    (set-clientsideWorld-players!
      currentWorld
      (onReceiveGamePlayersParse
        (map listToPlayer message)
      )
    )
    currentWorld
  )
)

;; [onReceivePlayerSpawnLocalPlayer] handles the stuff we display for when we die
(define (onReceivePlayerSpawnLocalPlayer currentWorld message user player)
  (and
    (play-our-sound sndSpawn)
    currentWorld
  )
)

;; [onReceivePlayerSpawnPlayer] Sets the players state to alive
(define (onReceivePlayerSpawnPlayer currentWorld message user player)
  (and
    (set-player-alive! player #t)
    (set-player-x! player (first (second message)))
    (set-player-y! player (second (second message)))
    (set-player-facingDir! player (third message))
    (set-player-facingSince! player (current-inexact-milliseconds))
    (if (equal? user (clientsideWorld-user currentWorld))
      (onReceivePlayerSpawnLocalPlayer currentWorld message user player)
      currentWorld
    )
  )
)

;; [onReceivePlayerSpawn] Sets the players state to alive and his position to the one sent by the server
(define (onReceivePlayerSpawn currentWorld message user)
  (define players (clientsideWorld-players currentWorld))

  (and
    (onReceivePlayerSpawnPlayer currentWorld message user (getPlayerByUser currentWorld (first message)))
    currentWorld
  )
)

;; [onReceiveDeathPlayerLocalPlayer] handles the stuff we display for when we die
(define (onReceiveDeathPlayerLocalPlayer currentWorld message user player)
  (and
    (play-our-sound sndDie)
    currentWorld
  )
)

;; [onReceivePlayerDeathPlayerFrag]
(define (onReceivePlayerDeathPlayerFrag currentWorld playerKilled killer)
  (if (equal? playerKilled killer)
    playerKilled
    (and
      (set-player-score! killer (+ (player-score killer) 1))
      killer
    )
  )
)

;; [onReceivePlayerDeathPlayer] Sets the players state to death
(define (onReceivePlayerDeathPlayer currentWorld message user player)
  (define newPlayerLives (- (player-lives player) 1))
  (define killer (getPlayerByUser currentWorld (second message)))

  (and
    (onReceivePlayerDeathPlayerFrag currentWorld player killer)
    (set-player-alive! player #f)
    (set-player-facingDir! player 'dying)
    (set-player-facingSince! player (+ 5000 (current-inexact-milliseconds)))

    (set-player-lives! player newPlayerLives)
    ;(resetPlayerAnimationFrames player (clientsideWorld-tickCount currentWorld))
    (if (equal? user (clientsideWorld-user currentWorld))
      (onReceiveDeathPlayerLocalPlayer currentWorld message user player)
      currentWorld
    )
  )
)

;; [onReceivePlayerDeath] Calls [onReceivePlayerDeathPlayer] for the player who has died
(define (onReceivePlayerDeath currentWorld message user)
  (define players (clientsideWorld-players currentWorld))

  (and
    (onReceivePlayerDeathPlayer currentWorld message user (getPlayerByUser currentWorld (first message)))
    currentWorld
  )
)

;; [onReceivePlayerMove] Sets the players position and directory to the one received from the server
(define (onReceivePlayerMove currentWorld message user)
  (define player (getPlayerByUser currentWorld (first message)))

  (if (or (not player) (equal? (car message) user))
    currentWorld
    (and
      (setPlayerPosPlayer
        player
        (first (second message))
        (second (second message))
        (third message)
      )
      currentWorld
    )
  )
)

;; [onReceivePlayerBombParse] Parses the new bomb received from the server
(define (onReceivePlayerBombParseExtraData currentWorld bombMsg user)
  (extraData-bomb
    (car bombMsg)
    #t
    (+
      (clientsideWorld-tickCount currentWorld)
      bombTickCountTillNextAnim
    )
    1
    (cadr bombMsg)
  )
)

(define (onReceivePlayerBombParse currentWorld bombMsg user)
  (fieldElement
    'bomb
    (caddr bombMsg)
    (cadddr bombMsg)
    1
    1
    (animatedTextureBomb)
    (onReceivePlayerBombParseExtraData currentWorld bombMsg user)
  )
)

;; [onReceivePlayerBomb] Adds the new bomb received from the server to our field
(define (onReceivePlayerBomb currentWorld message user)
  (define curField (clientsideWorld-gameField currentWorld))
  (define newFieldElement (onReceivePlayerBombParse currentWorld message user))

  (and
    (set-clientsideWorld-gameField! currentWorld
      (append curField (list newFieldElement))
    )
    currentWorld
  )
)

;; [onReceiveHandler] Receives a event from the server and calls the fitting handler
(define (onReceiveHandler currentWorld message user)
  (define event (car message))

  (case event
    [("game_over") (onReceiveGameOver currentWorld message user)]
    [("game_reset") (onReceiveGameReset currentWorld (cdr message) user)]
    [("game_start") (onReceiveGameStart currentWorld (cdr message) user)]
    [("game_players") (onReceiveGamePlayers currentWorld (cdr message) user)]
    [("player_spawn") (onReceivePlayerSpawn currentWorld (cdr message) user)]
    [("player_death") (onReceivePlayerDeath currentWorld (cdr message) user)]
    [("player_move") (onReceivePlayerMove currentWorld (cdr message) user)]
    [("player_bomb") (onReceivePlayerBomb currentWorld (cdr message) user)]
    [else currentWorld]
   )
)

;; [onReceiveHandler] Receives a event from the server, with optional logging and calls [onReceiveHandler]
(define (onReceive currentWorld message user)
  (if debugNetwork
    (and
      (println (string-append "RECEIVED FROM SERVER: " (car message)))
      (onReceiveHandler currentWorld message user)
    )
    (onReceiveHandler currentWorld message user)
  )
)
