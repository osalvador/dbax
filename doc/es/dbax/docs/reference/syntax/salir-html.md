<p class="page-header1"><b>Salir de HTML</b></p>

Cualquier cosa fuera de un par de etiquetas de apertura y cierre es ignorado por el intérprete de DBAX, lo que permite que las vistas tengan contenido mixto. Esto hace que DBAX pueda ser embebido en documentos HTML para, por ejemplo, crear plantillas.

```php
<p>Esto va a ser ignorado por DBAX y mostrado por el navegador.</p>
<?dbax p('Mientras que esto va a ser interpretado.'); ?>
<p>Esto también será ignorado por DBAX y mostrado por el navegador.</p>
```

Este ejemplo funciona como estaba previsto, porque cuando DBAX intercepta las etiquetas de cierre ?>, simplemente comienza a imprimir cualquier cosa que encuentre (a excepción de un una nueva línea inmediatamente después; véase la separación de instrucciones) hasta que dé con otra etiqueta de apertura. 

Para imprimir código HTML de forma condicional, actualmente DBAX no permite salir de HTML dentro de una estructura condicional, por tanto debemos hacerlo centro de sus etiquetas:

####Ejemplo Salida  usando condiciones

```php
<?dbax 
    if (expresión = true)
    then
        p('Esto se mostrará si la expresión es verdadera.');
    else
        p('En caso contrario se mostrará esto.');
    end if;
?>
```

Recuerde que para imprimir bloques de texto grandes, es más eficiente abandonar el modo intérprete de DBAX que enviar todo el texto a través de print.

