      *----------------------------------------------------------
      * SIDN - RETIRO (ONLINE)
      * Debita un monto de la cuenta (equivale a una deduccion).
      * Valida que el saldo alcance: no deja saldo negativo.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETIRO.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUENTAS ASSIGN TO DISK "CUENTAS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CTA-NUMERO
               FILE STATUS IS WS-FS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUENTAS.
       01  REG-CUENTA.
           05 CTA-NUMERO   PIC 9(10).
           05 CTA-TITULAR  PIC X(30).
           05 CTA-EMPRESA  PIC X(20).
           05 CTA-SALDO    PIC S9(11)V99.
           05 CTA-ESTADO   PIC X.

       WORKING-STORAGE SECTION.
       01  WS-FS      PIC XX.
       01  WS-SIGUE   PIC X VALUE "S".
       01  WS-NOENC   PIC X VALUE "N".
       01  WS-MONTO   PIC 9(9) VALUE 0.
       01  R-SALDO    PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN I-O CUENTAS.
           PERFORM OPERAR UNTIL WS-SIGUE = "N".
           CLOSE CUENTAS.
           STOP RUN.

       OPERAR.
           MOVE ZEROS TO CTA-NUMERO.
           DISPLAY "NUMERO DE CUENTA:".
           ACCEPT CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S"
               DISPLAY "CUENTA NO ENCONTRADA."
           ELSE
               PERFORM DEBITAR.
           DISPLAY "OTRO RETIRO? (S/N):".
           ACCEPT WS-SIGUE.

       DEBITAR.
           DISPLAY "MONTO A RETIRAR:".
           ACCEPT WS-MONTO.
           IF WS-MONTO > CTA-SALDO
               DISPLAY "SALDO INSUFICIENTE."
           ELSE
               SUBTRACT WS-MONTO FROM CTA-SALDO
               REWRITE REG-CUENTA INVALID KEY DISPLAY "ERROR AL GRABAR"
               MOVE CTA-SALDO TO R-SALDO
               DISPLAY "RETIRO APLICADO. NUEVO SALDO: " R-SALDO.
