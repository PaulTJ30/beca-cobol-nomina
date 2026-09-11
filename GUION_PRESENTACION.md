# Guion completo de presentacion (20 min)
## Sistema de Dispersion de Nomina (SIDN)

Proyecto individual. Agenda de 7 bloques (3+4+4+3+3+2+1 = 20 min) + Q&A de 3 min.
Apoyo visual: presentacion.html (diagrama fijo con resaltado + programas + archivos de
salida + capturas). Habla con datos y muestra el sistema corriendo.

Convenciones de este guion:
- [PANTALLA] = que dejar a la vista.
- [DEMO] = que correr en vivo (o mostrar la captura si algo falla).
- El texto entre comillas es lo que dices, en primera persona. Ajustalo a tu voz.

---

## Bloque 1 - Caso de negocio y arquitectura (3 min)

[PANTALLA] presentacion.html en la seccion "1. El tema" (el diagrama a la izquierda).

"Buenas. Voy a presentar el Sistema de Dispersion de Nomina. El problema de negocio es
sencillo de enunciar y pesado de resolver: cada quincena hay que pagar a miles de empleados,
dejando el monto exacto en la cuenta de cada uno, sin equivocarse y sin pagar dos veces.

El sistema vive en dos mundos. De dia, operaciones en linea: caja y app que consultan y
mueven saldos en tiempo real. De noche, un proceso batch de alto volumen que toma el archivo
de nomina y lo dispersa a todas las cuentas."

Encuadre de arquitectura (dilo tal cual, es tu decision de ingenieria):

"La arquitectura de referencia es Unisys ClearPath MCP: COBOL es la logica, WFL orquesta el
batch y DMSII persiste. Como no tenia acceso a un entorno MCP real, tome una decision de
ingenieria: implementar el sistema completo en OpenCOBOL y demostrar la capa MCP con
equivalentes funcionales. El maestro de cuentas es un archivo indexado, que hace el papel de
DMSII, y el JOB WFL lo ejecuto con un orquestador que respeta las mismas dependencias. Asi el
sistema corre de verdad hoy, y el diseno es portable a MCP sin tocar la logica de negocio."

[PANTALLA] Senala en el diagrama la zona verde (online) y la azul punteada (el JOB WFL).

---

## Bloque 2 - Proceso online (4 min)

[PANTALLA] Seccion "2. Los programas", tabla Online. (Al pasar el cursor por cada fila se
resalta su lugar en el diagrama.)

"De dia corren cinco operaciones sobre el maestro CUENTAS. ALTACUENTA da de alta al empleado;
el saldo arranca en cero, a proposito, porque la nomina se abona despues por el batch.
CONSULTACUENTA muestra sus datos y su saldo. DEPOSITO abona. RETIRO debita, y valida que no
quede saldo negativo. TRANSFERENCIA mueve entre dos cuentas, validando que ambas existan y que
haya fondos en el origen. Las cinco actualizan el saldo en tiempo real con READ y REWRITE
sobre el archivo indexado."

[DEMO] En una terminal ya preparada:
- CONSULTACUENTA 101 -> saldo 0.
- DEPOSITO 101, monto 500 -> "NUEVO SALDO 500".
- CONSULTACUENTA 101 -> saldo 500.

"Ahi esta lo importante: el saldo cambio en el momento. Esto es el mundo online; el volumen
grande viene en el batch."

(Si el demo falla: muestra la captura ONLINE.)

---

## Bloque 3 - Programacion COBOL (4 min)

[PANTALLA] Abre uno de los .cob, por ejemplo ACTUALIZAR-SALDOS.cob, y muestra el FD indexado
y el bloque READ / REWRITE. Deja tambien a la vista la seccion "3. Archivos de salida" del
HTML.

"Son 12 programas: 5 online y 7 batch, todos en COBOL-74, formato fijo. El maestro CUENTAS es
indexado por numero de cuenta; los movimientos entran por un archivo secuencial.

Un detalle tecnico que cuide, porque es una trampa clasica de COBOL-74: el READ con INVALID
KEY, si no lo cierras con punto, se traga la instruccion que sigue. Por eso cada lectura va en
su parrafo y cierra con punto, y uso banderas en vez de encadenar instrucciones dentro del
INVALID KEY.

Y aqui esta la trazabilidad de datos: cada programa produce un archivo. VALIDAR separa validos
de rechazados; los PROC filtran por tipo; CONSOLIDAR arma el consolidado y los totales de
control; ACTUALIZAR aplica al maestro; GENERAR-REPORTES arma el reporte final. Todo lo que ven
en estos archivos de salida es real, generado por la corrida."

[PANTALLA] Pasa el cursor por un archivo de salida (por ejemplo VALIDOS.TXT) para que se
resalte su lugar en el diagrama y los programas que lo tocan.

---

## Bloque 4 - WFL y orquestacion (3 min)

[PANTALLA] Abre dispersion.wfl; luego la seccion "4. WFL y orquestacion" del HTML.

