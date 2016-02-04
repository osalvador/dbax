<p class="page-header1"><b>DBAX Manual de usuario</b></p>

**Contenidos:**

[TOC]

##Bienvenido a DBAX
- [Bienvenido](welcome.md)

## Introducción a DABX
- [Empezando](intro/empezando.md)
- DBAX a simple vista
- Funciones soportadas
- Diagrama de flujo de las aplicaciones DBAX
- Model-Vista-Controlador
- Objetivos de arquitectura

## Instrucciones de instalación
- Descargar DBAX
- Instrucciones de instalación
<!--- Atualizar desde una versión anterior-->
- Solucionar problemas

## Tutorial Sencillo
- ¿Qué necesito?
- Su primera página con DBAX
- Algo útil
- Tratar con formularios
- Aplicación báscica de Noticias
    + Páginas estáticas
    + Sección noticias
    + Crer una noticia
    + Conslusión

## Consola Web DBAX
- Aplicaciones
    - Crear una nueva aplicación
    - Ajustes
        + Ajustes generales (Settings)
        + Propiedades (Properties)
        + Enrutado (Routing)
        + Vistas (Views)
        + Función de Validación de petición (Request Validation Function)
        + Seguridad (Security)
            * Roles (Roles)
            * Permisos (Permissions)
- Seguridad
    + Usuarios (Users)
    + Esquemas de autenticación (Auth Schemes)
- Monitorización
    + Logs

## Temas Generales
- DBAX URLs
- Controladores
- Vistas
- Modelos
- Enrutado URI
- Gestíón de excepciones
<!-- - Caching -->
- Seguridad

## Referencias del lenguaje
- Sintaxis básica
    - Etiquetas de DBAX
    - Salir de HTML
    - Separación de instrucciones
    - Comentarios
- Variables
    - Conceptos básicos
    - Variables Predefinidas
    - Ámbito de las variables
    - Variables variables
    - Variables desde fuentes externas
- Variables predefinidas
    + dbax_core 
        * g$server — Información del entorno del servidor y de ejecución
        * g$get — Variables HTTP GET
        * g$post — Variables POST de HTTP
        * g$view 
        * g$http_header
        * g$status_line
        * g$controller
        * g$view_name
        *  g$parameter 
        * g$path 
        * g$appid 
        * g$h_view 
        * g$content_type
        * g$username        
        * g_stop_process
    + dbax_cookie
        * g$req_cookies 
        * g$res_cookies
    + dbax_exception
        * g$error 
    + dbax_session
        * g$session  — Variables de sesión

## Referencia APIs DBAX
+ DBAX_COOKIE
+ DBAX_CORE
+ DBAX_DATATABLE
+ DBAX_DOCUMENT
+ DBAX_EXCEPTION
+ DBAX\_FILE_PARSER
+ DBAX_LDAP
+ DBAX_LOG
+ DBAX_SECURITY
+ DBAX_SSESSION
+ DBAX_UTILS
+ JSON_UTIL
+ XLSX_BUILDER


"attention", "caution", "danger", "error", "hint", "important", "note", "tip", "warning", "admonition"

!!! attention
    This is attention

!!! caution
    This is caution

!!! danger
    This is danger

!!! error
    This is error

!!! hint
    This is hint

!!! important
    This is important

!!! note
    This is note

!!! tip
    This is tip

!!! warning
    This is warning

!!! admonition
    This is admonition



Some text with an ABBR and a REF.

*[ABBR]: Abbreviation abreviatura con titulillo
*[REF]: Reference refenrecia