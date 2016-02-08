<p class="page-header1"><b>Ambito Variables</b></p>

El ámbito de una variable es el contexto dentro del que la variable está definida. La mayor parte de las variables DBAX sólo tienen un ámbito simple. 

```plsql
<?dbax
DECLARE
    a varchar2(2) := 'a';
BEGIN
    p(a);
END;
?>
```

La variable `a` solo se podrá usar en este bloque DBAX.

Si concatenamos varias instrucciones DBAX, las variables seguirán teniendo un ámbito simple, o local.

```plsql
<?dbax
DECLARE
    a varchar2(2) := 'a';
BEGIN
    p(a);
END; ?>

<?dbax
DECLARE
    a varchar2(2) := 'b';
BEGIN
    p(a);
END;
?>
```

Este código es correcto, e imprimirá `ab` por pantalla. 

en cambio si lo que queremos es compartir una variable a lo largo de toda una vista de DBAX y en todas sus instrucciones, debemos usar el array global `dbax_core.g$view`


```plsql
<?dbax
    dbax_core.g$view('user_name') := 'Oscar'; 
?>

... some HTML code ...

<p>Hello <?dbax p(dbax_core.g$view('a')); ?> </p>

```

El uso de las variables `dbax_core.g$view` es muy util para obtener un contexto global en todas las vistas incluidas. 

......