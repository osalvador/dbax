<p class="page-header1"><b>¿Qué necesito?</b></p>

En este manual se asume que usted ya tiene instalado DBAX en algun entorno descrito en el apartado de instalación. 

Para desarrollar aplicaciones DBAX realmente solo necesita un navegador web,  un editor de texto y accceso SQL a su base de datos Oracle. Pero para trabajar con agilidad y soltura se recomienda que instale las siguientes herramientas: 

####SQL Developer
Se trata de la herramienta oficial y gratuita de Oracle para el desarrollo en PL/SQL y gestión de Bases de datos Oracle. Con ella podremos acceder a la BD para compilar y desplegar nuestros controladores y modelos. 

Existen otras herramientas muy conocidas y potentes por los desarrolladores Oracle, Toad for Oracle, por ejemplo, pero que tienen un coste de licenciamiento. 

[Descarga SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html)

####Sublime Text
Como ellos mismos indican 

>The text editor you'll fall in love with. 
Sublime Text is a sophisticated text editor for code, markup and prose.
You'll love the slick user interface, extraordinary features and amazing performance.

Se trata de un editor de texto y editor de código fuente multi lenguaje gratuito, con un rendmiento excepcional y con una base de plugins muy amplia que extiende sus funcionalidades enormemente. Estas documentación está escrita con este editor. 

[Descarga Sublime Text 3](https://www.sublimetext.com/3)

## Tutorial Aplicación Básica de Noticias

Este tutorial tiene como objetivo  presentarle el framework DBAX y los principios básicos de la arquitectura MVC. Se le mostrará cómo se construye una aplicación básica DBAX paso a paso. 

En este tutorial, va a crear una aplicación de noticias básicas. Comenzaremos escribiendo el código para cargar páginas estáticas. A continuación, se creará una sección de noticias que extrae las noticias desde una tabla de la base de datos. Por último, se le agrega un formulario para crear nuevos artículos.

#### Este tutorial se centrará principalmente en:

- Fundamentos Modelo-Vista-Controlador
- Principios básicos de enrutamiento
- Validación de datos formularios
- Recuperar datos de una tabla y mostrarlos al usuario

Todo el tutorial se divide en varias páginas, cada una de explicar una pequeña parte de la funcionalidad del framework de DBAX.
