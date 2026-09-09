# Guion de presentacion (20 min)
## Banco Aurora - Sistema de Dispersion de Nomina

Proyecto individual. Agenda del proyecto. Hablar con datos, mostrar el sistema corriendo.

## 1. Caso de negocio y arquitectura (3 min)
"Banco Aurora dispersa la nomina de las empresas: cada quincena procesa miles de movimientos
para dejar el pago en la cuenta de cada empleado. El sistema tiene dos mundos: operaciones en
linea de dia (caja/app) y un proceso batch de noche que dispersa la nomina. La arquitectura
de referencia es Unisys ClearPath MCP, donde COBOL es la logica, WFL orquesta el batch, MCP
administra y DMSII persiste. Aqui lo implemente en GnuCOBOL: el maestro de cuentas es un
archivo indexado (equivalente a DMSII), y el JOB WFL lo demuestro con un orquestador."

## 2. Proceso online (4 min)
"De dia corren cinco operaciones sobre el maestro CUENTAS: ALTACUENTA da de alta al empleado;
CONSULTACUENTA muestra su saldo; DEPOSITO abona; RETIRO debita sin dejar saldo negativo; y
TRANSFERENCIA mueve entre dos cuentas validando ambas. Todas actualizan el saldo en tiempo
real con READ y REWRITE sobre el indexado." (Mostrar una consulta y un deposito en vivo.)

## 3. Programacion COBOL (4 min)
"Son 12 programas: 5 online y 7 batch. Todos en COBOL-74, formato fijo. El maestro CUENTAS es
indexado por numero de cuenta; los movimientos entran por un archivo secuencial. Un detalle
tecnico que cuido: en COBOL-74 el READ ... INVALID KEY sin punto se traga lo que sigue, asi
que uso banderas y cada lectura cierra con punto." (Mostrar la estructura de un programa.)

## 4. WFL y orquestacion (3 min)
"El batch lo orquesta un JOB WFL: primero VALIDAR; luego los tres PROC por tipo EN PARALELO
(depositos, retiros, transferencias); despues CONSOLIDAR; ACTUALIZAR-SALDOS; y GENERAR-
REPORTES. Las dependencias son claras: nada corre antes de que termine lo que necesita.
En GnuCOBOL lo demuestro con orquestador.ps1, que lanza los tres PROC en paralelo."
(Mostrar dispersion.wfl y correr el orquestador.)

## 5. Grandes volumenes y performance (3 min)
"Con 50,000 movimientos, la cadena completa corre en 0.55 segundos, unos 90,000 movimientos
por segundo. El cuello de botella es ACTUALIZAR-SALDOS, con 43% del tiempo, porque hace la
mayor cantidad de I/O indexado. Las optimizaciones: los PROC en paralelo, acceso por llave al
maestro, y validar antes de aplicar para que las fases pesadas solo trabajen lo valido."

## 6. Restart e idempotencia (2 min)
"Si el JOB se cae, no empieza de cero: un CHECKPOINT guarda la ultima fase completada y
reanuda desde ahi. Y a nivel de dato, ACTUALIZAR-SALDOS es idempotente: lleva un indice por
id de movimiento, asi que un movimiento ya aplicado no se aplica dos veces. En una nomina eso
significa: no pagar dos veces ni dejar a alguien sin pago, aunque el proceso se reinicie."
(Mostrar la corrida doble: la segunda omite todo.)

## 7. Conclusiones (1 min)
"Un sistema bancario completo: online + batch de alto volumen, orquestado, con integridad y
recuperacion ante fallas. Cumple el reto de pensar como desarrollador senior, no solo como
programador COBOL."
