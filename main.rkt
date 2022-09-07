#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt" (submod "asm.rkt" reader))

(module+ main
  (require racket/cmdline)
  (let ((filename
         (command-line
          #:program "hackasm" ; FIXME: get name from project
          #:args (filename)
          filename)))
    (parameterize ([current-namespace (make-base-empty-namespace)])
      (eval (read-syntax filename (open-input-file filename)))
      (dynamic-require '(quote hackasm-mod) #f))))