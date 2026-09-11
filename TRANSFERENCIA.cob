      *----------------------------------------------------------
      * SIDN - TRANSFERENCIA (ONLINE)
      * Mueve un monto de una cuenta origen a una destino
      * (dispersion a terceros). Valida saldo y que ambas existan.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANSFERENCIA.

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
       01  WS-FS       PIC XX.
       01  WS-SIGUE    PIC X VALUE "S".
       01  WS-NOENC    PIC X VALUE "N".
       01  WS-OK       PIC X VALUE "S".
       01  WS-MONTO    PIC 9(9) VALUE 0.
       01  WS-ORIGEN   PIC 9(10) VALUE 0.
       01  WS-DESTINO  PIC 9(10) VALUE 0.
       01  R-SALDO     PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN I-O CUENTAS.
           PERFORM OPERAR UNTIL WS-SIGUE = "N".
           CLOSE CUENTAS.
           STOP RUN.

       OPERAR.
           DISPLAY "CUENTA ORIGEN:".
           ACCEPT WS-ORIGEN.
           DISPLAY "CUENTA DESTINO:".
           ACCEPT WS-DESTINO.
           DISPLAY "MONTO A TRANSFERIR:".
           ACCEPT WS-MONTO.
           MOVE "S" TO WS-OK.
           PERFORM LEER-ORIGEN.
           IF WS-OK = "S" PERFORM CHECA-SALDO.
           IF WS-OK = "S" PERFORM LEER-DESTINO.
           IF WS-OK = "S" PERFORM APLICAR.
           DISPLAY "OTRA TRANSFERENCIA? (S/N):".
           ACCEPT WS-SIGUE.

       LEER-ORIGEN.
           MOVE WS-ORIGEN TO CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S"
               DISPLAY "CUENTA ORIGEN NO EXISTE."
               MOVE "N" TO WS-OK.

       CHECA-SALDO.
           IF WS-MONTO > CTA-SALDO
               DISPLAY "SALDO INSUFICIENTE EN ORIGEN."
               MOVE "N" TO WS-OK.

       LEER-DESTINO.
           MOVE WS-DESTINO TO CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S"
               DISPLAY "CUENTA DESTINO NO EXISTE."
               MOVE "N" TO WS-OK.

       APLICAR.
           MOVE WS-ORIGEN TO CTA-NUMERO.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           SUBTRACT WS-MONTO FROM CTA-SALDO.
           REWRITE REG-CUENTA INVALID KEY DISPLAY "ERROR ORIGEN".
           MOVE WS-DESTINO TO CTA-NUMERO.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           ADD WS-MONTO TO CTA-SALDO.
           REWRITE REG-CUENTA INVALID KEY DISPLAY "ERROR DESTINO".
           MOVE CTA-SALDO TO R-SALDO.
           DISPLAY "TRANSFERENCIA APLICADA. SALDO DESTINO: " R-SALDO.
