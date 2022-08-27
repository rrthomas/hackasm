#lang br/quicklang
(define (format-word w)
  (~r w #:base 2 #:min-width 16 #:pad-string "0"))

(define (a-instr ARG)
  (displayln (format-word ARG)))

(define (c-instr . ARGS)
  (displayln (format-word (apply + (arithmetic-shift 7 13) ARGS))))

(define (dest inst)
  (define opcodes
    (hash "M" 1 "D" 2 "DM" 3 "A" 4 "AM" 5 "AD" 6 "ADM" 7))
  (arithmetic-shift (hash-ref opcodes inst) 3))

(define (comp inst)
  (define opcodes
    (hash "0" 42 "1" 63 "-1" 58 "D" 12 "A" 48 "M" 112
          "!D" 13 "!A" 49 "!M" 113 "-D" 15 "-A" 51 "-M" 115
          "D+1" 31 "A+1" 55 "M+1" 119 "D-1" 14 "A-1" 50 "M-1" 114
          "D+A" 2 "D+M" 66 "D-A" 19 "D-M" 83 "A-D" 7 "M-D" 71
          "D&A" 0 "D&M" 64 "D|A" 21 "D|M" 85))
  (arithmetic-shift (hash-ref opcodes inst) 6))

(define (jump inst)
  (define opcodes
    (hash "JGT" 1 "JEQ" 2 "JGE" 3 "JLT" 4 "JNE" 5 "JLE" 6 "JMP" 7))
  (hash-ref opcodes inst))

(provide a-instr c-instr dest comp jump)

(define-macro (hack-module-begin (hack-program INSTR ...))
  #'(#%module-begin
     INSTR ...))
(provide (rename-out [hack-module-begin #%module-begin]))