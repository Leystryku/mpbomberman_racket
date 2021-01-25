#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_collisions.rkt")
(require "sv_gamefieldgen.rkt")
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;; [makeClientReady] stores that a client is ready
(define (makeClientReady client)
  (and
    (set-clientData-player!
      client
      (and
        (set-player-ready!
          (clientData-player client)
          #t
        )
        (clientData-player client)
      )
    )
    client
  )
)

;; [isClientReady]  Checks whether a client is ready
(define (isClientReady client)
  (player-ready (getClientData client))
)

;; [countPlayersReady] Gets the amount of players who are ready
(define (countPlayersReady clients)
  (count isClientReady clients)
)

;; [enoughPlayersReady] Checks whether enough players are ready based on gameMinimumPlayers
(define (enoughPlayersReady currentWorld)
  (define amountPlayersReady (countPlayersReady (serversideWorld-clients currentWorld)))

  (> amountPlayersReady gameMinimumPlayers)
)

;; [storeGameField] Stores the current gameField in our world
(define (storeGameField currentWorld gameField)
  (and
    (set-serversideWorld-gameField! currentWorld gameField)
    currentWorld
  )
)

;; [messageWaitingStartGame] Calls the functions for generating the gamefield, setting the start time, and sends it to all the clients
(define (messageWaitingStartGame currentWorld)
  (let* ([clientDatas (getClientDatas currentWorld)]
        [gameField (generateGameField currentWorld)]
        [storedGameField (storeGameField currentWorld gameField)]
        [fieldElementList (map fieldElementToList gameField)]
        [gameEndTime ( + (current-seconds) gameTime)]
        [gameSetEndTime (set-serversideWorld-endTime! currentWorld gameEndTime)])

    (sendToAllClients
      storedGameField 
      (append
        (list "game_start")
        fieldElementList 
        (list gameEndTime)
      )
    )
  )
)


;; [messageWaitingPlayerReady] Calls the functions to make a client ready, if enough players are ready calls the functions to make the game start
(define (messageWaitingPlayerReady currentWorld connection)
  (and (makeClientReady (getClientByConnection currentWorld connection))
    (let ([newWorldStarted (and (set-serversideWorld-isInWaitingStage! currentWorld #f) currentWorld)])

      (if (enoughPlayersReady currentWorld)
        (messageWaitingStartGame newWorldStarted)
        (and
          (set-serversideWorld-isInWaitingStage! currentWorld #t)
          currentWorld
        )
      )
    )
  )
)

;; [messageWaiting] Is called whenever a client sends a message while we're in the waiting state, calls [messageWaitingPlayerReady] when the msg is imready
(define (messageWaiting currentWorld connection msg)
  (if (equal? (car msg)  "imready") 
    (messageWaitingPlayerReady currentWorld connection)
    (saveWorldState currentWorld)
  )
)

;; [messageWaiting] Checks whether the world is in the waiting stage
(define (worldWaitingForPlayers currentWorld)
  (serversideWorld-isInWaitingStage currentWorld)
)