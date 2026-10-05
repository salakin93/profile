# Ejemplo de uso: CRUD de Usuario

## Opción A — Chat (genera el código y tú lo pegas)
1. En VS Code pulsa `Ctrl+L`.
2. Escribe:
   ```
   /crud Usuario con nombre (texto, obligatorio, máx 100), edad (entero, 0-120) y genero (enum: MASCULINO, FEMENINO, OTRO)
   ```
3. El modelo devuelve cada archivo precedido de `// Archivo: ruta`. Usa el botón **Apply** de cada bloque para crearlo/insertarlo.

## Opción B — Modo agente (crea los archivos solo)
1. Abre el proyecto (p. ej. uno vacío generado en https://start.spring.io).
2. En el panel de Continue cambia el modo a **Agent**.
3. Pide:
   ```
   Crea en src/main/java/com/demo/usuario un CRUD completo para Usuario con nombre, edad y genero:
   entidad, DTOs, repositorio, servicio, controlador, manejo de errores, pruebas y README.
   ```
4. Aprueba cada archivo que propone crear.

> En CPU el modo agente es lento (varios minutos). Para el POC, la opción A es la más fiable;
> con GPU el modo agente se vuelve práctico.

## Otro stack
Añade la tecnología al pedido, por ejemplo:
`/crud Usuario (nombre, edad, genero) en .NET 8 Web API + EF Core + SQL Server`
