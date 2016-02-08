<p class="page-header1"><b>Su primera página</b></p>

Como se ha comentado, lo primero que debe hacer es crear una aplicación desde la consola Web de DBAX. De momento y de cara a este tutorial vamos a mostrar directamente el código que deberemos escribir en nuestro primero *Hola Mundo*: 

###Nuestro primer hola.dbax

```html
<html>
 <head>
  <title>Prueba de DBAX</title>
 </head>
 <body>
 <?dbax p('<p>Hola Mundo</p>'); ?>
 </body>
</html>
```

Desde el navegador prodremos acceder a la vista que hemos creado desde una URL similar a la siguiente: `/dbax/hola/mundo` 

Donde: 
- `/dbax` es el nombre que le hemos asignado al Database Access Descriptor en la instalación del Gateway.
- `/hola` es el nombre de la aplicación que hemos creado para este ejemplo.
- `/mundo` es el nombre de la vista que acabamos de crear. 

Si todo está configurado correctamente, la vista será analizado por el interprete de vistas de DBAX y se enviará el siguiente contenido a su navegador:

```html
<html>
 <head>
  <title>Prueba de PHP</title>
 </head>
 <body>
 <p>Hola mundo</p>
 </body>
</html>
```

Este ejemplo es extremadamente simple y realmente no es necesario utilizar la sintaxis de DBAX para crear una página como esta. Lo único que muestra es: *Hola mundo* empleando la sentencia `p` de DABX. 

El objetivo de este ejemplo es mostrar el formato de las etiquetas especiales de DBAX. En este ejemplo utilizamos `<?dbax` para indicar el inicio de una etiqueta de DBAX. Después ponemos la sentencia y abandonamos el modo DBAX añadiendo la etiqueta de cierre `?>`. De esta manera, se puede entrar y salir del modo DBAX en un fichero HTML cada vez que se quiera.

Entre las etiquetas `<?dbax` y `?>` debemos incluir nuestras sentencias PL/SQL. DBAX no incluye un nuevo lenguaje de programacióno, sino que utiliza PL/SQL como lenguaje de programación. Por tanto entre las etiquetas `<?dbax` y `?>` el codigo introducido será ejecutado como un bloque anónimo de PL/SQL. 

Por lo tanto esta instrucción: 

`<?dbax p('<p>Hola Mundo</p>'); ?>`

Será traducida en el siguiente código PL/SQL: 
```plsql
DECLARE
BEGIN
    p('<p>Hola Mundo</p>');
END;
```

La instrucción `P` es el alias creado en DBAX sobre la instrucción `HTP.P` que se trata de un procedimiento que imprime el string pasado por parámetro al buffer de salida HTTP . El objetivo de este alias es acortar la sintaxis para disminuir el código que debemos escribir.