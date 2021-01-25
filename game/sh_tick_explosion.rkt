#lang racket

;; import
(require 2htdp/image)
(require "cl_sound.rkt")
(require "sh_config.rkt")
(require "sh_structs.rkt")
(require "sh_collisions.rkt")
(require "sh_helper.rkt")
(require "sh_tick_bomb.rkt")

;; export
(provide (all-defined-out))


;; [explosionTickSpreadExplode] Is responsible for turning breakable tiles into breakingTiles
(define (explosionTickSpreadExplodeBreakableTile currentWorld elements tickCount elemToBreak)
  (and
    (set-fieldElement-elementName! elemToBreak 'breakingTile)
    (set-fieldElement-animatedTexture! elemToBreak (animatedTextureBreakingTile))
    (set-fieldElement-extraData!
      elemToBreak
      (extraData-breakingTile 
        (+ breakingTileVanishInMs (current-inexact-milliseconds))
        (+ tickCount breakingTileTickCountTillNextAnim)
        1
      ) 
    )
    currentWorld
  )
)

;; [explosionTickSpreadExplodeBomb] Is responsible for exploding other bombs
(define (explosionTickSpreadExplodeBomb currentWorld elements tickCount elemToBreak)
  (if gameBombsCanExplodeEachOther
    (and
      (bombTickExplode
        currentWorld
        elements
        tickCount
        elemToBreak
        (fieldElement-extraData elemToBreak)
      )
      currentWorld
    )
    currentWorld
  )
)

;; [explosionTickSpreadExplode] Calls the right function to explode a given tile
(define (explosionTickSpreadExplode setGameFieldFn currentWorld elements tickCount elemToBreak)
  (if elemToBreak
    (cond
      [(equal? (fieldElement-elementName elemToBreak) 'breakableTile)
        (explosionTickSpreadExplodeBreakableTile
          currentWorld
          elements
          tickCount
          elemToBreak
        )
      ]
      [(equal? (fieldElement-elementName elemToBreak) 'bomb)
        (explosionTickSpreadExplodeBomb
          currentWorld
          elements
          tickCount
          elemToBreak
        )
      ]
      [else currentWorld]
    )
    currentWorld
  )
)

;; [explosionTickSpreadExplodeIfCan] Calls the right function to explode a given tile
(define (explosionTickSpreadExplodeIfcan setGameFieldFn currentWorld elements tickCount spreadX spreadY)
  (define elemToBreak (getEntByFieldPos elements spreadX spreadY))

  (and
    (explosionTickSpreadExplode
      setGameFieldFn
      currentWorld
      elements
      tickCount
      elemToBreak
    )
    currentWorld
  )
)

;; [explosionTickSpreadPos] Spreads the explosion further in its direction
(define (explosionTickSpreadPos setGameFieldFn currentWorld elements tickCount explosionData spreadX spreadY spreadType)
  (define vanishWhen (extraData-explosion-vanishWhen explosionData))
  (define spreadsLeft (extraData-explosion-spreadsLeft explosionData))
  (define ticksWhenNextAnim (+ explosionTickCountTillNextAnim tickCount))
  (define user (extraData-explosion-user explosionData))

  (addExplosionField
    setGameFieldFn
    currentWorld
    elements
    spreadX
    spreadY
    vanishWhen
    spreadType
    (- spreadsLeft 1)
    ticksWhenNextAnim
    user
  )
)

;; [explosionTickSpreadKillPlayer] Calls the functions to kill a player who entered the explosion
(define (explosionTickSpreadKillPlayer setGameFieldFn currentWorld elements tickCount explosionData player isServer)
  (define user (extraData-explosion-user explosionData))

  (if isServer
    (and
      ((third setGameFieldFn)
        currentWorld
        player
        user
      )
      currentWorld
    )
    currentWorld
  )
)

;; [explosionTickSpreadPosIfCan] Spreads bomb if possible, otherwise calls functions responsible for handling what we touched (other fields, players)
(define (explosionTickSpreadPosIfCan setGameFieldFn currentWorld elements players tickCount explosionData spreadX spreadY spreadType isServer)
  (cond
  [(getPlayerByFieldPos players spreadX spreadY)
    (explosionTickSpreadKillPlayer
      setGameFieldFn
      currentWorld
      elements
      tickCount
      explosionData
      (getPlayerByFieldPos players spreadX spreadY)
      isServer
    )
  ]
  [(canBombSpreadToField elements players spreadX spreadY)
    (explosionTickSpreadPos
      setGameFieldFn
      currentWorld
      elements
      tickCount
      explosionData
      spreadX
      spreadY
      spreadType
    )
  ]
  [else
    (explosionTickSpreadExplodeIfcan
      setGameFieldFn
      currentWorld
      elements
      tickCount
      spreadX
      spreadY
    )
  ]
)
)

;; [explosionTickSpreadDir] Makes the explosion store that this part spread and calls functions for spreading with position instead of dir
(define (explosionTickSpreadDir setGameFieldFn currentWorld elements players explosion tickCount explosionData dir isServer)
  (define currentX (fieldElement-xtiles explosion))
  (define currentY (fieldElement-ytiles explosion))

  (set-extraData-explosion-didSpread! explosionData #t)
  (cond
    [(equal? dir 'up)
      (explosionTickSpreadPosIfCan
        setGameFieldFn
        currentWorld
        elements
        players
        tickCount
        explosionData
        currentX
        (- currentY 1)
        dir
        isServer
      )
    ]
    [(equal? dir 'down)
      (explosionTickSpreadPosIfCan
        setGameFieldFn
        currentWorld
        elements
        players
        tickCount
        explosionData
        currentX
        (+ currentY 1)
        dir
        isServer
      )
    ]
    [(equal? dir 'left)
      (explosionTickSpreadPosIfCan
        setGameFieldFn
        currentWorld
        elements
        players
        tickCount
        explosionData
        (- currentX 1)
        currentY
        dir
        isServer
      )
    ]
    [(equal? dir 'right)
      (explosionTickSpreadPosIfCan
        setGameFieldFn
        currentWorld
        elements
        players
        tickCount
        explosionData
        (+ currentX 1)
        currentY
        dir
        isServer
      )
    ]
    [else
      (error 'INVALID_EXPLOSION_SPREAD_DIR)
    ]
  )
)

;; [explosionTickSpreadCore] Responsible for making the core spread in all 4 dirs by calling [explosionTickSpreadDir] 4 t imes
(define (explosionTickSpreadCore setGameFieldFn currentWorld elements players explosion tickCount explosionData isServer)
  (let* (
        [worldFieldA (explosionTickSpreadDir setGameFieldFn currentWorld elements players explosion tickCount explosionData 'up isServer)]
        [worldFieldB (explosionTickSpreadDir setGameFieldFn currentWorld elements players explosion tickCount explosionData 'down isServer)]
        [worldFieldC (explosionTickSpreadDir setGameFieldFn currentWorld elements players explosion tickCount explosionData 'left isServer)]
        [worldFieldD (explosionTickSpreadDir setGameFieldFn currentWorld elements players explosion tickCount explosionData 'right isServer)]
      )

    worldFieldD
  )
)

;; [explosionTickSpread] Calls the right function for spreading this type of explosion
(define (explosionTickSpread setGameFieldFn currentWorld elements players explosion tickCount explosionData isServer)
  (define spreadType (extraData-explosion-spreadType explosionData))

  (if (equal? spreadType 'core)
    (explosionTickSpreadCore
      setGameFieldFn
      currentWorld
      elements
      players
      explosion
      tickCount
      explosionData
      isServer
    )
    (explosionTickSpreadDir
      setGameFieldFn
      currentWorld
      elements
      players
      explosion
      tickCount
      explosionData
      spreadType
      isServer
    )
  )

)

;; [explosionTickSpreadIfShould] Checks whether the explosion should spread and if yes calls the fn to make it do so
(define (explosionTickSpreadIfShould setGameFieldFn currentWorld elements players explosion tickCount explosionData isServer)
  (if (or (extraData-explosion-didSpread explosionData) (= (extraData-explosion-spreadsLeft explosionData) 0))
    currentWorld
    (explosionTickSpread
      setGameFieldFn
      currentWorld
      elements
      players
      explosion
      tickCount
      explosionData
      isServer
    )
  )
)

;; [explosionTickVanishIfShould] Checks whether the explosion should vanish and if yes calls the fn to make it vanish
(define (explosionTickVanishIfShould setGameFieldFn currentWorld elements explosion explosionData)
  (if
    (>
      (current-inexact-milliseconds)
      (extraData-explosion-vanishWhen explosionData)
    )
    (removeFieldElement
      setGameFieldFn
      currentWorld
      elements
      explosion
    )
    currentWorld
  )
)

;; [explosionTick] Calls the functions to make the bomb spread if it should and vanish if it should
(define (explosionTick setGameFieldFn currentWorld elements players explosion tickCount explosionData isServer)
  (explosionTickSpreadIfShould
    setGameFieldFn
    (explosionTickVanishIfShould
      setGameFieldFn
      currentWorld
      elements
      explosion
      explosionData
    )
    elements
    players
    explosion
    tickCount
    explosionData
    isServer
  )
)
