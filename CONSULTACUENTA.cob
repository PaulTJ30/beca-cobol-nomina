      *----------------------------------------------------------
      * SIDN - DISPERSION DE NOMINA
      * CONSULTACUENTA (ONLINE): busca una cuenta por su numero en
      * el maestro CUENTAS (indexado) y muestra sus datos y saldo.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONSULTACUENTA.

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
       01  R-SALDO    PIC $$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT CUENTAS.
           PERFORM CONSULTAR UNTIL WS-SIGUE = "N".
           CLOSE CUENTAS.
           STOP RUN.

       CONSULTAR.
           MOVE ZEROS TO CTA-NUMERO.
           DISPLAY "NUMERO DE CUENTA A CONSULTAR:".
           ACCEPT CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S"
               DISPLAY "CUENTA NO ENCONTRADA."
           ELSE
               PERFORM MOSTRAR.
           DISPLAY "OTRA CONSULTA? (S/N):".
           ACCEPT WS-SIGUE.

       MOSTRAR.
           MOVE CTA-SALDO TO R-SALDO.
           DISPLAY "----------------------------------------".
           DISPLAY "CUENTA : " CTA-NUMERO.
           DISPLAY "TITULAR: " CTA-TITULAR.
           DISPLAY "EMPRESA: " CTA-EMPRESA.
           DISPLAY "SALDO  : " R-SALDO.
           DISPLAY "ESTADO : " CTA-ESTADO.
           DISPLAY "----------------------------------------".
