#lang racket

;; imports
(require 2htdp/image)
(require lang/posn)
(require "cl_helper.rkt")
(require "cl_render_game.rkt")
(require "cl_render_titlescreen.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config_textures.rkt")

;; exports
(provide (all-defined-out))

;; [renderHandlerCond] Calls the fitting render function for our current state to render the game
(define (renderHandlerCond currentWorld)
  (define curState (clientsideWorld-curState currentWorld))
  (case curState
    [("titlescreen")  (renderTitlescreen currentWorld "HIT ENTER TO JOIN THE GAME" (* gameWidth 0.30)) ]
    [("loadingscreen")  (renderTitlescreen currentWorld "LOADING..." (* gameWidth 0.45))]
    [("ingame")  (renderGame currentWorld) ]
    [("gameover")  (renderTitlescreen currentWorld (generateWinnersText currentWorld) (* gameWidth 0.30)) ]
    [("resetscreen")  (renderTitlescreen currentWorld "PLAYERS LEFT, REBOOT GAME" (* gameWidth 0.30)) ]
    [else (text (string-append (clientsideWorld-curState currentWorld) "IS NOT A INVALID STATE!") 12 "red")]
  )
)



;; [renderHandlerRedraw] Calls the rendlerHanderCond since the frame needs to be redrawn
(define (rendlerHandlerRedraw currentWorld)
  (place-images/align
    (list
      (renderHandlerCond currentWorld)
    )
    (list
      (make-posn 0 0)
    )
    "left"
    "top"
    (empty-scene gameWidth gameHeight "black")
  )
)

;; [renderHandlerRedrawWithCache] Calls [rendlerHandlerRedraw] and caches the new frame
(define (renderHandlerRedrawWithCache currentWorld)
  (define newFrame (rendlerHandlerRedraw currentWorld))

  (and
    (set-clientsideWorld-renderCache!
      currentWorld
      (list
        newFrame
        (current-inexact-milliseconds)
      )
    )
    newFrame
  )
)

;; [rendlerHandlerShouldRedraw] Checks whether the frame should be redrawn to fit to 60FPS
(define (rendlerHandlerShouldRedraw lastRenderTime)
  (if lastRenderTime
    (>= (- (current-inexact-milliseconds) lastRenderTime) (/ 1 gameFPSRender))
    #t
  )
)

;; [renderHandler] Calls [renderHandlerRedrawWithCache] with a black canvas as background
(define (renderHandler currentWorld)
  (define curCache (clientsideWorld-renderCache currentWorld))

  (if (rendlerHandlerShouldRedraw (clientsideWorld-renderLastTime currentWorld))
    (renderHandlerRedrawWithCache currentWorld)
    curCache
  )

)

