<p class="page-header1"><b>Enrutado URI</b></p>

El enrutamiento es el proceso que recupera una URI final (o endpoint, que ess la parte de la URI que viene después del `base_path`) y descomponerla en parámetros para determinar qué módulo, controlador y acción del controlador  debe recibir la solicitud.

Tiene sentido que haya una relación de uno a uno entre una cadena de URL y su controlador correspondiente. Los segmentos en una URI normalmente siguen este patrón:

    example.com/dbax/!appid?p=/controlador/id

De todas formas, en DBAX hay que asignar esta relación de manera que una controlador puede ser llamado en lugar de la correspondiente a la URL.

Por ejemplo, digamos que usted quiere que sus URLs tengan este prototipo:

    example.com/dbax/!appid?p=/product/1/
    example.com/dbax/!appid?p=/product/2/
    example.com/dbax/!appid?p=/product/3/
    example.com/dbax/!appid?p=/product/4/

Los dos primeros segmentos de la URI son fijos por cada aplicación y el enrutado de DBAX tendrá en cuenta los segmentos desde `?p=*`. 

##Estableciendo sus reglas de enrutamiento
Las reglas de enrutamiento se definen en la pestaña de `Routing` dentro de las opciones de una aplicación en la consola web de DBAX.

El enrutado se puede especificar utilizando comodines (Wildcards) o expresiones regulares.

####Comodines
Una ruta comodín típico podría ser algo como esto:

| URL Pattern | Controller Method or View |
| -- | -- |
| `product/[[:digit:]]+` | pk_c_dbax_app.product_lookup | 

El *URL Pattern* o Patron de URL contiene la URL que llega desde el usuario (a partir de `?p=`) mientras que en *Controller Method or View* indicamos el desitino que se ha enrutado para esta peticion. 

En el segun ejemplo, si la palabra literal "product" se encuentra en el primer segmento de la URL, y un número se encuentra en el segundo segmento, el controlador "pk_c_dbax_app" el método "product_lookup" serán invocados.

En lugar de `[[:digit:]]+` podriamos haber hecho coincidir un literal concreto o podriamos haber utilizado algun otro tipo de comodín. 

!!! important
    Las rutas se ejecutarán en el orden en que se definen. Las rutas superiores siempre tendrán prioridad sobre los inferiores. La posición se pede alterar desde la pestaña de Routing arrastrando una ruta a un nivel superior. 


!!! note 
    Los comodines son respetan el estandar POSIX que define las expresiones regulares. Se pueden usar estas clases que facilitan algunas tareas como la seleccion de digitos o texto alfabético. La lista de las cases POSIX la puede encontrar en: [http://pubs.opengroup.org/onlinepubs/007908799/xbd/re.html](http://pubs.opengroup.org/onlinepubs/007908799/xbd/re.html)

### Ejemplos
Aquí hay algunos ejemplos de enrutamiento:

| URL Pattern | Controller Method or View |
| -- | -- |
| `journals` | pk_c_dbax_app.blogs | 

Una URL que contengan la palabra `journals` en el primer segmento se reasigna al controlador `pk_c_dbax_app.blogs`.

| URL Pattern | Controller Method or View |
| -- | -- |
| `blog/joe` | pk_c_dbax_app.blogs_by_user/34 | 

Una URL que contiene los segmentos `blog/joe` se asigna al controlador `pk_c_dbax_app.blogs_by_user` pasandole como parámetro el ID del usuario "34".

| URL Pattern | Controller Method or View |
| -- | -- |
| `product/[[:print:]]+` | pk_c_dbax_app.products_lookup |

Una URL con el "product" en el primer segmento, y cualquier cosa en la segunda se asigna al controlador `pk_c_dbax_app.products_lookup`

| URL Pattern | Controller Method or View |
| -- | -- |
| `product/([[:digit:]]+)` | pk_c_dbax_app.products_lookup_by_id/\1 | 

Una URL con el "product" en el primer segmento, y un número en el segundo se asigna a al controlador `pk_c_dbax_app.products_lookup_by_id` al cual se le pasa como parámetro el id de producto que ha coincidido en el patron.


!!! important
    No utilice las barras de inicio ni de fin en `URL Pattern` .

### Expresiones regulares
Como observa, se usan de expresiones regulares para definir las reglas de enrutamiento. Se permite cualquier expresión regular válida. 

!!! note
    DBAX usa la libreria `REGEX_REPLACE` de Oracle para realizar el enrutado. Para mas información [http://docs.oracle.com/cd/B19306_01/server.102/b14200/functions130.htm](http://docs.oracle.com/cd/B19306_01/server.102/b14200/functions130.htm)

Unos ejemplos de expresiones regulares típicos podría ser algo como esto:

| URL Pattern | Controller Method or View |
| -- | -- |
| `products/([a-z]+)/(\d+)` | pk_c_dbax_app.\1/\2 | 


En el ejemplo anterior, un URI como `products/camisas/123` invocaría al controlador `pk_c_dbax_app.camisas` pasandole como parámetro `123`.

Con las expresiones regulares, también se puede coger varios segmentos a la vez. Por ejemplo, si un usuario accede a una zona protegida por contraseña de su aplicación web y desea ser capaz de redirigir de nuevo a la misma página después de que se conecte, puede encontrar este ejemplo útil:

!!! note
    Puede mezclar y combinar los comodines y las expresiones regulares.