"El batch lo orquesta un JOB WFL. El orden es: primero VALIDAR; luego los tres PROC por tipo
EN PARALELO -depositos, retiros y transferencias-; despues CONSOLIDAR; luego ACTUALIZAR-SALDOS;
y al final GENERAR-REPORTES. Las dependencias son estrictas: nada corre antes de que termine
lo que necesita. El WFL declara la orquestacion, el paralelismo, las dependencias, el control
de ejecucion y el restart.

En OpenCOBOL lo demuestro con el orquestador, que lanza los tres PROC en paralelo y lleva un
checkpoint por fase."

[DEMO] Genera el feed y corre la cadena:
- GENERA-MOVIMIENTOS -> 30
- orquestador -> se ve VALIDAR (30 leidos, 27 validos, 3 rechazados), los 3 PROC en paralelo,
  CONSOLIDAR (27 movimientos, suma 113,300), ACTUALIZAR (27 aplicados) y "REPORTE GENERADO".
- Abre REPORTE.TXT: 8 empleados de 4 empresas con sus saldos.

"Ocho empleados, cuatro empresas, montos de nomina variados: no es un dato de juguete, es una
quincena chica pero realista."

---

## Bloque 5 - Grandes volumenes y performance (3 min)

[PANTALLA] Seccion "5. Evidencia de pruebas", captura VOLUMEN; y PERFORMANCE.md.

"Ahora el volumen de verdad. Genero 50,000 movimientos -una quincena realista- de los cuales
45,000 son validos y 5,000 los rechazo a proposito, con cuentas inexistentes, para probar el
manejo de error. La cadena completa corre en alrededor de medio segundo, del orden de 90 a 100
mil movimientos por segundo.

El cuello de botella es ACTUALIZAR-SALDOS, con el 43% del tiempo, porque es la fase con mas
entrada/salida: por cada movimiento lee y reescribe el maestro, mas el indice de idempotencia.
Las optimizaciones: los tres PROC en paralelo, acceso por llave al maestro en lugar de barrido
secuencial, y validar antes de aplicar, para que las fases pesadas solo trabajen lo valido."

[DEMO opcional] GENERA-MOVIMIENTOS 50000 -> orquestador; di el tiempo que salga en pantalla.

---

## Bloque 6 - Restart e idempotencia (2 min)

[PANTALLA] Capturas RESTART y DUPLICIDAD.

"Dos garantias que en nomina no son opcionales.

Restart: si el JOB se cae a la mitad, no empieza de cero. Un checkpoint guarda la ultima fase
completada y reanuda desde ahi. Lo demuestro corriendo el orquestador una segunda vez: detecta
el checkpoint y omite las cinco fases."

[DEMO] Corre el orquestador otra vez -> "omitida" en las 5 fases.

"Idempotencia: ACTUALIZAR-SALDOS lleva un indice por id de movimiento. Si un movimiento ya se
aplico, lo salta. Lo corro una segunda vez y aplica cero, omite veintisiete. En nomina esto
significa: no pagar dos veces ni dejar a nadie sin pago, aunque el proceso se reinicie."

[DEMO] Corre ACTUALIZAR-SALDOS otra vez -> APLICADOS 0, OMITIDOS 27.

---

## Bloque 7 - Conclusiones (1 min)

[PANTALLA] Vuelve al diagrama completo (seccion 1).

"En resumen: un sistema bancario completo. Online mas batch de alto volumen, orquestado, con
integridad de datos y recuperacion ante fallas. Cumple el objetivo del reto: pensar como
desarrollador senior, no solo como programador COBOL. Gracias, quedo para sus preguntas."

---

## Q&A - respuestas cortas (3 min, sin diapositivas)

- "Por que no corre en MCP real?" -> Por acceso al entorno. La logica de negocio es identica;
  migrarla a MCP es configuracion de ambiente, no reescritura.
- "El WFL de verdad ejecuta?" -> El WFL esta escrito con sus cinco elementos. En este entorno
  la ejecucion la demuestra el orquestador, que respeta las mismas dependencias y corre los
  tres PROC en paralelo. La traduccion a WFL real es uno a uno.
- "El indexado equivale a DMSII?" -> En el patron de acceso, si: persistencia por llave con
  integridad. DMSII seria la base de datos de red administrada por MCP; la logica de acceso no
  cambia.
- "Como evitan pagar dos veces?" -> Idempotencia por id de movimiento en el indice PROCESADOS;
  un id ya aplicado se omite.
- "Que pasa con un movimiento invalido?" -> VALIDAR lo manda al log con su causa (por ejemplo,
  CUENTA NO EXISTE) y no llega a aplicarse.
- "Y si el volumen crece 10 veces?" -> El cuello es ACTUALIZAR-SALDOS por el I/O indexado; la
  mejora seria ordenar por cuenta para reducir el acceso aleatorio.

---

## Checklist antes de empezar
- Entorno fijado en la terminal (ver GUION_DEMO.md, paso 0).
- Estado limpio y las 8 cuentas sembradas.
- presentacion.html abierto; capturas de respaldo a la mano.
- dispersion.wfl y un .cob listos para mostrar.
- Ensayo cronometrado hecho al menos una vez.
