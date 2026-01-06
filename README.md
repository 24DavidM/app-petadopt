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
  - `RemoteDataSource`: Llamadas a Supabase
  - `LocalDataSource`: Cache local con SharedPreferences
- **Models**: Implementaciones de entities con `fromJson/toJson`
- **Repository Implementations**: Implementan las interfaces del dominio

#### 🎨 **Presentation Layer** (UI e interacción)
- **Bloc**: Gestión de estado con eventos y estados
- **Pages**: Pantallas de la app
- **Widgets**: Componentes reutilizables

## 🔧 Tecnologías Principales

- **Flutter** 3.x
- **Supabase** (Backend as a Service)
  - Autenticación (Email + Google OAuth)
  - PostgreSQL con Row Level Security (RLS)
  - Storage para imágenes
- **flutter_bloc** - Gestión de estado
- **get_it** - Inyección de dependencias
- **dartz** - Programación funcional (Either para manejo de errores)
- **equatable** - Comparación de objetos
- **image_picker** - Selección de imágenes


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
