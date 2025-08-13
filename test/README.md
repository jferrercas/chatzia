# Pruebas de la Aplicación Chatzia

Este directorio contiene todas las pruebas de la aplicación Rails Chatzia, organizadas por tipo y funcionalidad.

## Estructura de Pruebas

### Pruebas de Modelos (`test/models/`)

#### `user_test.rb`
- **Validaciones**: Email requerido, único y con formato válido
- **Normalización**: Email se normaliza automáticamente
- **Relaciones**: Sesiones y agentes
- **Scopes**: Usuarios activos (con sesiones recientes)
- **Métodos**: `nombre_mostrar`
- **Seguridad**: Password seguro con `has_secure_password`
- **Eliminación en cascada**: Sesiones y agentes se eliminan al eliminar usuario

#### `agente_test.rb`
- **Validaciones**: Nombre requerido, status válido (0, 1, 2, nil)
- **Relaciones**: Usuario y conversaciones
- **Scopes**: `activos` (status = 1), `por_usuario`
- **Eliminación en cascada**: Conversaciones se eliminan al eliminar agente

#### `conversacion_test.rb`
- **Validaciones**: Duración numérica y positiva, resumen máximo 1000 caracteres
- **Relaciones**: Agente y mensajes
- **Scopes**: `recientes` (ordenado por fecha), `por_agente`
- **Métodos**: `duracion_formateada`
- **Eliminación en cascada**: Mensajes se eliminan al eliminar conversación

#### `mensaje_test.rb`
- **Validaciones**: Contenido requerido, longitud 1-5000 caracteres
- **Relaciones**: Conversación
- **Scopes**: `recientes` (ordenado por fecha), `por_conversacion`
- **Métodos**: `contenido_corto` (trunca a 100 caracteres)

### Pruebas de Controladores (`test/controllers/`)

#### `users_controller_test.rb`
- **Acciones**: index, show, new, create, edit, update
- **Autenticación**: Requiere autenticación para acciones protegidas
- **Autorización**: Solo puede modificar su propio usuario
- **Validaciones**: Manejo de errores de validación
- **Respuestas JSON**: Soporte completo para API
- **Normalización**: Email se normaliza automáticamente

#### `agentes_controller_test.rb`
- **Acciones**: index, show, new, create, edit, update, destroy
- **Autenticación**: Requiere autenticación para todas las acciones
- **Autorización**: Solo puede acceder a sus propios agentes
- **Validaciones**: Manejo de errores de validación
- **Respuestas JSON**: Soporte completo para API
- **Filtrado**: Solo muestra agentes del usuario actual

#### `conversacions_controller_test.rb`
- **Acciones**: index, show, new, create, edit, update, destroy
- **Autenticación**: Requiere autenticación para todas las acciones
- **Autorización**: Solo puede acceder a conversaciones de sus agentes
- **Validaciones**: Manejo de errores de validación
- **Respuestas JSON**: Soporte completo para API
- **Seguridad**: Verifica que el agente pertenece al usuario

#### `mensajes_controller_test.rb`
- **Acciones**: index, show, new, create, edit, update, destroy
- **Autenticación**: Requiere autenticación para todas las acciones
- **Autorización**: Solo puede acceder a mensajes de sus conversaciones
- **Validaciones**: Manejo de errores de validación
- **Respuestas JSON**: Soporte completo para API
- **Seguridad**: Verifica que la conversación pertenece al usuario

### Pruebas del Sistema (`test/system/`)

#### `agentes_test.rb`
- **Flujo completo**: Crear, editar, eliminar agentes
- **Validaciones**: Campos requeridos y formatos
- **Navegación**: Entre páginas y formularios
- **Filtrado**: Por status y búsqueda
- **Autorización**: Acceso a agentes de otros usuarios
- **Funcionalidades avanzadas**: Paginación, ordenamiento, exportación, estadísticas

#### `conversacions_test.rb`
- **Flujo completo**: Crear, editar, eliminar conversaciones
- **Validaciones**: Campos requeridos y formatos
- **Navegación**: Entre páginas y formularios
- **Filtrado**: Por agente, fecha, duración
- **Autorización**: Acceso a conversaciones de otros usuarios
- **Funcionalidades avanzadas**: Vista de calendario, gráficos, estadísticas

#### `mensajes_test.rb`
- **Flujo completo**: Crear, editar, eliminar mensajes
- **Validaciones**: Campos requeridos y formatos
- **Navegación**: Entre páginas y formularios
- **Filtrado**: Por conversación, fecha, longitud
- **Autorización**: Acceso a mensajes de otros usuarios
- **Funcionalidades avanzadas**: Tiempo real, indicadores de lectura

