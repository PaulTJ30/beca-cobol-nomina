      *----------------------------------------------------------
      * BANCO AURORA - GENERAR-REPORTES (BATCH)
      * Recorre el maestro CUENTAS (en orden de cuenta) y escribe
      * un reporte estructurado con el saldo de cada cuenta, mas
      * los totales de control que dejo CONSOLIDAR.
      *----------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GENERAREPORTES.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUENTAS ASSIGN TO DISK "CUENTAS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS CTA-NUMERO.
           SELECT CTRL ASSIGN TO DISK "CONTROL.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REP ASSIGN TO DISK "REPORTE.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CUENTAS.
       01  REG-CUENTA.
           05 CTA-NUMERO   PIC 9(10).
           05 CTA-TITULAR  PIC X(30).
           05 CTA-EMPRESA  PIC X(20).
           05 CTA-SALDO    PIC S9(11)V99.
           05 CTA-ESTADO   PIC X.
       FD  CTRL.
       01  REG-CTRL.
           05 C-TOT-CNT    PIC 9(8).
           05 C-TOT-MONTO  PIC 9(13)V99.
       FD  REP.
       01  REP-REG         PIC X(90).

       WORKING-STORAGE SECTION.
       01  WS-FIN   PIC X VALUE "N".
           88 FIN   VALUE "S".
       01  R-SALDO  PIC $$$,$$$,$$9.99.
       01  R-MONTO  PIC $$,$$$,$$$,$$9.99.
       01  R-CNT    PIC ZZZZZZZ9.

       01  LINEA-REP.
           05 L-NUM     PIC 9(10).
           05 FILLER    PIC X.
           05 L-TITULAR PIC X(30).
           05 FILLER    PIC X.
           05 L-EMPRESA PIC X(20).
           05 FILLER    PIC X.
           05 L-SALDO   PIC $$$,$$$,$$9.99.

       01  ENC-LINEA.
           05 FILLER PIC X(11) VALUE "CUENTA".
           05 FILLER PIC X(31) VALUE "TITULAR".
           05 FILLER PIC X(21) VALUE "EMPRESA".
           05 FILLER PIC X(14) VALUE "SALDO".

       01  ENC-RAYA.
           05 FILLER PIC X(76) VALUE ALL "-".

       01  LINEA-TIT.
           05 FILLER PIC X(50).

       01  LINEA-TOT.
           05 FILLER   PIC X(28) VALUE "MOVIMIENTOS APLICADOS: ".
           05 T-CNT    PIC ZZZZZZZ9.
           05 FILLER   PIC X(8)  VALUE "   SUMA:".
           05 T-MONTO  PIC $$,$$$,$$$,$$9.99.

       PROCEDURE DIVISION.
       PRINCIPAL.
           OPEN INPUT CUENTAS.
           OPEN INPUT CTRL.
           OPEN OUTPUT REP.
           MOVE ZEROS TO C-TOT-CNT.
           MOVE ZEROS TO C-TOT-MONTO.
           READ CTRL AT END MOVE "S" TO WS-FIN.
           MOVE "N" TO WS-FIN.
           MOVE SPACES TO LINEA-TIT.
           MOVE "REPORTE DISPERSION DE NOMINA - BANCO AURORA"
               TO LINEA-TIT.
           WRITE REP-REG FROM LINEA-TIT.
           WRITE REP-REG FROM ENC-LINEA.
           WRITE REP-REG FROM ENC-RAYA.
           READ CUENTAS AT END MOVE "S" TO WS-FIN.
           PERFORM UNA-CUENTA UNTIL FIN.
           WRITE REP-REG FROM ENC-RAYA.
           MOVE C-TOT-CNT   TO T-CNT.
           MOVE C-TOT-MONTO TO T-MONTO.
           WRITE REP-REG FROM LINEA-TOT.
           CLOSE CUENTAS.
           CLOSE CTRL.
           CLOSE REP.
           DISPLAY "REPORTE GENERADO EN REPORTE.TXT".
           STOP RUN.

       UNA-CUENTA.
           MOVE SPACES TO LINEA-REP.
           MOVE CTA-NUMERO  TO L-NUM.
           MOVE CTA-TITULAR TO L-TITULAR.
           MOVE CTA-EMPRESA TO L-EMPRESA.
           MOVE CTA-SALDO   TO L-SALDO.
           WRITE REP-REG FROM LINEA-REP.
           READ CUENTAS AT END MOVE "S" TO WS-FIN.
