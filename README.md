# Chatzia

Una aplicación de chat inteligente construida con Ruby on Rails 8.0.

## Características

- **Sistema de Autenticación Seguro**: Usando bcrypt y sesiones seguras
- **Gestión de Agentes**: Crear y gestionar agentes de chat con diferentes estados
- **Conversaciones**: Sistema completo de conversaciones con mensajes
- **Autorización**: Control de acceso basado en propiedad de recursos
- **Validaciones Robustas**: Validaciones completas en todos los modelos
- **Manejo de Errores**: Sistema centralizado de manejo de excepciones
- **Logging**: Registro detallado de requests y responses

## Tecnologías

- **Ruby**: 3.4.5
- **Rails**: 8.0.2
- **Base de Datos**: SQLite3
- **Autenticación**: bcrypt
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Assets**: Propshaft

## Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd chatzia
   ```

2. **Instalar dependencias**
   ```bash
   bundle install
   ```

3. **Configurar base de datos**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Iniciar el servidor**
   ```bash
   rails server
   ```

## Estructura de la Aplicación

### Modelos

- **User**: Usuarios del sistema con autenticación
- **Agente**: Agentes de chat con estados (inactivo, activo, ocupado)
- **Conversacion**: Conversaciones entre usuarios y agentes
- **Mensaje**: Mensajes individuales en las conversaciones
- **Session**: Sesiones de usuario para autenticación

### Controladores

- **ApplicationController**: Controlador base con manejo de errores y logging
- **AgentesController**: CRUD para agentes con autorización
- **ConversacionsController**: Gestión de conversaciones
- **MensajesController**: Manejo de mensajes
- **SessionsController**: Autenticación de usuarios

### Características de Seguridad

- Validación de parámetros con `params.require().permit()`
- Autorización basada en propiedad de recursos
- Cookies seguras con `httponly` y `same_site: :lax`
- Validaciones robustas en todos los modelos
- Manejo centralizado de excepciones

## Constantes de la Aplicación

Las constantes están definidas en `config/initializers/constants.rb`:

- **AGENTE_ESTADOS**: Estados disponibles para agentes
- **LIMITES**: Límites de validación para campos
- **SESION_CONFIG**: Configuración de sesiones
- **MENSAJES_ERROR**: Mensajes de error estandarizados

## Pruebas

```bash
# Ejecutar todas las pruebas
rails test

# Ejecutar pruebas específicas
rails test test/models/agente_test.rb
```

## Despliegue

La aplicación está configurada para despliegue con Kamal:

```bash
kamal deploy
```

## Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT.
