      *----------------------------------------------------------
      * BANCO AURORA - PROC-DEPOSITOS (BATCH)
      * Toma los movimientos VALIDOS y separa los de tipo D
      * (abono de nomina) hacia APLICA-D. Corre en paralelo con
      * PROC-RETIROS y PROC-TRANSFERENCIAS.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROCDEP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT VALIDOS ASSIGN TO DISK "VALIDOS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SALIDA ASSIGN TO DISK "APLICA-D.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  VALIDOS.
       01  REG-MOV.
           05 MOV-ID       PIC 9(12).
           05 MOV-CUENTA   PIC 9(10).
           05 MOV-TIPO     PIC X.
           05 MOV-MONTO    PIC 9(9)V99.
           05 MOV-DESTINO  PIC 9(10).
           05 MOV-FECHA    PIC X(10).
       FD  SALIDA.
       01  REG-OUT         PIC X(54).

       WORKING-STORAGE SECTION.
       01  WS-FIN   PIC X VALUE "N".
           88 FIN   VALUE "S".
       01  WS-CNT   PIC 9(6) VALUE 0.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT VALIDOS.
           OPEN OUTPUT SALIDA.
           READ VALIDOS AT END MOVE "S" TO WS-FIN.
           PERFORM UNO UNTIL FIN.
           CLOSE VALIDOS.
           CLOSE SALIDA.
           DISPLAY "PROC-DEPOSITOS - DEPOSITOS: " WS-CNT.
           STOP RUN.

       UNO.
           IF MOV-TIPO = "D"
               WRITE REG-OUT FROM REG-MOV
               ADD 1 TO WS-CNT.
           READ VALIDOS AT END MOVE "S" TO WS-FIN.
