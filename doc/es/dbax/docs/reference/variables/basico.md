<p class="page-header1"><b>Conceptos Básicos</b></p>

En DBAX las variables tienen la misma sintaxis y criterios que en PL/SQL, puede leer la [documentación de Oracle](https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/overview.htm#sthref121) para mas información. El nombre de la variable **NO** es sensible a minúsculas y mayúsculas.

Los nombres de variables siguen las mismas reglas PL/SQL.Un nombre de variable válido tiene que empezar con una letra, seguido de cualquier número de letras, números y caracteres de subrayado. Además el nombre de una variable como máximo puede ser de 30 caracteres.

!!! note
    Nota: Para los propósitos de este manual, una letra es a-z, A-Z, y los bytes del 127 al 255 (0x7f-0xff).

!!! tip
    Para más información sobre convención de nombres en Oracle vea [Database Object Names and Qualifiers](http://docs.oracle.com/cd/E11882_01/server.112/e41084/sql_elements008.htm)

```php
<?dbax
  DECLARE
    var1 VARCAHR2(20)  := 'Roberto';
    var2 VARCAHR2(20)  := 'Juan';
    --
    4site VARCAHR2(20) := 'aun no';   /* inválido; comienza con un número*/
    _4site VARCAHR2(20) := 'aun no';  /* inválido; comienza con un carácter de subrayado*/
    site4$ VARCAHR2(20) := 'ahora si'; /* válido; comienza por una letra*/
    
    täyte VARCAHR2(20) := 'mansikka'; /* válido; 'ä' es ASCII (Extendido) 228*/
  BEGIN
    p(var1 || ' , '|| var2);  /*imprime "Roberto, Juan"*/
  END;
?>
```

De forma predeterminada, las variables siempre se asignan por valor. Esto significa que cuando se asigna una expresión a una variable, el valor completo de la expresión original se copia en la variable de destino. Esto quiere decir que, por ejemplo, después de asignar el valor de una variable a otra, los cambios que se efectúen a una de esas variables no afectará a la otra. 

No es necesario inicializar variables en PL/SQL, sin embargo, es una muy buena práctica. Las variables no inicializadas tienen un valor predeterminado de acuerdo a su tipo dependiendo del contexto en el que son usadas - las booleanas se asumen como FALSE, los enteros y flotantes se establecen vacíos, las cadenas o strings se establecen como una cadena vacía y los arrays se convierten en un array vacío.

####Ejemplo Valores predeterminados en variables sin inicializar

```php
<?dbax
/* Una variable no definida (sin contexto de uso); dará un error en tiempo de ejecución */
p(variable_indefinida);

/* Uso booleano; imprime 'false'*/
DECLARE
  booleano BOOLEAN;
BEGIN
  IF booleano THEN
    p('true');
  ELSE
    p('false');
  END IF;
END;

/* Uso de una cadena; imprime 'string(3) "abc"' */
DECLARE
  cadena_indefinida VARCHAR2(10);
BEGIN
  cadena_indefinida := 'abc';
  p(cadena_indefinida);
END;

/* Uso de un entero; imprime null */
DECLARE
  int_indefinido number(10);
BEGIN
  int_indefinido := int_indefinido + 25;
  p(int_indefinido);
END;

/*En cambio si lo inicializamos, nos imprimirá 25*/
DECLARE
  int_indefinido number(10):= 0;
BEGIN
  int_indefinido := int_indefinido + 25;
  p(int_indefinido);
END;

?>
```

Depender del valor predeterminado de una variable sin inicializar es problemático ya que podemos obtener resultados no deseados.
