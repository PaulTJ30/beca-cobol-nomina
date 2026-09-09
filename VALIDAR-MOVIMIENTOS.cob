      *----------------------------------------------------------
      * BANCO AURORA - VALIDAR-MOVIMIENTOS (BATCH)
      * Lee el feed MOVIMIENTOS y separa los validos de los
      * rechazados. Valida: tipo D/R/T, monto > 0, cuenta existe,
      * y destino existe (para transferencias).
      * Salidas: VALIDOS.TXT (para los PROC) y LOG-RECHAZOS.TXT.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDARMOV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MOVS ASSIGN TO DISK "MOVIMIENTOS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.
           SELECT CUENTAS ASSIGN TO DISK "CUENTAS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CTA-NUMERO.
           SELECT VALIDOS ASSIGN TO DISK "VALIDOS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.
           SELECT LOGF ASSIGN TO DISK "LOG-RECHAZOS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  MOVS.
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
           05 CTA-RESTO    PIC X(64).

       FD  VALIDOS.
       01  REG-VAL         PIC X(54).

       FD  LOGF.
       01  REG-LOG.
           05 LOG-ID     PIC 9(12).
           05 FILLER     PIC X VALUE SPACE.
           05 LOG-CTA    PIC 9(10).
           05 FILLER     PIC X VALUE SPACE.
           05 LOG-CAUSA  PIC X(20).

       WORKING-STORAGE SECTION.
       01  WS-FIN     PIC X VALUE "N".
           88 FIN-MOV VALUE "S".
       01  WS-NOENC   PIC X VALUE "N".
       01  WS-CAUSA   PIC X(20).
       01  WS-LEIDOS  PIC 9(6) VALUE 0.
       01  WS-VAL     PIC 9(6) VALUE 0.
       01  WS-RECH    PIC 9(6) VALUE 0.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT MOVS.
           OPEN INPUT CUENTAS.
           OPEN OUTPUT VALIDOS.
           OPEN OUTPUT LOGF.
           READ MOVS AT END MOVE "S" TO WS-FIN.
           PERFORM PROCESAR UNTIL FIN-MOV.
           CLOSE MOVS.
           CLOSE CUENTAS.
           CLOSE VALIDOS.
           CLOSE LOGF.
           PERFORM ESTADISTICA.
           STOP RUN.

       PROCESAR.
           ADD 1 TO WS-LEIDOS.
           PERFORM VALIDA.
           IF WS-CAUSA = "OK"
               WRITE REG-VAL FROM REG-MOV
               ADD 1 TO WS-VAL
           ELSE
               PERFORM ESCRIBIR-LOG
               ADD 1 TO WS-RECH.
           READ MOVS AT END MOVE "S" TO WS-FIN.

       VALIDA.
           MOVE "OK" TO WS-CAUSA.
           IF MOV-TIPO NOT = "D" AND MOV-TIPO NOT = "R"
                   AND MOV-TIPO NOT = "T"
               MOVE "TIPO INVALIDO" TO WS-CAUSA.
           IF WS-CAUSA = "OK" AND MOV-MONTO NOT > 0
               MOVE "MONTO INVALIDO" TO WS-CAUSA.
           IF WS-CAUSA = "OK"
               PERFORM CHECA-CUENTA.
           IF WS-CAUSA = "OK" AND MOV-TIPO = "T"
               PERFORM CHECA-DESTINO.

       CHECA-CUENTA.
           MOVE MOV-CUENTA TO CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S" MOVE "CUENTA NO EXISTE" TO WS-CAUSA.

       CHECA-DESTINO.
           MOVE MOV-DESTINO TO CTA-NUMERO.
           MOVE "N" TO WS-NOENC.
           READ CUENTAS INVALID KEY MOVE "S" TO WS-NOENC.
           IF WS-NOENC = "S" MOVE "DESTINO NO EXISTE" TO WS-CAUSA.

       ESCRIBIR-LOG.
           MOVE MOV-ID     TO LOG-ID.
           MOVE MOV-CUENTA TO LOG-CTA.
           MOVE WS-CAUSA   TO LOG-CAUSA.
           WRITE REG-LOG.

       ESTADISTICA.
           DISPLAY "===== VALIDACION =====".
           DISPLAY "MOVIMIENTOS LEIDOS  : " WS-LEIDOS.
           DISPLAY "VALIDOS             : " WS-VAL.
           DISPLAY "RECHAZADOS (AL LOG) : " WS-RECH.
