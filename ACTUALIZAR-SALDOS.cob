      *----------------------------------------------------------
      * BANCO AURORA - ACTUALIZAR-SALDOS (BATCH)
      * Aplica los movimientos consolidados al maestro CUENTAS.
      * D = abona; R = debita; T = debita origen y abona destino.
      * IDEMPOTENCIA: lleva un indexado PROCESADOS por id de
      * movimiento; si un id ya se aplico, lo omite. Asi el restart
      * puede reanudar sin aplicar dos veces.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACTUALIZASALDOS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MOVAP ASSIGN TO DISK "MOVAPLICAR.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CUENTAS ASSIGN TO DISK "CUENTAS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CTA-NUMERO
               FILE STATUS IS WS-FSC.
           SELECT PROCS ASSIGN TO DISK "PROCESADOS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS P-ID
               FILE STATUS IS WS-FSP.

       DATA DIVISION.
       FILE SECTION.
       FD  MOVAP.
       01  REG-MOV.
           05 MOV-ID       PIC 9(12).
           05 MOV-CUENTA   PIC 9(10).
           05 MOV-TIPO     PIC X.
           05 MOV-MONTO    PIC 9(9)V99.
           05 MOV-DESTINO  PIC 9(10).
           05 MOV-FECHA    PIC X(10).

       FD  CUENTAS.
       01  REG-CUENTA.
           05 CTA-NUMERO   PIC 9(10).
           05 CTA-TITULAR  PIC X(30).
           05 CTA-EMPRESA  PIC X(20).
           05 CTA-SALDO    PIC S9(11)V99.
           05 CTA-ESTADO   PIC X.

       FD  PROCS.
       01  REG-PROC.
           05 P-ID     PIC 9(12).
           05 FILLER   PIC X(10).

       WORKING-STORAGE SECTION.
       01  WS-FSC      PIC XX.
       01  WS-FSP      PIC XX.
       01  WS-FIN      PIC X VALUE "N".
           88 FIN      VALUE "S".
       01  WS-NOENC    PIC X VALUE "N".
       01  WS-YAESTA   PIC X VALUE "N".
       01  WS-LEIDOS   PIC 9(8) VALUE 0.
       01  WS-APLIC    PIC 9(8) VALUE 0.
       01  WS-OMIT     PIC 9(8) VALUE 0.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT MOVAP.
           OPEN I-O CUENTAS.
           OPEN I-O PROCS.
           IF WS-FSP = "35"
               OPEN OUTPUT PROCS
               CLOSE PROCS
               OPEN I-O PROCS.
           READ MOVAP AT END MOVE "S" TO WS-FIN.
           PERFORM APLICA-UNO UNTIL FIN.
           CLOSE MOVAP.
           CLOSE CUENTAS.
           CLOSE PROCS.
           PERFORM ESTADISTICA.
           STOP RUN.

       APLICA-UNO.
           ADD 1 TO WS-LEIDOS.
           MOVE MOV-ID TO P-ID.
           MOVE "S" TO WS-YAESTA.
           READ PROCS INVALID KEY MOVE "N" TO WS-YAESTA.
           IF WS-YAESTA = "N"
               PERFORM APLICAR-MOV
               ADD 1 TO WS-APLIC
               MOVE SPACES TO REG-PROC
               MOVE MOV-ID TO P-ID
               WRITE REG-PROC INVALID KEY DISPLAY "DUP PROC"
           ELSE
               ADD 1 TO WS-OMIT.
           READ MOVAP AT END MOVE "S" TO WS-FIN.

       APLICAR-MOV.
           IF MOV-TIPO = "D"
               PERFORM ABONA-ORIGEN.
           IF MOV-TIPO = "R"
               PERFORM DEBITA-ORIGEN.
           IF MOV-TIPO = "T"
               PERFORM DEBITA-ORIGEN
               PERFORM ABONA-DESTINO.

       ABONA-ORIGEN.
           MOVE MOV-CUENTA TO CTA-NUMERO.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           ADD MOV-MONTO TO CTA-SALDO.
           REWRITE REG-CUENTA INVALID KEY DISPLAY "ERR CTA".

       DEBITA-ORIGEN.
           MOVE MOV-CUENTA TO CTA-NUMERO.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           SUBTRACT MOV-MONTO FROM CTA-SALDO.
           REWRITE REG-CUENTA INVALID KEY DISPLAY "ERR CTA".

       ABONA-DESTINO.
           MOVE MOV-DESTINO TO CTA-NUMERO.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           ADD MOV-MONTO TO CTA-SALDO.
           REWRITE REG-CUENTA INVALID KEY DISPLAY "ERR DEST".

       ESTADISTICA.
           DISPLAY "===== ACTUALIZAR-SALDOS =====".
           DISPLAY "MOVIMIENTOS LEIDOS   : " WS-LEIDOS.
           DISPLAY "APLICADOS            : " WS-APLIC.
           DISPLAY "OMITIDOS (DUPLICADOS): " WS-OMIT.
