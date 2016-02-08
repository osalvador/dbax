<p class="page-header1"><b>Comentarios</b></p>

DBAX admite comentarios al estilo de PL/SQL. Por ejemplo:

```sql
<?dbax
    p('Esto es una prueba'); --Esto es un comentario al estilo de c++ de una sola línea
    /* Esto es un comentario multilínea
       y otra lína de comentarios */
    p('Esto es otra prueba');
    p('Una prueba final'); /*Esto es un comentario de una sola línea*/
?>
```


Los comentarios al estilo de "una sola línea" solo comentan hasta el final de la línea o del bloque actual de código PL/SQL, lo primero que suceda. Esto implica que el código HTML después de `-- ... ?>` SERÁ impreso: `?>` sale del modo DBAX y vuelve al modo HTML, por lo que `--` no pueden influir en eso. 

```php
    <h1>Esto es un <?dabx --p('simple');?> ejemplo</h1>
    <p>El encabezado anterior dirá 'Esto es un  ejemplo'.</p>
```

Los comentarios al estilo de 'C' finalizan con el primer */ que se encuentre. Asegúrese de no anidar comentarios al estilo de 'C'. Es muy fácil cometer este error cuando se intenta comentar un bloque grande de código.

```php
<?dbax
 /*
    echo 'Esto es una prueba'; /* Este comentario causará un problema*/
 */
?>
```