---
title: Experimentando con Elm en mi trabajo
date: "2025-08-31 02:41:00"
categories:
  - interactive
tags:
  - elm
  - web
  - work
language: spa
external:
  mastodon-toot-id: "115121095181061077"
  devto-slug: "experimentando-con-elm-en-mi-trabajo-2c78"
---

Llevo trabajando cuatro años como desarrollador full-stack en una empresa cuyo producto es un [“SaaS”](https://es.wikipedia.org/wiki/Software_como_servicio), o sea, básicamente una aplicación web. La empresa ha sufrido varios cambios internos de estrategia, y eso ha impactado al lado técnico también. En una de esas ocasiones se vio posible el reconsiderar varios aspectos técnicos que llevábamos en el front-end, y quise probar suerte proponiendo mi tecnología preferida para este ámbito: Elm.

Para bien o para mal, los planes fueron otros, y hoy día Elm no se usa en la empresa en ninguna capacidad. Igual, quiero compartir un poco mi experiencia construyendo esta propuesta de integrar Elm en un sistema preexistente. Lo que sigue está escrito bajo la suposición de que tienes cierto conocimiento del lenguaje y algo de experiencia trabajando el front-end.

El proyecto partió después de una conversación con el “ingeniero principal” de la empresa, quien me propuso que haga la prueba migrando algún trozo pequeño de la aplicación como prueba de concepto. Quedamos en que tomaría una página interna: el explorador de usuarios. Esta página la usan el equipo de soporte y el área comercial para revisar y corregir problemas en los datos de nuestros usuarios, aunque aparentemente no se usa muy frecuentemente. La página merecía ser mejorada porque funcionaba muy lento, y siendo una página de uso exclusivo interno, el riesgo de intervenirla era bajo.

Como parte de este experimento, también estuve algunos días haciendo “pair programming” con dos colegas, para que conozcan Elm y puedan hacerse una opinión que compartirían con el resto del equipo, aunque a ellos los integré una vez que ya estaba todo mayormente armado. (Un error de cálculo fue que estos dos colegas se fueron de la empresa poco tiempo después, obviamente por razones sin relación con este proyecto). El resto lo hice durante semanas de “cooldown” entre proyectos, y también algunos fines de semana.

# Integración con Webpack

Ese entorno “legacy” sobre el que trabajaría es un monolito hecho en PHP, con Vue en algunos lados, y el JS empaquetado usando [Webpack](https://webpack.js.org/). Por eso, la verdad fue bastante fácil integrar Elm usando un plugin de nombre [elm-webpack-loader](https://www.npmjs.com/package/elm-webpack-loader). Sólo tuve que crear un punto de entrada `main.js`, donde instancio la aplicación Elm con sus flags y puertos, y agregarlo en el archivo de configuración de Webpack como `entry`. Lo demás consiste en poner en la página la etiqueta `<script>` que carga el `.js` generado, y otra etiqueta con un ID específico que luego le pasaremos a Elm para que la use.

Como se ve abajo es como estructuré los archivos, finalmente. Nótese que permite tener múltiples miniaplicaciones Elm, cada una definida en un directorio `elm/Entrypoint/*`, que incluye su propio punto de entrada y rutas.

```
elm/
  Api/            Comandos de llamada a la API.
  Data/           Tipos de datos.
  Entrypoint/
    */            Cada punto de entrada tiene un submódulo.
      Route/
        *.elm     Rutas, cada una un “mini TEA”.
      Main.elm    Un punto de entrada en Elm.
      Route.elm   Tipo que define la ruta actual.
      main.js     Punto de entrada para Webpack. Instancia `Main`.
  Util/           Utilidades varias.
  View/           “Componentes”.
  Layout.elm      Constantes de la vista, como colores y tamaños.
  Ports.elm       Puertos, lado Elm.
  Run.elm         Envoltorio sobre `Browser.element`.
  ports.js        Puertos, lado JS.
```

El archivo `elm.json` queda en la raíz del proyecto, con el directorio `elm/` configurado en `source-directories`. Cada `elm/Entrypoint/*/main.js` es vinculado en la configuración de Webpack. Este archivo se encarga de inicializar su `Main.elm` respectivo, pasándole flags, y configura los puertos usando una función exportada desde `elm/ports.js`.

# Puertos para enrutar

Mencioné la reconstrucción de una página (la de usuarios), pero este módulo en realidad comprende dos páginas: el listado de usuarios, y la página de visualización y edición de un usuario individual. Por eso hacía falta tener alguna solución para el manejo de rutas, o sea que funcione como una “single-page application”, si bien para sólo dos rutas.

[Normalmente](https://agj.github.io/elm-guide-es/webapps/navigation.html), si uno hace una aplicación Elm independiente, uno usa `Browser.application` ([doc.](https://elm.dmy.fr/packages/elm/browser/latest/Browser?source=#application)), que permite definir las funciones `onUrlRequest` y `onUrlChange` para reaccionar ante clicks en links y cambios en la ruta. Lamentablemente, en este contexto no es posible, ya que `Browser.application` se apodera de la página completa. En este caso tenemos una aplicación Elm incrustada dentro de una aplicación más grande, con menús alrededor que funcionan de forma independiente, así que fue necesario solucionarlo de otra forma.

Lo que hice fue usar `Browser.element` ([doc.](https://elm.dmy.fr/packages/elm/browser/latest/Browser?source=#element)), que sólo toma poder de un elemento dentro de la página, y para manejar los cambios de ruta usé puertos. Desde el lado de JS escuché el evento `"popstate"` ([MDN](https://developer.mozilla.org/es/docs/Web/API/Window/popstate_event)) emitido desde `window` para registrar cambios en la ruta y gatillar el puerto correspondiente, y escuché un puerto de Elm para cambiar la ruta usando `window.history.pushState` ([MDN](https://developer.mozilla.org/es/docs/Web/API/History/pushState)). Esto sirve para cambiar parámetros de búsqueda en la URL tipo `?param=value`, también.

Usé sólo dos puertos, uno de entrada y otro de salida, ambos cuales transmiten un tipo así:

```elm
type alias JsMsg =
    { kind : String
    , value : Value
    }
```

Este es un patrón usualmente recomendado en la comunidad Elm, aunque hay distintas maneras de implementarlo. También usamos decodificadores JSON para manejar los valores recibidos en forma estricta.

# Manejo centralizado de rutas

Para simplificar la manera en que se construye una miniaplicación Elm, creé una abstracción: Envolví el uso de `Browser.element` en una función que llamé `Run.elementWithFlagsAndRoute`, con la siguiente firma.

```elm
elementWithFlagsAndRoute :
    { init : route -> flags -> ( model, Cmd msg )
    , flagsDecoder : Decoder flags
    , routeDecoder : AppUrl -> Maybe route
    , view : model -> Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , routeChanged : route -> model -> ( model, Cmd msg )
    }
    -> Program Value (InitModel (RouteModel route model)) (RouteMsg msg)
```

Esta función centraliza la decodificación de “flags” y, por supuesto, se hace cargo de los detalles del manejo de puertos para el enrutamiento. Esta estrategia está un poco inspirada en [un artículo por Ju Liu de NoRedInk](https://juliu.is/elm-at-noredink/#our-elm-programs), y en otro blog de por ahí cuyo link no logré desenterrar, que también habla de esto mismo.

Internamente, esta función administra los puertos mencionados más arriba para saber cuándo hay un cambio en la URL. `routeDecoder : AppUrl -> Maybe route` es la manera en que determinamos cuál es la nueva ruta (aquí usé [lydell/elm-app-url](https://elm.dmy.fr/packages/lydell/elm-app-url/latest/AppUrl) para esto). Si esta función retorna `Nothing` esto significa que navegamos hacia algo externo, entonces la navegación se defiere al navegador, y gatillamos la carga de otro recurso.

La función `routeChanged : route -> model -> ( model, Cmd msg )` que mencioné arriba es parecida a `update`, pero dedicada a manejar cambios de ruta. En este primer acercamiento quedó una solución relativamente manual para manejar rutas, pero en todo caso, la idea es que esta función se responsabiliza de almacenar la ruta actual en el modelo y de inicializar el modelo de la ruta actual, potencialmente llamando comandos que la ruta necesita al inicializarse.

# Arquitectura Elm anidada

Existe un módulo `Entrypoint.*.Main` para cada miniaplicación, que se encarga de manejar el estado global y de orquestrar los cambios de ruta. Opté por usar una arquitectura Elm anidada, de modo que este módulo es el encargado de delegar al `init`, `update` y `view` de cada ruta, que está definida en cada módulo `Entrypoint.*.Route.*`.

De hacerlo de nuevo, seguramente separaría entre un modelo global, compartido entre rutas, y otro modelo específico para cada ruta. Lo que hice, sin embargo, fue usar un sólo modelo central para cada miniaplicación, y en cada ruta usé “registros extensibles” para definir un subconjunto de llaves del mismo modelo. Por ejemplo, para el listado de usuarios dentro del módulo `Entrypoint.Usuarios.Route.List`:

```elm
type alias Model a =
    { a
        | usuarios : RemoteData Http.Error Usuarios
        , apiConfig : Api.Http.Config
    }
```

Estas llaves `usuarios` y `apiConfig` están definidas también en el `Model` central. El módulo `Main` le pasa el modelo completo al `update` de esta ruta, pero gracias a que definimos su “submodelo” como un registro extensible, la ruta sólo ve lo que le interesa dentro de él. El problema de esta estrategia es que hay que tener cuidado en qué datos deben limpiarse al cambiar de ruta y cuáles no, y también implica repetir las mismas llaves en el `Model` central y el de la ruta.

Por ejemplo, si tenemos un tipo `Route` así:

```elm
type Route
    = List RouteListQuery.Query
    | Detail String
```

Podemos actualizar el modelo así en `Main`, mapeando duplas de ruta + mensaje:

```elm
type Msg
    = RouteListMsg Entrypoint.Usuarios.Route.List.Msg
    | RouteDetailMsg Entrypoint.Usuarios.Route.Detail.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model.route, msg ) of
        ( Route.List query, RouteListMsg routeMsg ) ->
            let
                ( newModel, cmd ) =
                    Entrypoint.Usuarios.Route.List.update routeMsg model query
            in
            ( newModel
            , Cmd.map RouteListMsg cmd
            )

        ( Route.Detail _, RouteDetailMsg routeMsg ) ->
            let
                ( newModel, cmd ) =
                    Entrypoint.Usuarios.Route.Detail.update routeMsg model
            in
            ( newModel
            , Cmd.map RouteDetailMsg cmd
            )

        _ ->
            ( model, Cmd.none )
```

Este tipo de repetición por el uso de “pattern matching” para cada ruta se replica en otras funciones del módulo `Main`, como `init` y `view`. Hay maneras de hacer esto un poco menos repetitivo, pero en general es lo que pasa cuando uno empieza a anidar arquitecturas Elm, y la razón por la que no se suele recomendar.

---

Eso por ahora. Tal vez en otro artículo escribiré sobre la vista, o sea la estrategia que usé para crear “componentes” y su documentación usando [ElmBook](https://github.com/dtwrks/elm-book).
