# HairMatch

Una aplicación móvil desarrollada en Flutter que utiliza visión por computadora e inteligencia artificial para recomendar cortes de pelo basados en la forma del rostro del usuario.

## Características

- Captura de fotos con la cámara frontal o trasera
- Detección automática de la forma del rostro (ovalado, cuadrado, redondo, etc.)
- Análisis de características faciales mediante Google ML Kit
- Recomendaciones personalizadas de cortes de pelo según la forma del rostro
- Interfaz de usuario intuitiva y moderna
- Soporte para recomendaciones tanto para hombres como para mujeres

## Tecnologías utilizadas

- **Flutter**: Framework para desarrollo multiplataforma
- **Google ML Kit Face Detection**: Para la detección y análisis facial
- **Flutter BLoC**: Para la gestión del estado de la aplicación
- **Camera package**: Para acceso a la cámara del dispositivo

## Requisitos

- Flutter SDK 3.7.0 o superior
- Dart 3.0.0 o superior
- Android SDK 21+ o iOS 11+
- Permisos de cámara en el dispositivo

## Instalación

1. Clona este repositorio:
```
git clone https://github.com/tu-usuario/haircut_recommender.git
```

2. Navega al directorio del proyecto:
```
cd haircut_recommender
```

3. Instala las dependencias:
```
flutter pub get
```

4. Ejecuta la aplicación:
```
flutter run
```

## Estructura del proyecto

```
lib/
├── bloc/                # Gestión del estado con BLoC
├── models/              # Modelos de datos
├── screens/             # Pantallas de la aplicación
├── services/            # Servicios (cámara, detección facial)
├── utils/               # Utilidades y helpers
├── widgets/             # Widgets reutilizables
└── main.dart            # Punto de entrada de la aplicación
```

## Cómo funciona

1. La aplicación utiliza la cámara del dispositivo para capturar una imagen del rostro del usuario.
2. Google ML Kit detecta los puntos de referencia faciales y los contornos del rostro.
3. El algoritmo analiza las proporciones y características del rostro para determinar su forma.
4. Basado en la forma detectada, la aplicación recomienda estilos de corte de pelo que mejor se adapten.
5. El usuario puede alternar entre recomendaciones para hombres y mujeres.

## Limitaciones actuales

- Requiere buena iluminación para una detección precisa
- La detección funciona mejor con el rostro completamente visible (sin gafas, pelo cubriendo la cara, etc.)
- Las imágenes de los cortes de pelo son placeholders y deben ser reemplazadas con imágenes reales

## Posibles mejoras futuras

- Implementar un modelo ML personalizado para mejorar la precisión de la detección
- Agregar más estilos de cortes de pelo con imágenes reales
- Permitir guardar y compartir los resultados
- Implementar AR para "probar" virtualmente los cortes de pelo
- Integración con redes sociales o salones de belleza cercanos

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para más detalles.
