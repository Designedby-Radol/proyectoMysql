# Proyecto: Base de Datos Campuslands

## Descripción del Proyecto
Campuslands es un centro de entrenamiento para programadores donde los campers pueden desarrollar sus habilidades técnicas a través de rutas de aprendizaje y módulos especializados. La base de datos diseñada permite gestionar las inscripciones, evaluaciones, entrenadores, rutas, módulos y áreas de entrenamiento de manera eficiente.

Este proyecto tiene como objetivo proporcionar una estructura de datos normalizada (3FN) que facilite la administración de los campers, su historial académico, el seguimiento de sus evaluaciones y la gestión de los trainers y sus asignaciones.

---

## Requisitos del Sistema
Para ejecutar correctamente este proyecto, asegúrate de contar con los siguientes requisitos:

- MySQL Server 8.0 o superior.
- MySQL Workbench (opcional, para gestión visual de la base de datos).
- Un entorno de desarrollo con acceso a una terminal SQL.

---

## Instalación y Configuración
Para desplegar la base de datos, sigue estos pasos:

### 1. Crear la Base de Datos y Tablas:
Ejecuta el archivo `ddl.sql` en MySQL para generar la estructura de la base de datos.

### 2. Cargar Datos Iniciales:
Ejecuta el archivo `dml.sql` para poblar la base de datos con datos de prueba.

### 3. Ejecutar Procedimientos y Funciones:
Para cargar las funciones y procedimientos almacenados, ejecuta los archivos `dql_funciones.sql` y `dql_procedimientos.sql`.

### 4. Ejecutar Triggers y Eventos:
Para definir la lógica automatizada en la base de datos, ejecuta `dql_triggers.sql`.

---

## Estructura de la Base de Datos
La base de datos **campuslands** está compuesta por las siguientes tablas:

- **Campers**: Almacena información sobre los estudiantes inscritos.
- **Trainers**: Registra los instructores y sus módulos asignados.
- **Rutas**: Contiene las diferentes rutas de aprendizaje disponibles.
- **Modulos**: Lista los módulos que conforman las rutas de entrenamiento.
- **Evaluaciones**: Guarda los registros de evaluaciones de cada camper.
- **Áreas de Entrenamiento**: Administra los espacios físicos de aprendizaje.
- **Grupos**: Permite la organización de campers en clases específicas.
- **Historial de Estados**: Registra los cambios de estado de los campers.
- **Egresados**: Contiene los campers que han completado el programa exitosamente.

---

## Ejemplos de Consultas
Algunas consultas útiles que se pueden ejecutar en la base de datos:

### Obtener la lista de campers inscritos:
```sql
SELECT * FROM Campers WHERE estado_actual = 'Inscrito';
```

### Consultar las evaluaciones de un camper:
```sql
SELECT * FROM Evaluaciones WHERE documento_camper = '123456789';
```

### Verificar disponibilidad de un área en un horario específico:
```sql
SELECT * FROM AreasEntrenamiento WHERE id_area = 2
AND capacidad_maxima > (SELECT COUNT(*) FROM Asistencia WHERE id_area = 2);
```

---

## Procedimientos, Funciones, Triggers y Eventos

### **Procedimientos Almacenados**
- `RegistrarEvaluacion`: Inserta una nueva evaluación y calcula la nota final.
- `ActualizarEstadoCamper`: Modifica el estado de un camper según sus evaluaciones.
- `AsignarCamperAGrupo`: Inscribe un camper en un grupo, validando disponibilidad.

### **Funciones**
- `CalcularPromedioEvaluaciones(camper_id)`: Retorna el promedio ponderado de evaluaciones.
- `CamperAprobadoEnModulo(camper_id, modulo_id)`: Determina si un camper aprobó un módulo.

### **Triggers**
- `TRG_CalcularNotaFinal`: Al insertar una evaluación, calcula la nota final automáticamente.
- `TRG_ActualizarEstadoModulo`: Modifica el estado de un camper tras la actualización de su nota final.
- `TRG_ValidarCapacidadArea`: Verifica que un área no exceda su capacidad al asignar campers.

### **Eventos**
- `EVT_ActualizarEstados`: Revisa y actualiza estados de campers cada semana.

---

## Roles de Usuario y Permisos
La base de datos implementa los siguientes roles de usuario:

- **Administrador**: Acceso completo a la base de datos.
- **Trainer**: Puede registrar evaluaciones y gestionar módulos.
- **Campers**: Puede consultar sus evaluaciones y estado.
- **Coordinador**: Puede asignar campers a grupos y rutas.
- **Auditor**: Solo tiene permisos de lectura sobre la base de datos.

---

## Licencia
Este proyecto está bajo la **Licencia MIT**.

---

## 📩 Contacto
Para dudas o soporte, puedes contactarme a través de **[raulsantiagoramirez1@gmail.com](mailto:raulsantiagoramirez1@gmail.com)**.

