# 🌙 NeuroSueño v5.0

**NeuroSueño** es una aplicación avanzada de gestión del sueño diseñada para optimizar tu descanso basándose en ciclos de sueño de 90 minutos (ritmos ultradianos). Ayuda a los usuarios a despertar en el momento óptimo para evitar la inercia del sueño y maximizar la energía diaria.

![Banner](assets/banner_placeholder.png)

## ✨ Características Principales

*   **🧠 Calculadora de Sueño Inteligente**: Calcula la hora ideal para ir a dormir o despertar basándose en ciclos de sueño completos.
*   **⚡ Siestas Energéticas (Power Naps)**: Modos predefinidos para siestas de 20m (Power Nap), 90m (Ciclo Completo) y más.
*   **⏰ Alarma Integrada**: Configura alarmas directamente desde la app con persistencia y gestión de estado.
*   **📊 Factores de Latencia**: Ajusta el cálculo del tiempo de sueño considerando factores como cafeína, luz azul, ejercicio y estrés.
*   **🎨 Diseño Premium**: Interfaz moderna y minimalista con modo oscuro, animaciones fluidas y componentes estilo "Bento Grid".

## 🛠️ Tecnologías y Arquitectura

Este proyecto está construido con **Flutter** siguiendo una arquitectura modular y principios de **Atomic Design**.

*   **Gestión de Estado**: [Flutter Riverpod](https://riverpod.dev/)
*   **Arquitectura**: Atomic Design (Atoms, Molecules, Organisms) + Feature-based Modules.
*   **Alarmas**: [alarm](https://pub.dev/packages/alarm) package.
*   **Persistencia**: [shared_preferences](https://pub.dev/packages/shared_preferences).
*   **Iconos**: [lucide_icons](https://pub.dev/packages/lucide_icons).

### 📂 Estructura del Proyecto

```
lib/
├── core/                   # Configuraciones globales (Theme, Utils)
├── domain/                 # Lógica de negocio y Entidades
│   ├── entities/           # Modelos (SleepCycle, AlarmItem)
│   └── logic/              # Algoritmos (SleepCalculator)
├── presentation/
│   ├── modules/            # Módulos por funcionalidad
│   │   ├── home/           # Pantalla Principal, Calculadora
│   │   └── alarm/          # Gestión de Alarmas
│   ├── providers/          # Riverpod Providers
│   └── shared/             # Componentes Reutilizables (Atomic Design)
│       ├── atoms/          # Widgets indivisibles
│       ├── molecules/      # BentoCard, GlassModal
│       └── organisms/      # TimerWidget
└── main.dart
```

## 🚀 Instalación y Ejecución

1.  **Clonar el repositorio**:
    ```bash
    git clone https://github.com/tu-usuario/neuro_sleep.git
    cd neuro_sleep
    ```

2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```

3.  **Configuración de Permisos (iOS)**:
    Asegúrate de que `ios/Podfile` tenga habilitados los permisos de notificación:
    ```ruby
    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
      '$(inherited)',
      'PERMISSION_NOTIFICATIONS=1',
    ]
    ```
    Luego ejecuta:
    ```bash
    cd ios && pod install && cd ..
    ```

4.  **Ejecutar la App**:
    ```bash
    flutter run
    ```

## 📱 Permisos Requeridos

*   **Notificaciones**: Para mostrar alarmas cuando la app está en segundo plano.
*   **Alarmas Exactas (Android 12+)**: Para programar alarmas con precisión.

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, abre un issue o envía un pull request para mejoras y correcciones.

---
Desarrollado con 💙 y Flutter.
