#lang racket

;; imports
(require 2htdp/image)
(require lang/posn)
(require "cl_helper.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config_textures.rkt")

;; exports
(provide (all-defined-out))


;; [getCurTitlescreenTxt] Returns the current texture for the titlescreen
(define (getCurTitlescreenTxt tickcount div mod)
  (if (> div (modulo tickcount mod))
    txtTitlescreen1
    txtTitlescreen2
  )
)


;; [renderTitlescreen] Renders the titlescreen
(define (renderTitlescreen currentWorld curtxt textx)
  (place-images/align
    (list
      (text curtxt 24 "white")
    )
    (list
      (make-posn
        textx
        (interpTwo
          (* gameHeight 0.65)
          (* gameHeight 0.79)
          (/ (modulo (clientsideWorld-tickCount currentWorld) 100 ) 50)
        )
      )
    )
    "left" "top"
    (getCurTitlescreenTxt (clientsideWorld-tickCount currentWorld) 20 40)
  )
)