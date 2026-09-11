# ------------------------------------------------------------------
# SIDN - Sistema de Dispersion de Nomina
# Menu interactivo (launcher del proyecto). Corre cada cosa sin teclear
# comandos: preparar, generar, correr la cadena, online, pruebas, docs.
# Uso:  .\menu.ps1     (o:  powershell -ExecutionPolicy Bypass -File menu.ps1)
# ------------------------------------------------------------------
$ErrorActionPreference = "Continue"
$proj = "D:\Ntt\COBOL\ProyectoFinal"
$env:Path = "D:\Program Files\OpenCobolIDE\GnuCOBOL\bin;" + $env:Path
$env:COB_CONFIG_DIR = "D:\Program Files\OpenCobolIDE\GnuCOBOL\config"
$env:TMP = "D:\Ntt\tmp"; $env:TEMP = "D:\Ntt\tmp"
Set-Location $proj

function Pausa { Write-Host ""; Read-Host "Enter para volver al menu" | Out-Null }

function Limpiar {
  Remove-Item CUENTAS.DAT,PROCESADOS.DAT,CHECKPOINT.TXT,MOVIMIENTOS.TXT,`
    VALIDOS.TXT,LOG-RECHAZOS.TXT,MOVAPLICAR.TXT,CONTROL.TXT,REPORTE.TXT,`
    APLICA-D.TXT,APLICA-R.TXT,APLICA-T.TXT -ErrorAction SilentlyContinue
}

function Sembrar {
@"
101
JUAN PEREZ HERNANDEZ
TECNOLOGIA ALFA
S
102
MARIA LOPEZ GARCIA
TECNOLOGIA ALFA
S
103
CARLOS RUIZ MENDOZA
CONSTRUCTORA BETA
S
104
ANA TORRES VEGA
CONSTRUCTORA BETA
S
105
LUIS RAMOS CASTRO
COMERCIAL GAMA
S
106
SOFIA DIAZ NUNEZ
COMERCIAL GAMA
S
107
JORGE MENA SOLIS
SERVICIOS DELTA
S
108
ELENA SOTO RIVERA
SERVICIOS DELTA
N
"@ | .\ALTACUENTA.exe | Out-Null
}

function Compilar {
  Get-ChildItem *.cob | ForEach-Object { cobc -x $_.Name }
  Write-Host "Compilacion terminada."
}

function Abrir($f) {
  if (Test-Path $f) { Invoke-Item $f } else { Write-Host "No existe: $f" }
}

# --------------------------- SUBMENU: ONLINE ---------------------------
function Menu-Online {
  do {
    Clear-Host
    Write-Host "==== OPERACIONES ONLINE ===="
    Write-Host " 1) Alta de cuenta        (ALTACUENTA)"
    Write-Host " 2) Consultar cuenta      (CONSULTACUENTA)"
    Write-Host " 3) Deposito              (DEPOSITO)"
    Write-Host " 4) Retiro                (RETIRO)"
    Write-Host " 5) Transferencia         (TRANSFERENCIA)"
    Write-Host " 0) Volver"
    $o = Read-Host "Opcion"
    switch ($o) {
      "1" { .\ALTACUENTA.exe;      Pausa }
      "2" { .\CONSULTACUENTA.exe;  Pausa }
      "3" { .\DEPOSITO.exe;        Pausa }
      "4" { .\RETIRO.exe;          Pausa }
      "5" { .\TRANSFERENCIA.exe;   Pausa }
    }
  } while ($o -ne "0")
}

