      *----------------------------------------------------------
      * BANCO AURORA - CONSOLIDAR (BATCH)
      * Junta los tres archivos de los PROC (APLICA-D/R/T) en un
      * solo MOVAPLICAR y calcula los totales de control (numero de
      * movimientos y suma de montos) en CONTROL.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONSOLIDAR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ED  ASSIGN TO DISK "APLICA-D.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ER  ASSIGN TO DISK "APLICA-R.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ET  ASSIGN TO DISK "APLICA-T.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SAL ASSIGN TO DISK "MOVAPLICAR.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CTRL ASSIGN TO DISK "CONTROL.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ED.
       01  REG-D   PIC X(54).
       FD  ER.
       01  RR   PIC X(54).
       FD  ET.
       01  RT   PIC X(54).
       FD  SAL.
       01  RS   PIC X(54).
       FD  CTRL.
       01  REG-CTRL.
           05 C-TOT-CNT    PIC 9(8).
           05 C-TOT-MONTO  PIC 9(13)V99.

       WORKING-STORAGE SECTION.
       01  WS-FIN   PIC X VALUE "N".
           88 FIN   VALUE "S".
       01  WS-CNT   PIC 9(8) VALUE 0.
       01  WS-MONTO PIC 9(13)V99 VALUE 0.
       01  WS-MOV.
           05 W-ID       PIC 9(12).
           05 W-CUENTA   PIC 9(10).
           05 W-TIPO     PIC X.
           05 W-MONTO    PIC 9(9)V99.
           05 W-DESTINO  PIC 9(10).
           05 W-FECHA    PIC X(10).

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT ED.
           OPEN INPUT ER.
           OPEN INPUT ET.
           OPEN OUTPUT SAL.
           PERFORM COPIA-D.
           PERFORM COPIA-R.
           PERFORM COPIA-T.
           CLOSE ED.
           CLOSE ER.
           CLOSE ET.
           CLOSE SAL.
           OPEN OUTPUT CTRL.
           MOVE WS-CNT   TO C-TOT-CNT.
           MOVE WS-MONTO TO C-TOT-MONTO.
           WRITE REG-CTRL.
           CLOSE CTRL.
           DISPLAY "CONSOLIDAR - MOVIMIENTOS: " WS-CNT.
           DISPLAY "CONSOLIDAR - SUMA MONTOS: " WS-MONTO.
           STOP RUN.

       COPIA-D.
           MOVE "N" TO WS-FIN.
           READ ED INTO WS-MOV AT END MOVE "S" TO WS-FIN.
           PERFORM UNO-D UNTIL FIN.

       UNO-D.
           WRITE RS FROM WS-MOV.
           ADD W-MONTO TO WS-MONTO.
           ADD 1 TO WS-CNT.
           READ ED INTO WS-MOV AT END MOVE "S" TO WS-FIN.

       COPIA-R.
           MOVE "N" TO WS-FIN.
           READ ER INTO WS-MOV AT END MOVE "S" TO WS-FIN.
           PERFORM UNO-R UNTIL FIN.

       UNO-R.
           WRITE RS FROM WS-MOV.
           ADD W-MONTO TO WS-MONTO.
           ADD 1 TO WS-CNT.
           READ ER INTO WS-MOV AT END MOVE "S" TO WS-FIN.

       COPIA-T.
           MOVE "N" TO WS-FIN.
           READ ET INTO WS-MOV AT END MOVE "S" TO WS-FIN.
           PERFORM UNO-T UNTIL FIN.

       UNO-T.
           WRITE RS FROM WS-MOV.
           ADD W-MONTO TO WS-MONTO.
           ADD 1 TO WS-CNT.
           READ ET INTO WS-MOV AT END MOVE "S" TO WS-FIN.
