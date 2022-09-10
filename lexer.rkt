#lang br
(require brag/support)

; Use tests from https://beautifulracket.com/basic/the-lexer.html

(define-lex-abbrev reserved-terms
  (:or "@" "=" ";" "(" ")"
       "0" "1" "-1" "D" "A" "M" "!D" "!A" "-D" "-A"
       "D+1" "A+1" "D-1" "A-1" "D+A" "D-A" "A-D"
       "D&A" "D|A" "M" "!M" "-M" "M+1" "M-1"
       "D+M" "D-M" "M-D" "D&M" "D|M"
       "JGT" "JEQ" "JGE" "JLT" "JNE" "JLE" "JMP"
       "AD" "AM" "DA" "DM" "MA" "MD"
       "ADM" "AMD" "DAM" "DMA" "MAD" "MDA"
    ))

(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev id (:: alphabetic (:* (:or numeric alphabetic "_" "." "$"))))

(define asm-lexer
  (lexer-srcloc
   ["\n" (token 'NEWLINE lexeme)]
   [whitespace (token lexeme #:skip? #t)]
   [(from/stop-before "//" "\n") (token lexeme #:skip? #t)]
   [reserved-terms (token lexeme lexeme)]
   [digits (token 'INTEGER (string->number lexeme))]
   [id (token 'ID lexeme)]))

(provide asm-lexer)