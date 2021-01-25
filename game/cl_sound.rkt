#lang racket

;; imports
(require (only-in racket/gui/base play-sound))
(require ffi/unsafe)
(require "sh_config.rkt")
(require "sh_config_snds.rkt")

;; exports
(provide (all-defined-out))


;; [sound-fn] calls the proper sound functions for the OS using rackets foreign function interface
(define (sound-fn str)
  (cond
    [(equal? soundEnabled 1)
      (lambda (x) (define mci-send-string
        (get-ffi-obj "mciSendStringA" "Winmm"
          (_fun _string [_pointer = #f] [_int = 0] [_pointer = #f]
            -> [ret : _int]))
          )
      (mci-send-string str))(str)
    ]
    [(equal? soundEnabled 2)
      (lambda (x) (define mci-send-string
        (get-ffi-obj "mciSendStringA" "Winmm"
          (_fun _string [_pointer = #f] [_int = 0] [_pointer = #f]
            -> [ret : _int]))
          )
        (mci-send-string str))(str)
    ]
    [else str]
  )
)

;; [windows-play-sound] is a wrapper around sound-fn for playing sounds using the windows sound cmd
(define (windows-play-sound snd)
  (if soundEnabled
    (sound-fn (string-append (string-append "play " snd)))
    (windows-stop-sound snd)
  )
)

;; [windows-stop-sound] is a wrapper around sound-fn for stopping sounds using the windows sound cmd
(define (windows-stop-sound snd)
  (sound-fn (string-append (string-append "stop " snd)))
)

;; [play-our-sound] is a wrapper around the play sound functions for the os's
(define (play-our-sound snd)
  (cond
    [(equal? soundEnabled 1) (windows-play-sound snd)]
    [(equal? soundEnabled -1) (play-sound snd #t)]
    [else snd]
  )
)

;; [stop-our-sound] is a wrapper around the sound stop functions for the os's
(define (stop-our-sound)
  (cond
    [(equal? soundEnabled 1) (windows-stop-sound)]
    [else #t]
  )
)