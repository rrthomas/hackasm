#lang racket
(require parser-tools/lex (prefix-in : parser-tools/lex-sre))

; Use tests from https://beautifulracket.com/basic/the-lexer.html

(define-lex-abbrev comp
  (:or "-1" "!D" "!A" "-D" "-A"
       "D+1" "A+1" "D-1" "A-1" "D+A" "D-A" "A-D"
       "D&A" "D|A" "M" "!M" "-M" "M+1" "M-1"
       "D+M" "D-M" "M-D" "D&M" "D|M"
       ))

(define-lex-abbrev jump
  (:or "JGT" "JEQ" "JGE" "JLT" "JNE" "JLE" "JMP"))

(define-lex-abbrev dest
  (:or "AD" "AM" "DA" "DM" "MA" "MD"
       "ADM" "AMD" "DAM" "DMA" "MAD" "MDA"
       ))

(define-lex-abbrev register (char-set "ADM"))
(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev id (:: alphabetic (:* (:or numeric alphabetic "_" "." "$"))))
(define-lex-abbrev comment (:: "//" (:* (char-complement "\n"))))

(define-tokens basic-tokens (INTEGER ID ZEROONE REGISTER DEST COMP JUMP))
(define-empty-tokens punct-tokens (NEWLINE EOF AT EQ SEMICOLON LPAREN RPAREN))

(define asm-lexer
  (lexer-src-pos
   [(eof) (token-EOF)]
   ["\n" (token-NEWLINE)]
   [whitespace (return-without-pos (asm-lexer input-port))]
   [comment (return-without-pos (asm-lexer input-port))]
   ["@" (token-AT)]
   ["=" (token-EQ)]
   [";" (token-SEMICOLON)]
   ["(" (token-LPAREN)]
   [")" (token-RPAREN)]
   [(char-set "01") (token-ZEROONE lexeme)]
   [register (token-REGISTER lexeme)]
   [dest (token-DEST lexeme)]
   [comp (token-COMP lexeme)]
   [jump (token-JUMP lexeme)]
   [digits (token-INTEGER (string->number lexeme))]
   [id (token-ID lexeme)]))

(provide asm-lexer basic-tokens punct-tokens)