# --------------------------- SUBMENU: PRUEBAS ---------------------------
function Menu-Pruebas {
  do {
    Clear-Host
    Write-Host "==== PRUEBAS ===="
    Write-Host " 1) Funcional   (limpia, siembra, 30 mov, corre cadena, muestra reporte)"
    Write-Host " 2) Error       (ver LOG-RECHAZOS.TXT)"
    Write-Host " 3) Restart     (corre la cadena otra vez: omite fases por checkpoint)"
    Write-Host " 4) Duplicidad  (ACTUALIZAR-SALDOS otra vez: aplica 0, idempotente)"
    Write-Host " 5) Volumen     (limpia, siembra, 50000 mov, corre cadena)"
    Write-Host " 0) Volver"
    $o = Read-Host "Opcion"
    switch ($o) {
      "1" {
        Limpiar; Sembrar
        "30" | .\GENERA-MOVIMIENTOS.exe | Out-Null
        & "$proj\orquestador.ps1"
        Write-Host ""; Write-Host "---- REPORTE.TXT ----"; Get-Content REPORTE.TXT
        Pausa
      }
      "2" {
        if (Test-Path LOG-RECHAZOS.TXT) { Get-Content LOG-RECHAZOS.TXT }
        else { Write-Host "No hay log todavia; corre la prueba funcional primero." }
        Pausa
      }
      "3" { & "$proj\orquestador.ps1"; Pausa }
      "4" { .\ACTUALIZAR-SALDOS.exe;   Pausa }
      "5" {
        Limpiar; Sembrar
        "50000" | .\GENERA-MOVIMIENTOS.exe | Out-Null
        & "$proj\orquestador.ps1"
        Pausa
      }
    }
  } while ($o -ne "0")
}

# --------------------------- SUBMENU: DOCUMENTOS ---------------------------
function Menu-Docs {
  do {
    Clear-Host
    Write-Host "==== DOCUMENTOS (se abren en su app por defecto) ===="
    Write-Host " 1) Presentacion interactiva  (presentacion.html)"
    Write-Host " 2) Diseno tecnico            (DISENO_TECNICO.md)"
    Write-Host " 3) Evidencias de pruebas     (PRUEBAS.md)"
    Write-Host " 4) Reporte de performance    (PERFORMANCE.md)"
    Write-Host " 5) Guion de presentacion     (GUION_PRESENTACION.md)"
    Write-Host " 6) Guion de demo             (GUION_DEMO.md)"
    Write-Host " 7) Codigo WFL                (dispersion.wfl)"
    Write-Host " 8) Bitacora de avances       (AVANCES.md)"
    Write-Host " 0) Volver"
    $o = Read-Host "Opcion"
    switch ($o) {
      "1" { Abrir "presentacion.html" }
      "2" { Abrir "DISENO_TECNICO.md" }
      "3" { Abrir "PRUEBAS.md" }
      "4" { Abrir "PERFORMANCE.md" }
      "5" { Abrir "GUION_PRESENTACION.md" }
      "6" { Abrir "GUION_DEMO.md" }
      "7" { Abrir "dispersion.wfl" }
      "8" { Abrir "AVANCES.md" }
    }
  } while ($o -ne "0")
}

# --------------------------- MENU PRINCIPAL ---------------------------
do {
  Clear-Host
  Write-Host "=================================================="
  Write-Host "  SIDN - Sistema de Dispersion de Nomina"
  Write-Host "  Menu principal"
  Write-Host "=================================================="
  Write-Host " 1) Preparar demo      (limpia estado + siembra 8 cuentas)"
  Write-Host " 2) Generar feed       (crea MOVIMIENTOS.TXT con N movimientos)"
  Write-Host " 3) Correr la cadena   (orquestador: valida, PROC paralelo, consolida, aplica, reporta)"
  Write-Host " 4) Operaciones online >"
  Write-Host " 5) Pruebas >"
  Write-Host " 6) Documentos >"
  Write-Host " 7) Recompilar los programas (cobc -x)"
  Write-Host " 0) Salir"
  Write-Host "--------------------------------------------------"
  $c = Read-Host "Opcion"
  switch ($c) {
    "1" { Limpiar; Sembrar; Write-Host "Estado limpio y 8 cuentas sembradas."; Pausa }
    "2" {
      $n = Read-Host "Cuantos movimientos (30 = rapido, 50000 = volumen)"
      if ($n) { "$n" | .\GENERA-MOVIMIENTOS.exe }
      Pausa
    }
    "3" { & "$proj\orquestador.ps1"; Pausa }
    "4" { Menu-Online }
    "5" { Menu-Pruebas }
    "6" { Menu-Docs }
    "7" { Compilar; Pausa }
  }
} while ($c -ne "0")
Write-Host "Hasta luego."
