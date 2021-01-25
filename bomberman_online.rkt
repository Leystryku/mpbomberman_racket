#lang racket

; import
(require racket/gui)
(require 2htdp/universe)
(require "bomberman_client.rkt")
(require "game/cl_sound.rkt")



(define ip-adress (void))
(define port-number (void))
(define user-name (void))


;; [run-online] starts the game, connect to the server and stops sound execution when closing
(define (run-online player-number ip-adress port-number)
    (and
     (create-world-withipandport player-number ip-adress port-number)
     (stop-our-sound)
    )
  )



;; defines the window-container which popups when the client wants to connect with a server
(define toplevel
  (new frame%
    [label "Verbindung mit Server"]
    [width 250]
    [height 200]
    [style '(no-resize-border)]
    [spacing 10]
    [border 30]
  )
)

;; Textfields for ip-adress and port placed in the container
(define user-name-text
  (new text-field%
    [label "Spielernummer [1-4]   "]
    [horiz-margin 40]
    [parent toplevel]
  )
)

(define ip-text
  (new text-field%
    [label "IP-Adresse                     "]
    [horiz-margin 40]
    [parent toplevel]
  )
)

(define port-text
  (new text-field%
    [label "Port-Nummer              "]
    [horiz-margin 40]
    [parent toplevel]
  )
)


;; event-handler-function when submitting by clicking the button
(define (button-callback button event)
  (define user (send user-name-text get-value))
  (define ip (send ip-text get-value))
  (define port (string->number (send port-text get-value)))

  (send user-name-text set-value "")
  (send ip-text set-value "")
  (send port-text set-value "")
  (send toplevel show #f) ; hide the window when game starts
  (run-online user ip port) ; starts
)

;; The button for submitting the input in the textfields
(new button%
     [label "Verbinden"]
     [parent toplevel]
     [callback button-callback]
)

;; The function that's called for opening the server connect window
(define (server-connect-window)
  (send toplevel show #t)
)


(server-connect-window)