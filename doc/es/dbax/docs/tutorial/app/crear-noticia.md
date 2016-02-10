<p class="page-header1"><b>Crear una Noticia</b></p>

You now know how you can read data from a database using CodeIgniter, but you haven’t written any information to the database yet. In this section you’ll expand your news controller and model created earlier to include this functionality.

##Create a form
To input data into the database you need to create a form where you can input the information to be stored. This means you’ll be needing a form with two fields, one for the title and one for the text. You’ll derive the slug from our title in the model. Create the new view at application/views/news/create.php.

```php
    <h2>${title}</h2>

    <form action="${base_path}/noticias/insertar" method="post">    

        <label for="titulo">Titulo</label>
        <input type="input" name="titulo" /><br />

        <label for="texto">Texto</label>
        <textarea name="texto"></textarea><br />

        <input type="submit" name="submit" value="Crear nueva noticia" />

    </form>    
```


Go back to your news controller. You’re going to do two things here, check whether the form was submitted and whether the submitted data passed the validation rules. You’ll use the form validation library to do this.

```plsql
  PROCEDURE insertar
  AS
    l_news_rt    tapi_news.news_rt;    
  BEGIN
    /*Recuperamos los datos que vienen por post*/
    l_news_rt.title := dbax_utils.get (dbax_core.g$post, 'titulo');
    l_news_rt.text := dbax_utils.get (dbax_core.g$post, 'texto');

    /*Incrementamos el ID. Lo normal seria con una secuencia
      o en caso contrario en el modelo
    */
    select max(id)+1 into l_news_rt.id from news;
     
    /*Insertamos el registro en la tabla*/
    BEGIN
        tapi_news.ins (p_news_rec => l_news_rt);
    EXCEPTION
      WHEN OTHERS
      THEN
          dbax_log.error(SQLERRM || ' ' || DBMS_UTILITY.format_error_backtrace () );
          dbax_core.load_view('noticiaCrear');
          RETURN;
    END;

    dbax_core.load_view('noticiaCorrecta');
  END;  
```


The code above adds a lot of functionality. The first few lines load the form helper and the form validation library. After that, rules for the form validation are set. The set_rules() method takes three arguments; the name of the input field, the name to be used in error messages, and the rule. In this case the title and text fields are required.

CodeIgniter has a powerful form validation library as demonstrated above. You can read more about this library here.

Continuing down, you can see a condition that checks whether the form validation ran successfully. If it did not, the form is displayed, if it was submitted and passed all the rules, the model is called. After this, a view is loaded to display a success message. Create a view at application/views/news/success.php and write a success message.

##Model
The only thing that remains is writing a method that writes the data to the database. You’ll use the Query Builder class to insert the information and use the input library to get the posted data. Open up the model created earlier and add the following:


This new method takes care of inserting the news item into the database. The third line contains a new function, url_title(). This function - provided by the URL helper - strips down the string you pass it, replacing all spaces by dashes (-) and makes sure everything is in lowercase characters. This leaves you with a nice slug, perfect for creating URIs.

Let’s continue with preparing the record that is going to be inserted later, inside the $data array. Each element corresponds with a column in the database table created earlier. You might notice a new method here, namely the post() method from the input library. This method makes sure the data is sanitized, protecting you from nasty attacks from others. The input library is loaded by default. At last, you insert our $data array into our database.

##Routing
Before you can start adding news items into your CodeIgniter application you have to add an extra rule to config/routes.php file. Make sure your file contains the following. This makes sure CodeIgniter sees ‘create’ as a method instead of a news item’s slug.

    noticiaCrear       pk_c_dbax_noticias.crear 
    noticiaInsertar    pk_c_dbax_noticias.insertar
    noticiaCorrecta    pk_c_dbax_noticias.correcta


Now point your browser to your local development environment where you installed CodeIgniter and add index.php/news/create to the URL. Congratulations, you just created your first CodeIgniter application! Add some news and check out the different pages you made.