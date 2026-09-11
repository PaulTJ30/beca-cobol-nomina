# Diseno tecnico
## Sistema de Dispersion de Nomina (SIDN)

## 1. Caso de negocio
La institucion ofrece a las empresas el servicio de dispersar la nomina de sus empleados.
Cada quincena, las empresas entregan un archivo con los movimientos del periodo y el banco
los procesa de forma masiva (miles de movimientos) para dejar el dinero en la cuenta de
cada empleado.

Tres tipos de movimiento:
- Deposito (D): abono de nomina a la cuenta del empleado. Es el flujo dominante.
- Retiro (R): deducciones del periodo (prestamos, impuestos, descuentos).
- Transferencia (T): dispersion de una parte del sueldo a otra cuenta.

Por que exige alto volumen, restart e idempotencia: si el proceso nocturno falla a la
mitad, debe poder reanudarse sin pagar dos veces ni dejar a un empleado sin su pago.

## 2. Arquitectura MCP (marco de referencia)
El proyecto se disena sobre la arquitectura Unisys ClearPath MCP y se implementa en
OpenCOBOL. Equivalencias:

| Pieza MCP | Rol | En este proyecto |
|-----------|-----|------------------|
| COBOL | Logica de negocio | Los 12 programas |
| WFL | Orquesta los JOBS batch | JOB de dispersion + orquestador.ps1 (demo) |
| MCP | Administra procesos, memoria, I/O | Sistema operativo (documentado) |
| DMSII | Persistencia estructurada | Archivos indexados/secuenciales |
| CANDE | Entorno del programador | OpenCobolIDE / OpenCOBOL |

Regla mnemotecnica: COBOL = que hace; WFL = cuando y en que orden; MCP = como se
administra; DMSII = donde se guardan los datos.

## 3. Flujo online (durante el dia)
Operaciones interactivas sobre el maestro CUENTAS:
```
   USUARIO (caja / app)
        |
        v
   PROGRAMA COBOL ONLINE
        |-- ALTACUENTA      -> da de alta la cuenta del empleado
        |-- CONSULTACUENTA  -> consulta datos y saldo por numero
        |-- DEPOSITO        -> abona a la cuenta
        |-- RETIRO          -> debita (valida que no quede en negativo)
        |-- TRANSFERENCIA   -> debita origen y abona destino
        v
   Actualiza CUENTAS (REWRITE) y registra un MOVIMIENTO
```

## 4. Flujo batch (dispersion de la quincena)
Proceso masivo orquestado por el JOB WFL:
```
                      MOVIMIENTOS (entrada, miles de registros)
                                    |
                                    v
                          VALIDAR-MOVIMIENTOS
                          (validos / rechazados -> LOG)
                                    |
             +----------------------+----------------------+
             v                      v                      v
      PROC-DEPOSITOS        PROC-RETIROS         PROC-TRANSFERENCIAS
             |                      |                      |
             +----------------------+----------------------+
                                    v
                               CONSOLIDAR
                                    |
                                    v
                            ACTUALIZAR-SALDOS  (aplica al maestro CUENTAS)
                                    |
                                    v
                            GENERAR-REPORTES
```

## 5. Archivos
| Archivo | Organizacion | Uso |
|---------|--------------|-----|
| CUENTAS | Indexado (llave: numero de cuenta) | Maestro de cuentas y saldos |
| MOVIMIENTOS | Secuencial | Entrada batch de la quincena |
| VALIDOS | Secuencial | Movimientos que pasaron validacion |
| LOG-RECHAZOS | Secuencial | Movimientos rechazados y su causa |
| CHECKPOINT | Secuencial | Ultima fase completada (restart) |
| REPORTE | Secuencial | Reporte estructurado de la dispersion |

### Registro CUENTAS (74 bytes)
```
CTA-NUMERO   9(10)     llave
CTA-TITULAR  X(30)     empleado
CTA-EMPRESA  X(20)
CTA-SALDO    S9(11)V99
CTA-ESTADO   X         A=activa I=inactiva
```

### Registro MOVIMIENTOS
```
MOV-ID       9(12)     identificador unico (idempotencia)
MOV-CUENTA   9(10)     cuenta origen
MOV-TIPO     X         D / R / T
MOV-MONTO    9(9)V99
MOV-DESTINO  9(10)     cuenta destino (solo T)
MOV-FECHA    X(10)
MOV-ESTADO   X         (lo marca el batch)
```

## 6. Programas
Online: ALTACUENTA, CONSULTACUENTA, DEPOSITO, RETIRO, TRANSFERENCIA.
Batch: VALIDAR-MOVIMIENTOS, PROC-DEPOSITOS, PROC-RETIROS, PROC-TRANSFERENCIAS,
CONSOLIDAR, ACTUALIZAR-SALDOS, GENERAR-REPORTES.

## 7. Dependencias del JOB
- VALIDAR-MOVIMIENTOS debe terminar antes que cualquier PROC.
- PROC-DEPOSITOS, PROC-RETIROS y PROC-TRANSFERENCIAS pueden correr en paralelo.
- CONSOLIDAR depende de que terminen los tres PROC.
- ACTUALIZAR-SALDOS depende de CONSOLIDAR.
- GENERAR-REPORTES es el ultimo.

## 8. Idempotencia y restart
- Idempotencia: cada movimiento trae MOV-ID unico. El batch lleva registro de los ids ya
  aplicados; si llega un id repetido, no lo vuelve a aplicar (no se paga dos veces).
- Restart: el archivo CHECKPOINT guarda la ultima fase completada. Si el JOB se cae, al
  reiniciar se lee el CHECKPOINT y se reanuda desde la siguiente fase, sin repetir las ya
  terminadas ni los movimientos ya aplicados.
