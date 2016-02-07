<p class="page-header1"><b>Buenas practicas MVC</b></p>

Aunque el modelo Model-View-Controller (MVC) es conocido por casi todos los desarrolladores Web, cómo utilizarlo correctamente en el desarrollo de aplicaciones reales todavía es desconocido por muchos de ellos. La principal idea central detrás MVC es la reutilización del código y la separación de las responsabilidades. En esta sección, se describen algunas pautas generales sobre cómo implementar MVC en el desarrollo de una aplicación DBAX.

Para explicar mejor estas directrices, se supone una aplicación web se compone de varias sub-aplicaciones: 

- front end: es la parte de un sitio web que interactua con los usuarios finales;
- back end: es la parte que normalmente procesa la entrada desde el fron end y que contiene la funcionalidad administrativa para la gestión de la aplicación. El acceso suele estar restringida a administradores;
- consola web: se trata de una aplicación web que ayuda a configurar y controlar la aplicación;
- Web API: interfaces con terceros para la integración con la aplicación.

El conjunto de estas sub-aplicaciones conforman un aplicación DBAX. 

## Modelo

Los Modelos representan la estructura de datos subyacente de una aplicación web. Los modelos normalmente son reutilizados y compartidos entre las diferentes sub-aplicaciones de una aplicación web. Por ejemplo, un modelo llamado Noticias puede ser utilizado por las APIs Web o por el front end o back end de la aplicación, o incluso por otras aplicaciones. Por lo tanto, los modelos

- deben contener las propiedades (variables, arrays, records) para procesar sus datos específicos;
- deben contener la lógica de negocio (por ejemplo, reglas de validación) para asegurar que los datos tratados cumplen los requisitos del negocio;
- contienen el código para la manipulación de datos. Por ejemplo, un modelo para un formulario de busqueda SearchModel, además de procesar los datos de entrada, puede contener una método (procedimiento o función) para ejecutar la búsqueda real.

Por norma general, los modelos no deben contener lógica que se comunique directamente con los usuarios finales. Más concretamente, los modelos

- no deben usar `dbax_core.g$get`, `dbax_core.g$post`, u otras variables similares que están directamente vinculados a la solicitud del usuario final. Recordemos que un modelo puede ser utilizado por una sub-aplicación totalmente independiente (por ejemplo, pruebas unitarias, API web) que no usan estas variables en las peticiones. Estas variables relativas a la solicitud del usuario deben ser gestionadas por el controlador.
- deben evitar contener código HTML u otro código de presentación. Ya que el código de presentación varía en función de los requerimientos del usuario (por ejemplo, el front end y back end muestran el detalle de una noticia en formatos diferentes, uno en HTML y otro en XML), el código de presentación se incorpora en las vistas.

##Vistas

Las vistas son las responsables de presentar los modelos en el formato que los usuarios finales desean. En general las vistas

- debe contener principalmente código de presentación, tales como HTML, y simple código PL/SQL para procesar, formatear y representar los datos;
- deben evitar contener código que realiza consultas explícitas en la DB. Este código se coloca en los modelos.
- no deben usar `dbax_core.g$get`, `dbax_core.g$post`, u otras variables similares que están directamente vinculados a la solicitud del usuario. Este es el trabajo del controlador. La vista se debe centrar en la pantalla y en el diseño de los datos facilitados por el controlador y/o modelos, pero no intentar acceder a las variables de la petición o al modelo de datos funcional directamente.
- puede acceder a las propiedades(variables, arrays, records...) y métodos (funciones o procedimientos) de los modelos directamente. Sin embargo, esto debe hacerse sólo con el propósito de presentación.

Las vistas pueden ser reutilizados en diferentes formas:

* Layout y Vistas parciales: áreas de presentación comunes (por ejemplo, las cabeceras de página, pie de página) se pueden poner en una vista Layout.
* Widgets: si se necesita una gran cantidad de lógica para presentar una vista parcial, ésta se puede convertir en un widget para contener esta lógica.
* Helpers (Clases de ayuda): a menudo se necesitan algunos fragmentos de código para realizar tareas pequeñas, como la generación de etiquetas HTML. En lugar de colocar el código directamente en las vistas, un mejor enfoque consiste en colocar todos estos fragmentos de código en un Helper. 

## Controlador
Los controladores son el pegamento que une a los modelos, las vistas y otros componentes en una aplicación. Los controladores son responsables de tratar directamente con las peticiones del usuario final. Por lo tanto, los controladores:

- deben usar `dbax_core.g$get`, `dbax_core.g$post` y otras variables que representan las solicitudes de los usuarios;
- invocan a los modelos y gestionan su ciclo de vida. Por ejemplo, en una acción típica de un modelo, una actualización, el controlador invoca al modelo pasando los parámetros que necesita que ha recogido del usuario desde `dbax_core.g$post`; después de que el modelo realiza la actualización, el controlador puede redirigir el navegador del usuario a la página de detalle del modelo. 
- deben evitar contener sentencias SQL de modificacion de datos, esto se realiza en los modelos.
- deben evitar contener código HTML o cualquier otro lenguaje de presentación. Esto se realiza en las vistas.

En una aplicación MVC bien diseñado, los controladores son muy ligeros, contienen unas pocas docenas de líneas de código; mientras que los modelos son muy pesados, ya que contiene la mayor parte del código responsable de procesar y manipular los datos. Esto es porque la estructura de datos y la lógica de negocio que contienen los modelos es específica para una aplicación en particular, y necesitan ser personalizados para satisfacer los requisitos específicos de la misma; mientras que la lógica de los controladores a menudo sigue un patrón similar en todas las aplicaciones.