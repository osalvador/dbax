<p class="page-header1"><b>Etiquetas de DBAX</b></p>

Cuando DBAX analiza una vista, busca las etiquetas de apertura y cierre, que son `<?dbax` y `?>`, y que indican a DBAX dónde empezar y finalizar la interpretación del código. Recordar que el código interpretado es código PL/SQL que se ejecuta dinámicamente. Este mecanismo permite embeber código PL/SQL en todo tipo de documentos, ya que todo lo que esté fuera de las etiquetas de apertura y cierre de DBAX será ignorado por el analizador.

Recordar que las vistas de DBAX están pensadas para solo contener código de presentación y lógica solo relacionada con ésta. 

Recuerde que siempre debe existir la etiqueta de cierre aunque ésta sea la ultima instrucción:
```php
<?dabx
p('Hola mundo');

/*... más código*/

p('Última sentencia');

?>
```


Actualmente se está trabajando en un nuevo motor de plantillas, el cual ofrece mayor rendimento, una sintaxis más clara y es menos *vervoso*, además la sintaxis actual será compatible. Incluso si ya tienes conocimiento en Oracle PSP no tendrás que aprender ninguna sintaxis nueva ya que será compatible.

Puedes ver la evolución de este nuevo proyecto en GitHub: [tePLSQL](https://github.com/osalvador/tePLSQL)