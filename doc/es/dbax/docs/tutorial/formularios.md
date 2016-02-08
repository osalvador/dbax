<p class="page-header1"><b>Trabajar con Formularios</b></p>

Otra de las características más potentes de DBAX es la forma de gestionar formularios HTML. El concepto básico que es importante entender es que cualquier elemento de un formulario estará disponible automáticamente en sus scripts de DBAX.

####Ejemplo Un formulario HTML sencillo
```html
<form action="${base_path}/mundo" method="post">
 <p>Su nombre: <input type="text" name="nombre" /></p>
 <p>Su edad: <input type="text" name="edad" /></p>
 <p><input type="submit" /></p>
</form>
```

Tan solo tenemos algo especial en este formulario que es la variable `${base_path}`, se trata de una varibale de sustitución sobre código HTML que se define a nivel de propiedad en la aplicación y que referencia a la url base de la aplicación. En el apartado de Ajustes -> Propiedades podrá encontrar más información al respecto.

Por lo demás, este código es solamente un formulario HTML sin ninguna clase de etiqueta especial. Cuando el usuario rellena este formulario y oprime el botón de envío, se llama a la página `${base_path}/mundo`. En esta URL se podría escribir algo así:

####Ejemplo Mostrar información de nuestro formulario

    Hola <?dbax p(dbax_core.g$post('nombre')); ?>.
    Usted tiene <?dbax p(to_number(dbax_core.g$post('edad'))); ?> años.

Un ejemplo del resultado de este script podría ser:

    Hola José. Usted tiene 22 años.

Debería ser obvio qué es lo que hace el código. El campo edad, ya que sabemos que es un número, podemos convertirlo a un valor de tipo `NUMBER`. Las variables `dbax_core.g$post('nombre'))` y `dbax_core.g$post('edad'))` son establecidas automáticamente por DBAX. Anteriormente hemos usado la superglobal `dbax_core.g$server` ahora hemos usado la superglobal `dbax_core.g$post`, la cual contiene todos los datos de POST. Observe que el método de nuestro formulario es POST. 

####Mejorando el código
Si ha intentado ejecutar este código, verá que si accedemos a las variables `dbax_core.g$post('nombre')` y `dbax_core.g$post('edad'))` sin que tengan datos, DBAX nos imprimirá por pantalla el siguiente error: 

```html
DBAX Inline Runtime Error 

SQLERRM

ORA-01403: no data found
ORA-01403: no data found

Before this sentence [BEGIN htp.prn(''); /*Your code star...] (1) 

SQL Statement 

BEGIN htp.prn('<!-- DBAX interpreter -->'); /*Your code starts here*/ p(dbax_core.g$post('nombre')); END;
Error BackTrace 

ORA-06512: at line 1
ORA-06512: at "DBAX.DBAX_CORE", line 922
```

Lo que nos indica que la variable `dbax_core.g$post('nombre')` no tiene contenido. Para solcionar esto sin tener que rescribir demasiado nuestro código, haremos uso de la libreria `dbax_utis` el procedimiento `get`.

       Hola <?dbax p(dbax_utils.get(dbax_core.g$post,'nombre')); ?>.
       Usted tiene <?dbax p(to_number(dbax_utils.get(dbax_core.g$post,'edad'))); ?> años.

`dbax_utils.get` recibe como primer parámetro un array y como segundo parámetro el elemento que queremos recuperar del array. Si el elemento no se ecuentra devuelve NULL. De esta forma, no nos dará error si los valores no existen. 