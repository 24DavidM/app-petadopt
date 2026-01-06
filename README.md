# 🐾 PetAdopt App

Aplicación móvil  desarrollada en **Flutter** para conectar refugios de animales con adoptantes, siguiendo la arquitectura **Clean Architecture** con **Bloc** para gestión de estado.

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── stubs/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   ├── adoptante/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   └── refugio/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           └── pages/
└── main.dart
```

## 🏗️ Arquitectura

### Clean Architecture + Bloc

#### 📦 **Domain Layer** (Núcleo de negocio)
- **Entities**: Modelos de dominio puros (sin dependencias externas)
- **Repositories**: Interfaces (contratos) para acceso a datos
- **Use Cases**: Lógica de negocio (un caso de uso = una acción)

#### 💾 **Data Layer** (Acceso a datos)
- **Data Sources**: Comunicación con APIs, bases de datos, storage
- **Models**: Implementaciones de entities con conversión a/from JSON
- **Repository Implementations**: Implementan las interfaces del dominio

#### 🎨 **Presentation Layer** (UI e interacción)
- **Bloc**: Gestión de estado con eventos y estados
- **Pages**: Pantallas de la app
- **Widgets**: Componentes reutilizables

## 🔧 Tecnologías Principales

- **Flutter** 3.x / Dart SDK: ^3.10.4
- **Supabase**: `supabase_flutter` ^2.12.0 (Auth, Postgres, Storage)
- **Gestión de estado**: `flutter_bloc` ^9.1.1
- **Inyección de dependencias**: `get_it` ^9.2.0
- **Programación funcional / utilidades**: `dartz` ^0.10.1, `equatable` ^2.0.5
- **HTTP / Config**: `http` ^1.6.0, `flutter_dotenv` ^6.0.0
- **Autenticación / Enlaces**: `sign_in_with_apple` ^7.0.1, `app_links` (override to 6.2.0)
- **Imágenes**: `image_picker` ^1.0.7, `flutter_local_notifications` ^18.0.1, `timezone` ^0.9.4
- **Mapas & Geolocalización**: `flutter_map` ^7.0.2, `latlong2` ^0.9.1, `geolocator` ^13.0.2
- **IA / Markdown**: `google_generative_ai` ^0.4.6, `flutter_markdown` ^0.7.0




## 🚀 Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone <repo-url>
cd app_petadopt
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Supabase

#### a) Crear proyecto en [Supabase](https://supabase.com)

#### b) Ejecutar el script SQL
```sql
-- Ejecutar los script qu estan ubicados en sql 
```

#### c) Crear archivo `.env` en la raíz del proyecto
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
VERCEL_CONFIG_URL=https://tu-vercel-config-url
GEMINI_API_KEY=tu-gemini-api-key
```

#### d) Configurar Google OAuth (opcional)
1. Ir a **Authentication > Providers** en Supabase
2. Habilitar Google OAuth
3. Añadir credenciales de Google Cloud Console
4. Configurar deep links:
   - Android: `petaadpot://auth-callback`


### 4. Ejecutar la app
```bash
# Android
flutter run

# Web
flutter run -d chrome
```
