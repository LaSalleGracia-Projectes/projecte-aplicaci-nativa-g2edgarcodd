
# StreamHub - Aplicación para compartir gustos cinematográficos

![StreamHub Logo](images/logo.png)

StreamHub es una aplicación multiplataforma desarrollada con Flutter que permite a los usuarios explorar, compartir y descubrir contenido cinematográfico. La aplicación ofrece una experiencia intuitiva para navegar por películas y series, guardar favoritos, y conectar con otros usuarios que comparten intereses similares.

## 📋 Requisitos previos

Antes de comenzar, asegúrate de tener instalado:

- [Flutter](https://flutter.dev/docs/get-started/install) (versión 3.x o superior)
- [Dart](https://dart.dev/get-dart) (versión 3.x o superior)
- [Git](https://git-scm.com/downloads)
- [MongoDB](https://www.mongodb.com/try/download/community) (para el almacenamiento local)
- Un IDE como [Visual Studio Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio)

## 🚀 Guía de despliegue

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/projecte-aplicaci-nativa-g2edgarcodd.git
cd projecte-aplicaci-nativa-g2edgarcodd
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configuración de MongoDB local

1. Asegúrate de tener MongoDB instalado y en ejecución en tu sistema.
2. Crea una base de datos llamada `streamhub`:

```bash
mongosh
use streamhub
```

3. Crea una colección para el contenido de la plataforma:

```bash
db.createCollection("content")
```

4. (Opcional) Puedes insertar algunos datos de ejemplo:

```bash
db.content.insertMany([
  {
    "#TITLE": "Película de ejemplo",
    "#IMG_POSTER": "https://via.placeholder.com/150x225?text=Ejemplo"
  },
  {
    "#TITLE": "Serie de ejemplo",
    "#IMG_POSTER": "https://via.placeholder.com/150x225?text=Ejemplo"
  }
])
```

### 4. Configuración del servidor API

La aplicación utiliza un backend API desarrollado en Laravel para la autenticación y otras funcionalidades. El servidor API debe estar configurado en la dirección `http://25.17.74.119:8000` o modificar las URLs en el código para que apunten a tu servidor local.

Para usar tu propio servidor local:

1. Clona el repositorio del backend (no incluido en este README)
2. Configura la base de datos MySQL
3. Ejecuta las migraciones y seeders
4. Inicia el servidor Laravel
5. Actualiza las URLs en la aplicación para que apunten a tu servidor local

### 5. Ejecución de la aplicación

Para ejecutar la aplicación en modo de desarrollo:

```bash
flutter run
```

Para ver una lista de dispositivos disponibles:

```bash
flutter devices
```

Para ejecutar en un dispositivo específico:

```bash
flutter run -d [ID-DEL-DISPOSITIVO]
```

### 6. Compilación para producción

#### Android

Para generar un APK instalable:

```bash
flutter build apk --release
```

El APK generado se encontrará en `build/app/outputs/flutter-apk/app-release.apk`

#### iOS (requiere macOS)

```bash
flutter build ios --release
```

A continuación, abre el proyecto Xcode generado y distribuye la app según las directrices de Apple.

#### Web

```bash
flutter build web --release
```

El resultado se guardará en la carpeta `build/web` y podrás desplegar estos archivos en cualquier servidor web estático.

## 🔑 Autenticación y API

La aplicación se conecta a un backend Laravel que proporciona:
- Registro de usuarios
- Autenticación mediante tokens
- Gestión de reseñas
- Perfil de usuario

Los endpoints de la API están configurados para usar `http://25.17.74.119:8000` como URL base.

## 🖥️ Estructura del proyecto

```
lib/
├── Header/             # Componentes de la cabecera
├── l10n/               # Archivos de internacionalización
├── Menu_Usuario/       # Pantallas del menú de usuario
├── Models/             # Modelos de datos
├── Registro/           # Pantallas de registro y login
├── Secciones/          # Secciones principales de la app
├── Services/           # Servicios para conexión con APIs
├── main.dart           # Punto de entrada de la aplicación
└── theme_provider.dart # Proveedor del tema
```

## 📱 Características principales

- Exploración de películas y series usando la API de TMDB
- Sistema de autenticación de usuarios
- Perfil personalizable
- Reseñas y valoraciones
- Modo oscuro/claro
- Multilenguaje (Español/Inglés)
- Interfaz adaptable a diferentes dispositivos

## 👥 Contribuyentes

- [Nombre del Contribuyente 1](https://github.com/usuario1)
- [Nombre del Contribuyente 2](https://github.com/usuario2)

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo [LICENSE.txt](LICENSE.txt) para más detalles.
