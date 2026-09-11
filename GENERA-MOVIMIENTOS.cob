      *----------------------------------------------------------
      * SIDN - GENERA-MOVIMIENTOS
      * Genera el archivo MOVIMIENTOS (feed batch de la dispersion)
      * con N registros. Cicla 8 cuentas (101-108) y tipos D/R/T con
      * montos variados (sueldos), e inyecta cuentas invalidas (9999)
      * cada 10 para probar el LOG.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GENERAMOV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MOVS ASSIGN TO DISK "MOVIMIENTOS.TXT"
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

       WORKING-STORAGE SECTION.
       01  WS-N    PIC 9(6) VALUE 0.
       01  WS-I    PIC 9(6) VALUE 0.
       01  WS-Q    PIC 9(6) VALUE 0.
       01  WS-R8   PIC 9(2) VALUE 0.
       01  WS-R7   PIC 9(2) VALUE 0.
       01  WS-R3   PIC 9(2) VALUE 0.
       01  WS-R10  PIC 9(2) VALUE 0.
       01  WS-IDX  PIC 9(2) VALUE 0.
       01  WS-SUELDOS.
           05 FILLER PIC 9(6) VALUE 006500.
           05 FILLER PIC 9(6) VALUE 008200.
           05 FILLER PIC 9(6) VALUE 012000.
           05 FILLER PIC 9(6) VALUE 009750.
           05 FILLER PIC 9(6) VALUE 015300.
           05 FILLER PIC 9(6) VALUE 007100.
           05 FILLER PIC 9(6) VALUE 010500.
           05 FILLER PIC 9(6) VALUE 005400.
       01  WS-TABLA REDEFINES WS-SUELDOS.
           05 WS-SUELDO PIC 9(6) OCCURS 8.

       PROCEDURE DIVISION.
       PRINCIPAL.
           DISPLAY "CUANTOS MOVIMIENTOS GENERAR:".
           ACCEPT WS-N.
           OPEN OUTPUT MOVS.
           PERFORM UNO VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N.
           CLOSE MOVS.
           DISPLAY "MOVIMIENTOS GENERADOS: " WS-N.
           STOP RUN.

       UNO.
           MOVE SPACES TO REG-MOV.
           MOVE WS-I TO MOV-ID.
           DIVIDE WS-I BY 8 GIVING WS-Q REMAINDER WS-R8.
           COMPUTE MOV-CUENTA = 101 + WS-R8.
           DIVIDE WS-I BY 3 GIVING WS-Q REMAINDER WS-R3.
           IF WS-R3 = 0 MOVE "D" TO MOV-TIPO.
           IF WS-R3 = 1 MOVE "R" TO MOV-TIPO.
           IF WS-R3 = 2 MOVE "T" TO MOV-TIPO.
           COMPUTE WS-IDX = WS-R8 + 1.
           IF MOV-TIPO = "D"
               MOVE WS-SUELDO(WS-IDX) TO MOV-MONTO.
           IF MOV-TIPO = "R"
               MOVE 1200 TO MOV-MONTO.
           IF MOV-TIPO = "T"
               MOVE 2000 TO MOV-MONTO.
           MOVE 0 TO MOV-DESTINO.
           IF MOV-TIPO = "T"
               DIVIDE WS-I BY 7 GIVING WS-Q REMAINDER WS-R7
               COMPUTE MOV-DESTINO = 101 + WS-R7.
           MOVE "2026-09-08" TO MOV-FECHA.
           DIVIDE WS-I BY 10 GIVING WS-Q REMAINDER WS-R10.
           IF WS-R10 = 0 MOVE 9999 TO MOV-CUENTA.
           WRITE REG-MOV.
