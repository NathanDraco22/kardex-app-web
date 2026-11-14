# Operación y Entorno (`kardex_app_front`)

Cómo instalar, ejecutar, verificar y compilar la aplicación.

---

## 1. Requisitos

- Flutter `>=3.44.0` y Dart `^3.12.0`.
- Android SDK + NDK `28.2.13676358` para builds Android (ver `android/app/build.gradle.kts`).
- Python (solo para los scripts de `scripts/`).

En Windows, el `README.md` sugiere:

```powershell
$env:HOME = "C:\Users\sytru"
$env:ANDROID_NDK_HOME = "C:\Users\sytru\AppData\Local\Android\Sdk\ndk\28.2.13676358"
```

---

## 2. Instalación

```powershell
cd kardex_app_front
flutter pub get
```

El paquete local `packages/kardex_business` se resuelve por path (`pubspec.yaml`).

---

## 3. Ejecución local

La app usa `--dart-define-from-file` para inyectar URLs y secretos.

### Web

```powershell
flutter run -d chrome --web-port=8080 --dart-define-from-file secrets.json
```

### Windows

```powershell
flutter run -d windows --dart-define-from-file secrets.json
```

### Android

```powershell
flutter run -d <device-id> --dart-define-from-file secrets.json
```

### VS Code

`.vscode/launch.json` ya define tres configuraciones (`debug`, `profile`, `release`) que usan `secrets.json`. En web agrega `--web-port=8080`.

> Si no pasas `--dart-define-from-file`, la app usa los defaults de `lib/config/app_env.dart` (`http://localhost:8000`).

---

## 4. Archivos de secretos

| Archivo | Uso | Versionado |
| :--- | :--- | :--- |
| `secrets.json` | Entorno local de desarrollo. | Ignorado por Git. |
| `secrets_dev.json` | Entorno de desarrollo compartido. | Ignorado por Git. |
| `secrets_prod.json` | Entorno de producción. | Ignorado por Git. |
| `secrets-template.json` | Plantilla mínima (`ORIGIN_SERVER_URL`). | Versionado. |
| `scripts/secrets_script_template.json` | Plantilla usada por scripts. | Versionado. |

Contenido típico:

```json
{
  "SERVER_URL": "http://localhost:8000",
  "ORIGIN_SERVER_URL": "http://localhost:8001"
}
```

> Nunca commitees credenciales reales en `secrets*.json` ni en `secrets-template.json`.

---

## 5. Defines soportados

| Define | Archivo | Uso |
| :--- | :--- | :--- |
| `SERVER_URL` | `lib/config/app_env.dart` | URL base del backend (`kardex-server`). |
| `PRACTICE_URL` | `lib/config/app_env.dart` | URL secundaria de práctica. |
| `ORIGIN_SERVER_URL` | `image_uploader.dart`, `servin_data_source.dart` | Servidor de origen para Servin e imágenes. |
| `SHOW_UNIT_SCALES` | `lib/constants/feature_flags.dart` | Muestra u oculta escalas de unidades (`true` por defecto). |

Ejemplo para ocultar escalas:

```powershell
flutter run --dart-define=SHOW_UNIT_SCALES=false --dart-define-from-file secrets.json
```

---

## 6. Verificación

```powershell
# Análisis estático de toda la app
flutter analyze

# Paquete de dominio
dart analyze packages/kardex_business

# Tests
flutter test

# Un test concreto
flutter test test/credit_note_policy_test.dart

# Un módulo concreto
flutter analyze lib/src/modules/<modulo>
```

Objetivo: **0 errores y 0 warnings**. No silencies lints sin justificación.

---

## 7. Compilación

### Compilar por edición

Antes de compilar, confirma la rama y el `applicationId`:

| Aspecto | `main` | `lite` |
| :--- | :--- | :--- |
| Rama | `main` | `lite` |
| Web | `python scripts/compile_web.py` | `python scripts/compile_web_lite.py` |
| Android | `python scripts/compile_android.py` | `python scripts/compile_android_lite.py` |
| APK | `neptuno-arm64-v8a.apk` / `neptuno-armeabi-v7a.apk` | `neptuno-lite-arm64-v8a.apk` / `neptuno-lite-armeabi-v7a.apk` |
| `applicationId` | `com.nathandraco22.neptuno_system` | `com.nathandraco22.neptuno_system_lite` |

> [!WARNING]
> Los scripts no cambian de rama por ti. Ejecuta la compilación **desde la rama correcta** y verifica el `applicationId` antes de publicar. Ver [`ramas_main_vs_lite.md`](./ramas_main_vs_lite.md).

### Web

```powershell
flutter build web --wasm --release --dart-define-from-file secrets.json
```

O con el script (mueve el build a `output/web` y opcionalmente despliega):

```powershell
python scripts/compile_web.py
python scripts/compile_web.py deploy   # publica en Netlify
```

- `compile_web.py` → edición estándar.
- `compile_web_lite.py` → edición lite.
- Firebase Hosting publica `output/web` (`firebase.json`).

### Android

```powershell
flutter build apk --release --split-per-abi --android-skip-build-dependency-validation --dart-define-from-file secrets.json
```

O con scripts (mueven los APK a `output/apk` y los renombran):

```powershell
python scripts/compile_android.py        # neptuno-arm64-v8a.apk / neptuno-armeabi-v7a.apk
python scripts/compile_android_lite.py   # neptuno-lite-*.apk
```

- `applicationId` y metadatos Android cambian según la edición/rama.
- Los scripts incluyen tokens de despliegue; trátalos como secretos.

### Windows

```powershell
flutter build windows --release --dart-define-from-file secrets.json
```

---

## 8. Salidas

| Ruta | Contenido |
| :--- | :--- |
| `build/` | Salida nativa de Flutter (ignorada por Git). |
| `output/web/` | Build web listo para hosting. |
| `output/apk/` | APK renombrados por edición. |
| `output/deploy.zip` | Paquete de despliegue web. |

---

## 9. Problemas comunes

| Síntoma | Causa probable | Solución |
| :--- | :--- | :--- |
| La app apunta a `localhost:8000` | No se pasó `--dart-define-from-file`. | Usa `secrets.json`. |
| `Unable to find a device` | No hay emulador/dispositivo activo. | `flutter devices` y elige uno con `-d`. |
| Falla el build Android por NDK | NDK no coincide con `28.2.13676358`. | Instálalo y define `ANDROID_NDK_HOME`. |
| Cambios en `packages/kardex_business` no se reflejan | Pub cache desactualizado. | `flutter pub get` y reinicia la app. |
| `flutter analyze` marca warnings preexistentes | Deuda técnica. | No los aumentes; corrige lo que toques. |

---

## 10. Checklist al terminar una tarea

- [ ] `flutter pub get` sin cambios inesperados en `pubspec.lock`.
- [ ] `flutter analyze` limpio.
- [ ] `dart analyze packages/kardex_business` limpio si tocaste el paquete.
- [ ] `flutter test` pasa (o se documenta por qué no aplica).
- [ ] La app arranca en la plataforma objetivo.
- [ ] Se evaluó el impacto en `lite`.
- [ ] Cambio registrado en `GEMINI.md` según `agents.md`.
