<p class="page-header1"><b>Algo útil</b></p>

Hagamos ahora algo que puede ser más útil. Vamos a comprobar qué tipo de navegador está utilizando el usuario visitante. Para hacerlo, vamos a comprobar el string del agente de usuario que el navegador envía como parte de la petición HTTP. Esta información es almacenada en una variable. En DBAX, las variables siempre comienzan por `g$` y están contenidas en algún paquete de referencia. La variable que nos interesa ahora es `dbax_core.g$server('HTTP_USER_AGENT')`.

!!! note 
    `dbax_core.g$server` es una variable especial reservada por DBAX que contiene toda la información del servidor web. Es conocida como una variable Superglobal. Consulte la página del manual sobre *variable predefinidas* para más información.

####Ejemplo Imprimir una variable (elemento de array)

    <?dbax p(dbax_core.g$server('HTTP_USER_AGENT')); ?>

Un jemplo del resultado de este script podría ser:

    Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0 

Hay muchos tipos de variables en DBAX. En el ejemplo anterior se muestra un elemento de un Array. Los arrays pueden ser muy útiles.

`dbax_core.g$server` es simplemente una variable que se encuentra disponible automáticamente en DBAX. Se puede encontrar una lista en la sección Variables reservadas del manual.

Puede usar múltiples sentencias dentro de una etiqueta de DBAX y crear pequeños bloques de código que realicen más que un simple `P`. Por ejemplo, si se quisiera detectar el uso de Internet Explorer, se podría hacer algo así:

####Ejemplo usando estructuras de control y funciones

```php
<?dbax
  if instr(dbax_core.g$server('HTTP_USER_AGENT'), 'MSIE') <> 0 
      OR instr(dbax_core.g$server('HTTP_USER_AGENT'), 'WOW64') <> 0
  then
      p( 'Está usando Internet Explorer.<br />');
  else
      p( 'Está usando un navegador diferente a Internet Explorer.<br />');
  end if;
?>
```

Un ejemplo del resultado de este script sería:

    Está usando Internet Explorer.<br />

Aquí hemos introducido un par de conceptos nuevos. Tenemos una sentencia `if`. Si está familiarizado con la sintaxis básica del lenguaje PL/SQL, debería parecerle lógico. De lo contrario, probablemente debería conseguir un libro que le introduzca a PL/SQL, y leer el primer par de capítulos. 

El segundo concepto que introducimos fue la función llamada a `instr()`. `instr()` es una función integrada en PL/SQL que busca un string dentro de otro. En este caso estamos buscando 'MSIE' o 'WOW64' (llamado aguja) dentro de `dbax_core.g$serever('HTTP_USER_AGENT')` (también llamado pajar). Si el string se encuentra dentro del pajar, la función devuelve la posición de la aguja relativa al inicio del pajar. De lo contrario, devuelve 0. 

