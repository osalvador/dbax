<p class="page-header1"><b>Objetivos de Arquitectura</b></p>

!!! warning
    Documento sin finalizar. No lo tenga en cuenta todavía 

El objetivo con la arquitectura de DBAX es obtener el máximo rendimiento, capacidad y la flexibilidad en el paquete más ligero posible.

Para cumplir con este objetivo estamos comprometidos con la evaluación comparativa, re-factorización y simplificación en cada paso del proceso de desarrollo, rechazando cualquier cosa que no cumpla el objetivo establecido.

Desde un punto de vista técnico y arquitectónico, DBAX ha sido creado con los siguientes objetivos:

- La instanciación dinámica. En DBAX, los componentes se cargan y ejecutan las rutinas sólo cuando se solicita, en lugar de a nivel mundial. No se hacen suposiciones por el sistema en cuanto a lo que puede ser necesaria más allá de los recursos básicos mínimos, por lo que el sistema es muy ligero por defecto. Los eventos, que se activa por la petición HTTP, y los controladores y vistas que diseñe determinarán lo que se invoca.
- El acoplamiento flexible. El acoplamiento es el grado en que los componentes de un sistema dependen unos de otros. Los menos componentes dependen unos de otros más reutilizable y flexible el sistema se vuelve. Nuestro objetivo era un sistema muy imprecisa.
- Componente Singularidad. La singularidad es el grado en que los componentes tienen un propósito estrechamente enfocado. En DBAX, cada clase y sus funciones son muy autónomos con el fin de permitir la máxima utilidad.
DBAX es un sistema dinámicamente una instancia, débilmente acoplado con un alto componente de singularidad. Se esfuerza por simplicidad, flexibilidad y alto rendimiento en un paquete pequeño huella.

