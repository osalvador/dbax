<p class="page-header1"><b>Conceptos de las Aplicaciones DBAX</b></p>

##¿Que es una aplicación DBAX?
El objetivo final del framework DABX es crear aplicaciones Web. Por tanto, a diferencia de otros lenguajes web o frameworks, cualquier cosa que usted desarrolle estará bao el paraguas de una aplicación. Incluso si tan solo quiere realizar un *hola mundo*, éste pertenecerá a una aplicación. 

Crear una aplicación desde la consola Web de DBAX, será lo primero que deba hacer en su fase de desarrollo. 

## Como se distribuyen las aplicaciones en una instalación de DBAX

En una instalación de DBAX, que como hemos visto se instala en un esquema de base de datos, existe una única consola web desde donde se crear todas las aplicaicones.

![Single tenancy](DBAX_single_Tenancy.png)

Por tanto, dependiendo de su entorno, usted puede instalar una única vez DBAX y utilizar esta única instalación para todos sus desarrollos, o en cambio si necesita diferenciar instalaciones, por ejemplo si tiene diferentes equipos desarrollando aplicaciones en la misma base de datos, o quiere separar el acceso a las aplicaciones por seguridad, puede realizar varias instalaciones de DBAX en la base de datos. 


![Single tenancy](DBAX_multi_tenancy.png)