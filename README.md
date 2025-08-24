# RegistroCE
# Sistema de Gestión de Calificaciones en Ensamblador 8086

## Descripción
Este proyecto implementa un sistema interactivo de gestión de calificaciones desarrollado en ensamblador 8086, diseñado para ejecutarse en un entorno de 16 bits (como MS-DOS) utilizando emuladores como DOSBox o emu8086. El sistema permite gestionar las calificaciones de hasta 15 estudiantes, incluyendo ingreso de datos, cálculo de estadísticas, búsqueda, ordenamiento y manejo básico de errores, cumpliendo con los requisitos especificados.

## Características

### Funcionalidades Principales
- **Menú Principal Interactivo**: Interfaz de texto en pantalla con las siguientes opciones:
  1. **Ingresar Calificaciones**: Permite registrar hasta 15 estudiantes con su nombre completo (Nombre Apellido1 Apellido2) y una nota de tipo flotante (hasta 5 decimales, e.g., 92.77459 o 80.80).
  2. **Mostrar Estadísticas**: Calcula y muestra:
     - Promedio general de las calificaciones.
     - Nota máxima y mínima.
     - Cantidad y porcentaje de estudiantes aprobados (nota ≥ 70).
     - Cantidad y porcentaje de estudiantes reprobados (nota < 70).
  3. **Buscar Estudiante por Posición**: Localiza un estudiante por su índice en el arreglo.
  4. **Ordenar Calificaciones**: Ordena las calificaciones en orden ascendente o descendente utilizando un algoritmo de ordenamiento (Burbuja o Selección).
  5. **Salir**: Finaliza la ejecución del programa.

### Requisitos Técnicos
- **Subrutinas Modulares**: Uso de `CALL` y `RET` para estructurar el código en procedimientos modulares.
- **Ciclos y Comparaciones**: Implementación de estructuras de control con `LOOP`, `CMP` y saltos condicionales (`Jxx`).
- **Algoritmo de Ordenamiento**: Implementación de un algoritmo de ordenamiento (Burbuja o Selección) para ordenar las calificaciones.
- **Manejo de Entrada/Salida**: Uso de interrupciones de DOS (`INT 21h`) para la entrada y salida de caracteres y números.
- **Manejo de Errores**: Validación básica para evitar notas fuera del rango 0–100.

### Requisitos No Funcionales
- Código robusto con manejo de errores para entradas inválidas (e.g., notas fuera de rango).
- Diseñado para entornos de 16 bits, compatible con emuladores como DOSBox o emu8086.

## Requisitos del Sistema
- **Entorno**: Emulador de MS-DOS (recomendado: DOSBox o emu8086).
- **Ensamblador**: MASM, NASM o TASM para compilar el código.
- **Editor**: Visual Studio Code con extensiones para ensamblador (opcional) o cualquier editor de texto.
- **Sistema Operativo**: Cualquier sistema moderno que soporte emuladores de 16 bits.

## Instrucciones de Instalación y Ejecución
1. **Configurar el Entorno**:
   - Instala DOSBox o emu8086 en tu sistema.
   - Descarga e instala un ensamblador como NASM o MASM.
2. **Compilar el Código**:
   - Escribe o copia el código ensamblador en un archivo con extensión `.asm`.
   - Usa el ensamblador para generar el ejecutable. Por ejemplo, con NASM:
     ```bash
     nasm -f bin programa.asm -o programa.com