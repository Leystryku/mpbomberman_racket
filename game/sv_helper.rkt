#lang racket

;; import
(require 2htdp/universe)
(require "sh_config.rkt")
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;; [saveWorldState] Saves the current world state
(define (saveWorldState currentWorld)
  (make-bundle
    currentWorld
    '()
    '()
  )
)

;; [makeClientsMail] Sends a message to all connections given
(define (makeClientsMail connections msg)
  (for/list ([connection connections])
    (make-mail connection msg)
  )
)

;; [getClientConnection] Gets the connection of a client
(define (getClientConnection fullClient)
  (clientData-connection fullClient)
)

;; [getClientConnection] Gets the connection of all clients
(define (getClientConnections currentWorld)
  (define clients (serversideWorld-clients currentWorld))

  (for/list ([client clients])
    (getClientConnection client)
  )
)


;; [getClientData] Gets the client data/player data of a client
(define (getClientData fullClient)
  (clientData-player fullClient)
)

;; [getClientDatas] Gets the client data/player data of all clients
(define (getClientDatas currentWorld)
  (define clients (serversideWorld-clients currentWorld))

  (for/list ([client clients])
    (getClientData client)
  )
)

;; [getClientByConnection] Gets a client by his connection
(define (getClientByConnection currentWorld connection)
  (define clients (serversideWorld-clients currentWorld))

  (findf
    (lambda (client)
      (equal?
        (getClientConnection client)
        connection
      )
    )
    clients
  )
)

;; [getClientIndex] Gets the index of a client
(define (getClientIndex currentWorld client)
  (index-of
    (serversideWorld-clients currentWorld)
    client
  )
)

;; [getClientIndexByConnection] Gets the index of a client based on his connection
(define (getClientIndexByConnection currentWorld connection)
  (getClientIndex
    currentWorld
    (getClientByConnection
      currentWorld
      connection
    )
  )
)

;; [getConnectionByData] Gets a connection by a clientData
(define (getConnectionByData currentWorld clientData)
  (define clients (serversideWorld-clients currentWorld))

  (findf
    (lambda (client)
      (and
        (equal?
          (getClientData client)
          clientData
        )
        (getClientConnection client)
      )
    )
    clients
  )
)

;; [getClientByUser] Gets a client by given username
(define (getClientByUser currentWorld user)
  (define clients (serversideWorld-clients currentWorld))

  (findf
    (lambda (client)
      (and
        (equal?
          (player-user (getClientData client))
          (getClientData client)
        )
      )
    )
    clients
  )
)

;; [sendToAllClients] Sends a message to all clients using makeClientsMail
(define (sendToAllClients currentWorld msg)
  (define clientMails (makeClientsMail (getClientConnections currentWorld) msg))

  (make-bundle
    currentWorld
    clientMails
    '()
  )
)

;; [sendToClient] Sends a message to one client
(define (sendToClient currentWorld connection msg)
  (make-bundle
    currentWorld
    (list
      (make-mail connection msg)
    )
    '()
  )
)

;; [addClientToClientList] Adds a client to the client list
(define (addClientToClientList clients client)
  (append clients (list client))
)

;; [addClientToClientList] Adds a client to the current world
(define (addClient currentWorld client)
  (define clients (serversideWorld-clients currentWorld))

  (and
    (set-serversideWorld-clients!
      currentWorld
      (addClientToClientList clients client)
    )
    currentWorld
  )
)

;; [addClientToClientList] Removes a client from the client list based on his username
(define (removeClientFromClientList clients stringPlayerNumber)
  (filter
    (lambda (client)
      (not
        (equal?
          (player-user (clientData-player client))
          stringPlayerNumber
        )
      )
    )
    clients
  )
)

;; [removeClient] Removes a client from the world based on his user
(define (removeClient currentWorld stringPlayerNumber)
  (define clients (serversideWorld-clients currentWorld))

  (and
    (set-serversideWorld-clients!
      currentWorld
      (removeClientFromClientList
        clients
        stringPlayerNumber
      )
    )
    currentWorld
  )
)

