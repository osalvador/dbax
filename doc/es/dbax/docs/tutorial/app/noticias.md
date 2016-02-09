<p class="page-header1"><b>Seccion de noticias</b></p>

##Creación del su modelo
En lugar de escribir las operaciones de base de datos correcta en el controlador, las consultas deben ser colocados en un modelo, para que puedan ser fácilmente reutilizados más tarde. Los modelos son el lugar en el que recuperar, insertar y actualizar la información en su base de datos u otros almacenes de datos. Representan sus datos.

Lo primero que haremos será crear la tabla de noticias que contendrá nuestras noticias: 

```sql
CREATE TABLE news
  (
    id    NUMBER(11) NOT NULL,
    title VARCHAR(128) NOT NULL,
    text CLOB NOT NULL
  );

CREATE UNIQUE INDEX news_PK ON news
  (
    id
  );
ALTER TABLE news ADD ( CONSTRAINT news_PK PRIMARY KEY (id));
```


Ahora podremos crear un modelo por ejemplo, haciendo uso de `tapiGen2`
```sql
EXEC tapi_gen2.create_tapi_package (p_table_name => 'news', p_compile_table_api => TRUE);
```


##Mostrar las noticias
Ahora que que tenemos el modelo creado, donde se consulta la tabla de noticias, debemos vincular su contenido y enviarlo a las vistas. Lo que haremos será crear un nuevo procedimiento en nuestro controlador. 


Crearemos un controlador que cargue la vista para mostrar las noticias. 


Dentro de la vista, haremos referencia a nuestro controlador pintando una tabla para ello

```html
<table class="datatable table table-striped table-bordered">
   <thead>
      <tr>
         <th>ID Noticia</th>
         <th>Titulo</th>
         <th>Texto</th>
      </tr>
   </thead>
   <tbody>
      <?dbax
         FOR c1 IN (select * from table (tapi_news.tt()))
         LOOP                                            
           p('<tr>');                                     
                p('<td>'|| c1.id ||'</td>');
                p('<td>'|| c1.title ||'</td>');
                p('<td>'|| c1.text ||'</td>');
            p('</tr>');                      
         END LOOP;
         ?>
   </tbody>
</table>
```