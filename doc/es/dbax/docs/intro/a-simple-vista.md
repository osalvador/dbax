# Empezando con dbax

## A simple vista

### dbax es un Framework de Aplicaciones

dbax es un potente framework de desarrollo de aplicaciones, un conjunto de herramientas (toolkit) para construir aplicaciones web usando SQL y PL/SQL en las bases de datos Oracle.

Su objetivo es permitir el desarrollo de proyectos mucho más rápido de lo que lo haría si estuviera escribiendo el código desde cero, proporcionando un conjunto de librerías (APIs) para las tareas comunes, así como una interfaz simple. dbax le permite centrarse en su proyecto, reduciendo al mínimo la cantidad de código necesaria para una desarrollar una tarea.

### dbax es libre

dbax está disponible bajo la licencia LGPL para que puedas usarlo como quieras. Para obtener más información, puede leer el [acurdo de licencia](https://github.com/osalvador/dbax/blob/master/LICENSE).

### dbax es ligero

Verdaderamente ligero. El núcleo del sistema requiere sólo unas pocas librerias muy pequeñas. Al contrario que con muchos frameworks que requieren muchos más recursos. Con PL/SQL las librerias se cargan de forma dinámica a petición, por lo que el sistema de base es muy delgado y bastante rápido.

###dbax es rápido

Realmente rápido. Le retamos a encontrar un framework MVC PL/SQL que tenga mejor rendimiento que dbax.

###dbax usa M-V-C

dbax utiliza el enfoque de Modelo-Vista-Controlador, que permite una correcta  separación entre la lógica y la presentación. Esto es particularmente bueno para los proyectos en los que los diseñadores están trabajando con los archivos de plantilla (front-end), ya que se reducirá al mínimo el código de que estos archivos contienen. MVC se describe con más detalle en su propia página.

###dbax Genera URLs limpias

Las URLs generadas por dbax son limpias y amigables para los motores de búsqueda. En lugar de utilizar el método estándar "query string" que usan los sistemas dinámicos, dbax utiliza un enfoque basado en segmentos:

    example.com/noticias/articulo/345

!!! note
    Por defecto, el `dad_name` y el `appid`  estan incluidos en la URL pero puede ser eliminado mediante `mod_rewrite` de Apache.

###dbax Pega Fuerte

dbax viene con una serie completa de las librerias o paquetes que simplifican las tareas de desarrollo web más comunes, como el login de un usaurio, el envío de correo electrónico, la validación de los datos del formulario, el mantenimiento de sesiones, trabajar con datos XML y mucho más.

###dbax es Extensible

El sistema se puede ampliar fácilmente a través del uso de sus propias librerias, helpers, o por medio de cualquier paquete de terceros.

###dbax incopora un Motor de Plantillas 

Un motor de plantillas es necesario para mantener una iteraccion con las vistas HTML, por tanto dbax incorpora un sencillo motor de plantillas basado en  [tePLSQL](https://github.com/osalvador/tePLSQL) el cual tiene la misma sintaxis que Oracle PSP y Java JSP:

``` java
<ul>
    <% for c1 in (select username from all_users) loop %>
        <li><%=c1.username%></li>
    <% end loop; %>
</ul>
```

De este modo, usted no tiene que aprender un nuevo lenguaje de plantillas. Además los archivos PSP que tenga, serán compatibles con dbax sin tener que modificarlos. 

###dbax está debidamente documentado

A los programadores les encanta programar pero odian a escribir documentación. No somos diferentes, por supuesto, pero ya que la documentación es tan importante como el propio código, estamos comprometidos a hacerlo. Nuestro código fuente está extremadamente limpio y bien comentado también.




<script> 
  //Google prettyprint for pl/sql
  document.addEventListener("DOMContentLoaded", function(event) { prettyPrint(); });
</script>