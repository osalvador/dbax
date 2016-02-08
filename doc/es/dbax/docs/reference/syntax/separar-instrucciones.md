<p class="page-header1"><b>Separación de instrucciones</b></p>

Como el lenguaje entre las etiquetas de DABX es PL/SQL, se requiere que las instrucciones terminen en punto y coma al final de cada sentencia. La etiqueta de cierre de un bloque de código de DBAX automáticamente implica un punto y coma. La etiqueta de cierre del bloque incluirá la nueva línea final inmediata si está presente.

```php
<?dbax
p('Esto es una prueba');
?>

<?dbax p('Esto es otra prueba'); ?>
```

Este código dará como resultado: 

  
    Esto es una prueba

    Esto es otra prueba