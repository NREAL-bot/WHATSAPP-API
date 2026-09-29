# Bot de moderación de stickers para WhatsApp

Bot no oficial basado en `whatsapp-web.js`. Detecta stickers en grupos, intenta borrarlos, avisa al remitente y expulsa al usuario al alcanzar el tercer aviso.

## Importante

- Esta implementación usa WhatsApp Web automatizado, no la API oficial de Meta.
- Puede desconectarse o hacer que WhatsApp limite o bloquee el número. Usa un número secundario y acepta el riesgo.
- El bot debe ser administrador del grupo para borrar mensajes y expulsar participantes.
- Por seguridad y para evitar falsos negativos, el código considera **todo sticker como no permitido**. No intenta decidir automáticamente si un sticker es pornográfico.
- No compartas códigos de vinculación, archivos de sesión ni credenciales.

## Requisitos

- Un servidor Linux que permanezca encendido: una VM, VPS o servidor propio.
- Docker y Docker Compose.
- Un número secundario de WhatsApp vinculado al bot.
- El número del bot añadido como administrador del grupo.

## Instalación rápida con Docker

```bash
git clone <tu-repositorio> whatsapp-sticker-moderator
cd whatsapp-sticker-moderator
cp .env.example .env
# Edita .env si quieres cambiar mensajes o reglas
docker compose build
docker compose up -d
```

Ver el QR y los registros:

```bash
docker compose logs -f
```

En el teléfono que tiene el número del bot:

1. Abre WhatsApp.
2. Ve a **Ajustes/Configuración > Dispositivos vinculados**.
3. Pulsa **Vincular un dispositivo**.
4. Escanea el QR que aparece en los registros del servidor.
5. Añade el número al grupo y hazlo administrador.

Después de vincularlo, el proceso conservará la sesión en `./auth`. No borres esa carpeta.

## Dónde alojarlo

### Recomendado: VPS Linux con Docker

Aloja el proyecto en una VM/VPS Ubuntu/Debian de cualquier proveedor que permita procesos persistentes. Para este bot basta normalmente con **1 vCPU, 1–2 GB de RAM y unos 10 GB de disco**, aunque Chromium puede consumir más memoria momentáneamente.

No lo alojes en un servicio que duerma el proceso o cierre contenedores inactivos: el bot debe estar funcionando continuamente para recibir mensajes.

### Alternativa: tu propio ordenador o Raspberry Pi

Es más barato, pero debe permanecer encendido, tener internet estable y no suspenderse.

### En esta sandbox

No es una ubicación adecuada para producción: el entorno puede hibernar y no garantiza un proceso 24/7. Úsala solo para pruebas.

## Configuración

En `.env`:

```env
MAX_WARNINGS=3
BLOCK_ALL_STICKERS=true
EXEMPT_ADMINS=true
WARNING_MESSAGE=⚠️ Sticker no permitido. Aviso {count}/{max}.
KICK_MESSAGE=🚫 Has alcanzado {max} avisos y has sido expulsado del grupo.
TZ=Europe/Madrid
```

Los avisos se guardan en `data/warnings.json`, asociados al grupo y al usuario. Al expulsar a alguien, su contador se elimina.

## Operación y mantenimiento

Actualizar y reiniciar:

```bash
git pull
docker compose build
docker compose up -d
```

Parar:

```bash
docker compose down
```

Comprobar estado:

```bash
docker compose ps
docker compose logs --tail=100
```

## Prueba recomendada

1. Crea un grupo de prueba.
2. Añade el bot como administrador.
3. Envía tres stickers desde una cuenta de prueba.
4. Comprueba que el sticker se borra, que llegan los avisos y que la expulsión solo ocurre en el tercer aviso.

## Personalización futura: solo stickers pornográficos

La detección fiable de contenido sexual requiere descargar cada sticker, analizarlo con un clasificador de imágenes y definir una política de privacidad. No se incluye activada por defecto porque enviaría contenido potencialmente sensible a un servicio externo y puede producir falsos positivos. El punto de extensión es el `if (message.type !== 'sticker')` del archivo `src/index.js`.