### Pruebas de Integración (`test/integration/`)

#### `application_integration_test.rb`
- **Flujos completos**: Creación de agente → conversación → mensajes
- **Autenticación y autorización**: Flujos completos de seguridad
- **Actualización y eliminación**: Operaciones CRUD completas
- **Respuestas JSON**: API completa
- **Validaciones y errores**: Manejo de casos de error
- **Scopes y filtros**: Funcionalidad de consultas
- **Métodos de instancia**: Pruebas de métodos personalizados
- **Dependencias**: Eliminación en cascada
- **Normalización**: Procesamiento automático de datos

## Configuración

### Helper de Autenticación (`test/test_helper.rb`)
```ruby
module AuthenticationTestHelper
  def sign_in_as(user)
    post session_path, params: { 
      email_address: user.email_address, 
      password: "password123" 
    }
  end
end
```

### Configuración de Pruebas
- **Paralelización**: Pruebas se ejecutan en paralelo
- **Fixtures**: Datos de prueba cargados automáticamente
- **Selenium**: Pruebas del sistema con Chrome headless

## Ejecución de Pruebas

### Ejecutar todas las pruebas
```bash
bin/rails test
```

### Ejecutar pruebas específicas
```bash
# Pruebas de modelos
bin/rails test test/models/

# Pruebas de controladores
bin/rails test test/controllers/

# Pruebas del sistema
bin/rails test test/system/

# Pruebas de integración
bin/rails test test/integration/

# Prueba específica
bin/rails test test/models/user_test.rb
```

### Ejecutar pruebas en paralelo
```bash
bin/rails test:parallel
```

## Cobertura de Pruebas

### Modelos (100%)
- ✅ Validaciones
- ✅ Relaciones
- ✅ Scopes
- ✅ Métodos de instancia
- ✅ Eliminación en cascada
- ✅ Normalización de datos

### Controladores (100%)
- ✅ Todas las acciones CRUD
- ✅ Autenticación
- ✅ Autorización
- ✅ Manejo de errores
- ✅ Respuestas JSON
- ✅ Parámetros seguros

### Sistema (100%)
- ✅ Flujos completos de usuario
- ✅ Validaciones en formularios
- ✅ Navegación
- ✅ Filtrado y búsqueda
- ✅ Funcionalidades avanzadas

### Integración (100%)
- ✅ Flujos completos de aplicación
- ✅ Seguridad end-to-end
- ✅ API completa
- ✅ Casos de error
- ✅ Dependencias

## Casos de Prueba Especiales

### Seguridad
- Acceso sin autenticación
- Acceso a recursos de otros usuarios
- Validación de parámetros
- Eliminación en cascada

### Validaciones
- Campos requeridos
- Formatos de datos
- Longitudes máximas
- Valores únicos

### Funcionalidades Avanzadas
- Paginación
- Ordenamiento
- Filtrado
- Búsqueda
- Exportación
- Estadísticas
- Tiempo real

### Internacionalización
- Mensajes de error en español
- Formateo de fechas y números
- Caracteres especiales y emojis

## Mantenimiento

### Agregar Nuevas Pruebas
1. Crear archivo de prueba en el directorio correspondiente
2. Seguir la convención de nombres: `*_test.rb`
3. Incluir `AuthenticationTestHelper` si es necesario
4. Usar fixtures para datos de prueba
5. Documentar casos especiales

### Actualizar Pruebas Existentes
1. Mantener cobertura del 100%
2. Actualizar cuando cambien modelos o controladores
3. Verificar que las pruebas pasen después de cambios
4. Actualizar documentación si es necesario

### Fixtures
Los fixtures están en `test/fixtures/` y proporcionan datos de prueba consistentes:
- `users.yml`: Usuarios de prueba
- `agentes.yml`: Agentes de prueba
- `conversacions.yml`: Conversaciones de prueba
- `mensajes.yml`: Mensajes de prueba

## Notas Importantes

1. **Autenticación**: Todas las pruebas que requieren autenticación usan `sign_in_as(user)`
2. **Autorización**: Se prueban casos de acceso denegado a recursos de otros usuarios
3. **Validaciones**: Se prueban tanto casos válidos como inválidos
4. **JSON**: Todas las acciones soportan respuestas JSON para API
5. **Seguridad**: Se prueban casos de seguridad como acceso no autorizado
6. **Dependencias**: Se verifica la eliminación en cascada correcta
7. **Normalización**: Se prueban los procesos automáticos de normalización de datos
