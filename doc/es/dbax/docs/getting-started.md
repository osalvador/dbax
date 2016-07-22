# Empezando

## Instalación

### Requisitos de instalación

- Base de datos Oracle XE o superior. **dbax** es un framework PL/SQL y está escrito al completo en PL/SQL, usted necesita una BD Oracle para poder usar **dbax**. Revise los requisitos de instalación de cada base de datos. 
- Instalar o configurar un Web Listener, quien recibe las peticiones de los usuario y las deriba al motor de **dbax** instalado en la base de datos. **dbax** usa la misma tecnologia que Oracle Apex por tanto los Web Listeners o gateways son los mismos. Puedes leer la documentación de Oracle para elegir e instalar el Web Listener mas adecuado a sus necesidades: [Choosing Web Listener](https://docs.oracle.com/cd/E59726_01/install.50/e39144/overview.htm#HTMIG367)


### Instalando dbax

__dbax__ se compone de un conjunto de paquetes PL/SQL, librerias y una serie de tablas que deben ser creadas y compiladas en un esquema de la Base de datos.

Puede instalar __dbax__ en cualquier esquema existente o en uno nuevo, esto solo depende de como se quiera organizar la BD. Lo recomendable es crear un esquema específico para alojar el motor de __dbax__ y aislar así al framework de los esquemas de su negocio. 

El siguiente script contiene la creación de un nuevo esquema para __dbax__: 

<pre class="prettyprint lang-plsql">
CREATE TABLESPACE TS_DBAX DATAFILE 'dbax.dat' size 10M autoextend on;
CREATE TEMPORARY TABLESPACE TS_DBAX_TEMP tempfile 'dbax_temp.dat' size 5M autoextend on;

CREATE USER dbax IDENTIFIED BY password DEFAULT TABLESPACE TS_DBAX
   TEMPORARY TABLESPACE TS_DBAX_TEMP ACCOUNT UNLOCK  PROFILE DEFAULT;

GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO dbax;
GRANT EXECUTE ON DBMS_CRYPTO TO dbax;  
GRANT CREATE TYPE TO dbax;
GRANT EXECUTE ON UTL_FILE TO dbax;
GRANT CREATE PUBLIC SYNONYM, DROP PUBLIC SYNONYM TO dbax;    
ALTER USER dbax QUOTA UNLIMITED ON TS_DBAX;
ALTER USER dbax account unlock;
</pre>

Para instalar __dbax__ en la BD debemos seguir los siguientes pasos.

<pre class="prettyprint">
#dbax framework installation
unzip master.zip
cd dbax/source/install
sqlplus "user/userpass"@SID @dbax_install.sql
</pre>

Una vez todos los paquetes, librerias, procedimientos y objetos han sido compilados en la Base de datos, es necesario importar los datos de configuración para que la consola de __dbax__ funcione.

<pre class="prettyprint">
#Iport Metadata
cd dbax/source/install
imp "user/userpass"@SID file=dbax.dmp data_only=y
</pre>

## Uso

Una vez instalado podrá crear su primera aplicacion:

__dbax Hello world con Bootstrap__ :

<div class="embed-container">
        <iframe width="640" height="480" src="https://www.youtube.com/embed/SqZoL9mN-a0?rel=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>
</div>


