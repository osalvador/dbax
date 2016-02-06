<p class="page-header1"><b>Instrucciones de Instalación</b></p>

[TOC]

##Recursos DBAX

Recordar que, independientemente de Gateway elegido, los recuersos (resources) de DBAX se deben siempre alojar en un servidor web. Estos recursos contienen JavaScript, CSS, Fuentes e imágenes principalmente y se usan para dar servicio a la Consola de DBAX y a sus plantillas. 

En DBAX no nos ha parecido buena idea que los recursos los sirva también la BD ya que incrementa enormemente el numero de peticiones que se realiza a la misma, pero tampoco nos gusta tener que instalar demasiado software en nuestros equipos para poder empezar a desarrollar. 

Por todo ello, DBAX proporciona un sitio público en internet donde cualquiera puede enlazar sus recursos y no tener así que almacenarlos internamente, si así no se quisiera: [resources.haciendoti.com](resources.haciendoti.com)

##Esquema de BD para DBAX
DBAX son un conjunto de paquetes PL/SQL, librerias y una serie de tablas que deben ser creados y compilados en un esquema de la Base de datos.

Puede instalar DBAX en cualquier esquema que lo desee, incluso podria usar el mismo esquema de BD para almacenar DABX y todas sus aplicaciones creadas con DABX, esto solo depende de como se quiera organizar la BD. 

Lo recomendable es crear un esquema específico para alojar el motor de DBAX y aislar así al framework de los esquemas de su negocio. 

El siguiente script contiene la creación de un nuevo esquema para DBAX: 

```plsql
CREATE TABLESPACE TS_DBAX DATAFILE 'dbax.dat' size 10M autoextend on;

CREATE TEMPORARY TABLESPACE TS_DBAX_TEMP tempfile 'dbax_temp.dat' size 5M autoextend on;

CREATE USER dbax IDENTIFIED BY password DEFAULT TABLESPACE TS_DBAX
   TEMPORARY TABLESPACE TS_DBAX_TEMP ACCOUNT UNLOCK  PROFILE DEFAULT;
   
  GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE,
  CREATE SEQUENCE TO dbax;
  
  GRANT Execute on DBMS_CRYPTO to dbax;
  
  GRANT CREATE TYPE TO dbax;

  grant create public synonym, drop public synonym to dbax;
  
  
  ALTER USER dbax QUOTA UNLIMITED ON TS_DBAX;

  ALTER USER dbax account unlock;
```

##Gateway DBAX
Lo primero será seleccionar un gateway para para DBAX. En apartado de Arquitectura se explica cada uno de los gateways que se pueden elegir y sus recomendaciones de uso en función del entorno (desarrollo o producción).

### Entornos de producción
Para un entorno de producción se recomienda el uso de Oracle REST Data Services o de Oracle HTTP Server. 

####Configurar ORDS para DBAX

!!! note
    Hasta completar este manual revise la documentación de Oracle para instalar este producto. 
    [REST Data Services Installation, Configuration, and Development Guide](http://docs.oracle.com/cd/E56351_01/doc.30/e56293/install.htm)

####Configurar OHS para DABX

!!! note
    Hasta completar este manual revise la documentación de Oracle para instalar este producto. 
    [Installing Oracle HTTP Server 11g](https://docs.oracle.com/cd/E29542_01/doc.1111/e29751/install_ora_httpserver.htm)
    Tras instalar el servidor deberá configurarlo: 
    [Understanding Oracle HTTP Server Modules - mod_plsql](https://docs.oracle.com/cd/E15523_01/web.1111/e10144/under_mods.htm#HSADM003)

### Entorno de desarollo
Para un entorno de desarrollo no es requisito instalar ORDS por lo que puede configurar la propia Base de Datos para que actue como servidor web con el Embedded PL/SQL Gateway.

#### Configurar Embedded PL/SQL Gateway (DBMS_EPG)

Ejecutar el siguiente script con privilegios de SYS.

```plsql

BEGIN
   DBMS_EPG.drop_dad ('DBAX');
END;

BEGIN
   DBMS_EPG.create_dad (dad_name => 'DBAX', PATH => '/dbax/*');
END;

BEGIN

   DBMS_EPG.set_dad_attribute (dad_name     => 'DBAX',
                               attr_name    => 'default-page',
                               attr_value   => 'console');

   DBMS_EPG.set_dad_attribute (dad_name     => 'DBAX',
                               attr_name    => 'error-style',
                               attr_value   => 'DebugStyle');

   DBMS_EPG.set_dad_attribute (dad_name     => 'DBAX',
                               attr_name    => 'database-username',
                               attr_value   => 'DBAX');
   
   DBMS_EPG.set_dad_attribute (dad_name     => 'DBAX',
                               attr_name    => 'request-validation-function',
                               attr_value   => 'dbax.dbax_core.request_validation_function');
   
   DBMS_EPG.set_dad_attribute (dad_name     => 'DBAX',
                               attr_name    => 'session-state-management',
                               attr_value   => 'StatelessWithFastResetPackageState');                               

   DBMS_EPG.set_dad_attribute( dad_name   => 'DBAX',
                               attr_name  => 'document-table-name',
                               attr_value => 'wdx_documents' );
END;

BEGIN
   DBMS_EPG.authorize_dad (dad_name => 'DBAX', USER => 'DBAX');   
END;

```

!!! warning
    Este script asume que el usaurio DBAX existe en la BD. Si usted ha creado otro usuario con diferente nombre modifique los parámetros que hacen referencia al usario DBAX.

!!! note
    Para mas información dirígase a la documentación de Oracle
    [DBMS_EPG](https://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_epg.htm)

##Instalación DBAX

Para instalar DBAX en la BD debemos seguir los siguientes pasos.

```bash
    unzip master.zip
    cd dbax/source/install
    sqlplus "user/userpass"@SID @dbax_install.sql
```

Una vez todos los paquetes, librerias, procedimientos y objetos han sido compilados en la Base de datos, es necesario importar los datos de configuración para que la consola de DBAX funcione.

```bash
    cd dbax/source/install
    imp "user/userpass"@SID file=dbax.dmp data_only=y
```