;; [getSpawnPos] Gets the spawn pos for a client based on his username
(define (getSpawnPos user)
  (list-ref
    gamePlayerSpawns
    (- (string->number user) 1)
  )
)

;; [processPlayerDeath] Processses the death of a player
(define (processPlayerDeath currentWorld playerKilled byUser)
  (define newLives (- (player-lives playerKilled) 1))

  
  (and
    (set-player-alive! playerKilled #f)
    (set-player-lives! playerKilled newLives)
    (if
      (not
        (equal?
          (player-user playerKilled)
          byUser
        )
      )
      (givePlayerScore currentWorld byUser)
      currentWorld
    )
  )
)

;; [givePlayerScore] Gives a player one more score point
(define (givePlayerScore currentWorld killer)
  (define killingPlayer
    (first
      (filter
        (lambda (x)
          (equal? (player-user x) killer)
        )
        (getClientDatas currentWorld)
      )
    )
  )

  (and
    (set-player-score!
      killingPlayer
      (add1 (player-score killingPlayer))
    )
    currentWorld
  )
)


;; [doPlayerKill] Calls the functions for processing a players death and transmits it to all clients
(define (doPlayerKill currentWorld playerKilled byUser)
  (sendToAllClients
    (processPlayerDeath
      currentWorld
      playerKilled
      byUser
    )
    (list
      "player_death"
      (player-user playerKilled)
      byUser
    )
  )
)

;; [processPlayerSpawn] Processes the spawn of a player
(define (processPlayerSpawn currentWorld player spawnPos)
  (and
    (set-player-x! player (first spawnPos))
    (set-player-y! player (second spawnPos))
    (set-player-alive! player #t)
    currentWorld
  )
)

;; [doPlayerSpawn] Calls the functions for processing the spawn of a player and sends it to all clients
(define (doPlayerSpawn currentWorld player user)
  (sendToAllClients
    (processPlayerSpawn
      currentWorld
      player
      (getSpawnPos user)
    )
    (list
      "player_spawn"
      user
      (getSpawnPos user)
      'right
    )
  )
)

;; [generatePlayerStruct] creates a {player} fullfilling the given args
(define (generatePlayerStruct stringTexture pos speed user)
  (player
    #f
    (first pos)
    (second pos)
    'right
    (current-inexact-milliseconds)
    speed
    #t
    #f
    gamePlayerLifes
    0
    user
  )
)

;; [generatePlayer] creates a {player} based on his username and speed
(define (generatePlayer user speed)
  (case user
    [("1") (generatePlayerStruct"/assets/sprites/player1.png" (getSpawnPos user) speed user)]
    [("2") (generatePlayerStruct"/assets/sprites/player2.png" (getSpawnPos user) speed user)]
    [("3") (generatePlayerStruct"/assets/sprites/player3.png" (getSpawnPos user) speed user)]
    [("4") (generatePlayerStruct"/assets/sprites/player4.png" (getSpawnPos user) speed user)]
    [else (error 'GAME_MAXPLAYERS_IS_4) ]
  )
)

;; [doGameOver] Sends a gameover to all the clients for timing out
(define (doGameOver currentWorld)
  (sendToAllClients
    currentWorld
    (list
      "game_over"
      (getWinner currentWorld)
    )
  )
)


;; [getWinner] Gets the winner of the current game
(define (getWinner currentWorld)
  (define sortedGameScores
    (reverse
      (sort
        (map
          (lambda (x)
            (list
              (player-score x) (player-user x)
            )
          )
          (getClientDatas currentWorld)
        )
        #:key car <
      )
    )
  )

  (if (empty? sortedGameScores)
    currentWorld
    (if (< 1 (length sortedGameScores))
      (checkForDraw sortedGameScores)
      (first sortedGameScores)
    )
  )
)

;; [checkForDraw] Checks whether we're dealing with a draw right now
(define (checkForDraw sortedGameScores)
  (let* ([highestScorePair (first sortedGameScores)]
        [draw (= (first highestScorePair) (caadr sortedGameScores))])

    (if draw
      (list
        (first highestScorePair)
        "Draw"
      )
      highestScorePair
    )
  )
)