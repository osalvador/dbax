<p class="page-header1"><b>DBAX URLs</b></p>

De forma predeterminada, las direcciones URL en DBAX están diseñadas para ser como un "*motor de búsqueda*" y "*user friendly*". En lugar de utilizar el método estándar "query string" para URLs que es sinónimo de sistemas dinámicos, DBAX usa un enfoque basado en segmentos:

    example.com/news/article/my_article

!!! note
    Los parámetros por query string pueden ser habilitados pero dependiendo del Gateway que estemos usando

###Segmentos URI

Los segmentos en la URL, con el enfoque del MVC, por lo general representan:

    example.com/dbax/controller/ID

1. El primer segmento representa el Database Access Descriptor en la instalación del Gateway. 
2. El segundo segmento representa el controlador, o método, que debe ser llamado.
3. La tercera, y cualquiera de los segmentos adicionales, representan el ID y cualquier variable que serán pasados ​​al controlador como parámetros.

###Extracción del `?p=` en la URL

De manera predeterminada, las URLs en DABX incluyen el siguiente parámetro: `?p=`, esto indica a DBAX cual es la URL que debe tener en cuenta a la hora en erutar: 

    example.com/dbax/news?p=/article/my_article

Si usas un servidor web Apache como listener web y servidores de recueros, y éste tiene el módulo mod_rewrite activado, puede limpiar facilmente la URL con algunas reglas simples. He aquí un ejemplo de configuración, utilizando el método de "negativo" en el que todo se redirige a excepción de los elementos que se especifican:

    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ dbax/news/$1 [L]

!!! warning
    De momento no haga demasiado caso a lo que se comenta sobre reescribirlas urls.





