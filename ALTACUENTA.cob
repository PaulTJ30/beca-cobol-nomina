      *----------------------------------------------------------
      * BANCO AURORA - DISPERSION DE NOMINA
      * ALTACUENTA (ONLINE): da de alta cuentas de empleados en el
      * archivo maestro CUENTAS (indexado por numero de cuenta).
      * El saldo inicial es 0; la nomina se abona despues por batch.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ALTACUENTA.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUENTAS ASSIGN TO DISK "CUENTAS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
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
       01  WS-FS     PIC XX.
       01  WS-SIGUE  PIC X VALUE "S".

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN I-O CUENTAS.
           IF WS-FS = "35"
               OPEN OUTPUT CUENTAS
               CLOSE CUENTAS
               OPEN I-O CUENTAS.
           PERFORM CAPTURAR UNTIL WS-SIGUE = "N".
           CLOSE CUENTAS.
           DISPLAY "ALTA DE CUENTAS TERMINADA.".
           STOP RUN.

       CAPTURAR.
           MOVE SPACES TO REG-CUENTA.
           MOVE ZEROS TO CTA-NUMERO.
           MOVE 0 TO CTA-SALDO.
           MOVE "A" TO CTA-ESTADO.
           DISPLAY "NUMERO DE CUENTA (10 DIGITOS):".
           ACCEPT CTA-NUMERO.
           DISPLAY "TITULAR (EMPLEADO):".
           ACCEPT CTA-TITULAR.
           DISPLAY "EMPRESA:".
           ACCEPT CTA-EMPRESA.
           WRITE REG-CUENTA
               INVALID KEY DISPLAY "LA CUENTA YA EXISTE: " CTA-NUMERO.
           DISPLAY "OTRA CUENTA? (S/N):".
           ACCEPT WS-SIGUE.
