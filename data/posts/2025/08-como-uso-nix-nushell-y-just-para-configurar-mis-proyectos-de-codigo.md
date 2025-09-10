---
title: Cómo uso Nix, Nushell y Just para configurar mis proyectos de código
date: "2025-08-11 20:24:00"
categories:
  - interactive
tags:
  - espanol
  - nix
  - nushell
language: spa
external:
  mastodon-toot-id: "115012021382018212"
  devto-slug: "como-uso-nix-nushell-y-just-para-configurar-mis-proyectos-de-codigo-3dcg"
---

Desde hace un tiempo que en cualquier proyecto personal de código que empiezo, termino usando tres tecnologías: [Nix][nix], [Nushell][nushell] y [Just][just]. En este artículo quiero presentar estas tres herramientas, y compartir la forma en que las uso para configurar las dependencias del proyecto, escribir scripts, y definir sus tareas de desarrollo. Asumo que entiendes cómo usar tu terminal, que trabajas en un entorno tipo Unix, y que sabes programar.

Vamos a partir viendo el manejo de dependencias usando Nix.

[nix]: https://nixos.org/
[nushell]: https://www.nushell.sh/
[just]: https://just.systems/

# Nix para declarar dependencias

[Nix](https://nixos.org/) es un ecosistema enorme y muy versátil, pero en este contexto lo que nos interesa es que podemos usar esta herramienta para declarar todas las utilidades necesarias para correr un proyecto, compilarlo, hacer linting, etc., _y sin usar contenedores._ Es compatible con casi cualquier entorno tipo Unix, o sea Linux, macOS y Windows bajo WSL.

En particular, lo que uso es algo llamado “flake”. Este es un archivo de nombre `flake.nix` que se pone en la raíz del proyecto, y es donde declaramos los paquetes que necesita.

Partamos con un ejemplo simple:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    pkgs = import nixpkgs {system = "aarch64-darwin";};
  in {
    devShell."aarch64-darwin" = pkgs.mkShell {
      buildInputs = [
        pkgs.elmPackages.elm
        pkgs.elmPackages.elm-format
        pkgs.elmPackages.elm-test
        pkgs.just
        pkgs.nushell
      ];
    };
  };
}
```

Con esto, hemos definido un entorno que contiene algunas herramientas para un proyecto [Elm](https://elm-lang.org/), además de los binarios de Nushell y Just, a los que me voy a referir más abajo. Así como está, esto sólo va a funcionar en un Mac de los con procesador Apple Silicon. Después vamos a desarrollar este ejemplo para entenderlo mejor y hacerlo más versátil, pero por ahora partamos viendo en qué nos ayuda tener este archivo.

Si corremos el comando `nix develop` vamos a entrar a un shell Bash que contiene todas las herramientas declaradas en nuestro `flake.nix`. Para salir basta con correr el comando `exit`, y veremos que ya no tenemos disponibles las herramientas—son totalmente locales al proyecto.

```sh
$ nix develop
$ which elm
/nix/store/6hx8g6k7ihgaqvy1i0ydiy7v13s04pf4-elm-0.19.1/bin/elm

$ exit
exit

$ which elm
elm not found
```

La primera vez se generará un archivo `flake.lock`, el cual podemos integrar en Git (o tu VCS preferido) para mantener la versión exacta de estas dependencias. Luego se descargarán algunos binarios en caché o se compilarán las dependencias desde su código fuente. Pero eso ocurrirá sólo la primera vez, o cuando quieras cambiar las dependencias, ya que se almacenará todo en el “store” global de Nix.

## Un poco más en profundidad

Puedes saltarte esta sección si no te interesa. Aquí voy a explicar un poquito cómo hacer funcionar el ejemplo de arriba para ti, ya que no quise complejizar con ciertos detalles.

Primero, hace falta especificar que esta funcionalidad llamada “flakes” es, al momento en que escribo esto, considerada experimental, y por lo tanto no está activada por defecto: hay que configurarla.

Si no tienes Nix instalado aún, te recomiendo usar el [Determinate Nix Installer](https://zero-to-nix.com/concepts/nix-installer/). No es el oficial, pero es mejor en varios aspectos, entre ellos, viene con flakes activados por defecto, funciona mejor en macOS, y también incluye una forma fácil de desinstalar. Corre el script de abajo en tu terminal para instalarlo (o copia el script de la dirección vinculada arriba). **Cuidado:** Cuando te pregunte si instalar “Determinate Nix”, ponle que **no**. Ese es un fork, y lo que queremos es instalar Nix oficial.

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Si por otro lado ya tienes instalado Nix y no te funcionan los flakes, necesitas añadir un poco de configuración. Abre o crea un archivo `~/.config/nix/nix.conf` y ponle esto:

```
experimental-features = flakes nix-command
```

Ya con todo configurado correctamente, te pongo una versión ajustada del archivo `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {system = system;};
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-test
            pkgs.just
            pkgs.nushell
          ];
        };
      }
    );
}
```

Lo que hicimos fue declarar una nueva entrada bajo `inputs`, de nombre `flake-utils`, y más abajo usar la función `eachDefaultSystem` que provee, la que nos ayuda a configurar un shell de desarrollo para múltiples entornos simultáneamente. Lo demás está igual.

Para agregar otros paquetes, los encuentras en [la búsqueda de Nixpkgs](https://search.nixos.org/packages?channel=unstable). Una vez que encuentres el nombre de lo que quieres, lo puedes agregar en la lista en tu flake.

Y esto es todo lo esencial que necesitas saber para empezar, aunque por supuesto, hay muchos detalles que podrás ir descubriendo por tu cuenta. Como dije al principio, Nix es un mundo muy grande por explorar. Y de hecho, si Nix te parece muy complejo, existen herramientas que funcionan con Nix por debajo, pero proveen una interfaz más intuitiva para este caso de uso; te recomiendo que le eches una mirada a [Devbox](https://www.jetify.com/devbox), [Flox](https://flox.dev/) y [Devenv](https://devenv.sh/).

# Nushell para escribir scripts

[Nushell][nushell] es una alternativa a Bash o zsh. La diferencia es que en vez de seguir los lineamientos [POSIX](https://es.wikipedia.org/wiki/POSIX) e interactuar sólo con texto plano, trabajamos con datos estructurados. Básicamente, es un shell y lenguaje que reemplaza la necesidad de Bash, grep, sed, awk, jq, curl y muchas otras utilidades de línea de comandos frecuentemente usadas para procesar datos.

Igual se ajusta hasta cierto punto a nuestras expectativas como usuarios de Bash y similares. Por ejemplo, en un shell Nushell el comando `ls` funciona como es de esperarse:

```sh
$ ls
╭───┬────────────┬──────┬───────┬─────────────╮
│ # │    name    │ type │ size  │  modified   │
├───┼────────────┼──────┼───────┼─────────────┤
│ 0 │ flake.lock │ file │ 569 B │ 8 hours ago │
│ 1 │ flake.nix  │ file │ 405 B │ 7 hours ago │
╰───┴────────────┴──────┴───────┴─────────────╯
```

Pero esta salida no es puramente texto. En realidad lo que hemos obtenido es una tabla con filas y columnas. Mira el tipo de cosas que podemos hacer con sólo Nushell:

```sh
$ ls | where name =~ '[.]lock$' | get 0.name | open
::: | from json | get nodes.nixpkgs.locked.lastModified
::: | $in * 1_000_000_000 | into datetime
Tue, 5 Aug 2025 11:35:34 +0000 (2 days ago)
```

Obviamente este ejemplo es puramente demostrativo, pero fíjate: estamos listando archivos, filtrando en base a un regex, sacando el nombre del primero en la lista, leyendo el contenido del archivo, interpretándolo como JSON, recuperando un valor numérico dentro del JSON, multiplicando para convertir segundos a nanosegundos, y finalmente convirtiendo eso a una fecha.

Es tan práctico que lo tengo como mi shell por defecto. Pero para el caso de este artículo, lo relevante es su utilidad para escribir scripts simples y legibles que transforman archivos, levantan servicios, recuperan datos de internet, y más. Los archivos llevan la extensión `.nu`.

Veamos un pequeño ejemplo. Este es un script que actualiza una lista de exclusiones para evitar visitas de robots de IA, con datos que descargamos del [Github del proyecto ai.robots.txt](https://github.com/ai-robots-txt/ai.robots.txt/).

```nu
# Algunas constantes.
let aiRobotsTxtBaseUrl = "https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main"
let startMarkerLine = "# Start ai.robots.txt"
let endMarkerLine = "# End ai.robots.txt"

# Una pequeña función para simplificar el código más adelante.
def splitLines [] {
  split row "\n"
}

# Función que procesa los datos para un archivo específico, ya que son
# dos los que queremos actualizar.
def updateFile [$filename] {
  # Leemos el archivo local y lo dejamos en la variable como una lista
  # de líneas.
  let localLines = open $"./public/($filename)" | splitLines
  # Lo mismo para el archivo remoto.
  let updateLines = http get $"($aiRobotsTxtBaseUrl)/($filename)" | splitLines

  # El archivo local tiene líneas que marcan el comienzo y el final
  # del contenido que queremos actualizar, marcados por las constantes
  # de arriba de nombre `$startMarkerLine` y `$endMarkerLine`. En base
  # a ese contenido, cortamos la lista para recuperar el contenido
  # que queremos mantener, el cual viene antes y después dentro del
  # archivo.
  let firstSplit = $localLines | split list $startMarkerLine
  let linesBeforeUpdate = $firstSplit | get 0
  let secondSplit = $firstSplit | get 1 | split list $endMarkerLine
  let linesAfterUpdate = $secondSplit | get 1

  # Insertamos las líneas provenientes del archivo remoto en la mitad,
  # concatenando todo en una misma lista.
  let updatedLines = (
    $linesBeforeUpdate
    ++ [$startMarkerLine]
    ++ $updateLines
    ++ [$endMarkerLine]
    ++ $linesAfterUpdate
  )

  # Sobreescribimos el archivo antiguo con las nuevas líneas.
  $updatedLines | str join "\n" | save --force $"./public/($filename)"
}

# Usamos la función definida arriba para procesar dos archivos.
updateFile ".htaccess"
updateFile "robots.txt"
```

No sé lo que pienses tú, pero yo creo que queda un código extremadamente legible y conciso. Es fácil de escribir, trae “pilas incluídas” como quien dice, con soporte para procesar muchos formatos de archivo. Y cuando hay algo que no se puede hacer con Nushell, puedes echar mano a cualquier herramienta de línea de comandos, idéntico a como haríamos en un script de Bash.

El lenguaje Nushell toma las “pipes” (`|`) de los shell Unix y las combina con estructuras de datos inmutables. Es un lenguaje bastante funcional, de tipado dinámico pero estricto, o sea que si una función recibe un valor con un tipo inesperado, la ejecución falla con un mensaje bien explícito, como este:

```sh
$ ["hola", "cómo", "estás"] | date to-timezone "UTC"
Error: nu::parser::input_type_mismatch

  × Command does not support list<string> input.
   ╭─[entry #6:1:31]
 1 │ ["hola", "cómo", "estás"] | date to-timezone "UTC"
   ·                             ────────┬───────
   ·                                     ╰── command doesn't support list<string> input
   ╰────
```

# Just para definir tareas

[Just][just] es una herramienta con un alcance muy moderado: permitir definir tareas repetibles para un proyecto. Lo típico es definir una tarea “build” para compilar el código, o una “dev” para ejecutarlo localmente, o una “test” para correr los tests. La manera en que funcionaría usando Just es con los comandos `just build`, `just dev` y `just test`, cuyas tareas uno mismo define en un archivo de nombre `justfile`.

Seguro que hasta ahí no hay nada nuevo, es lo mismo que uno haría con Make o con `npm run`, por ejemplo. Y es verdad, Just no ofrece un paradigma novedoso. Lo único que ofrece es simpleza.

El modelo de Just es Make. No sé tú, pero yo al menos he escrito muchos [makefile](https://dev.to/djsurgeon/como-hacer-un-buen-makefile-2pol) para definir tareas para un proyecto. El problema con eso es que Make tiene muchas asperezas para este objetivo. Por ejemplo, si defines una tarea `test` para correr tus tests, y resulta que tienes una carpeta `test` en el mismo directorio, no se va a correr la tarea. Esto es porque Make está hecho para compilar cosas, donde el nombre de la tarea es el nombre del archivo, y cuando el archivo o directorio ya existe, simplemente no se ejecuta la tarea.

La razón por la que me gusta Just es porque es como un Make pero hecho para correr tareas, con todas sus asperezas pulidas. La sintaxis de un “justfile” es igual a la de un makefile, pero un poquito mejor. Por ejemplo, puedes indentar usando espacios en vez de tabs, y puedes poner comentarios de documentación. Además puedes listar tareas usando `just --list`.

Te pongo un ejemplo. Este archivo lleva el nombre `justfile`.

```justfile
port := "1237"

[private]
default:
  just --list

# Compila archivos.
build: install
  rm -rf dist
  pnpm exec vite build

# Levanta el servidor de desarrollo.
develop: install qr
  pnpm exec vite --port {{port}} --host

[private]
install:
  pnpm install

[private]
qr:
  #!/usr/bin/env nu
  let ip = sys net | where name == "en0" | get 0.ip | where protocol == "ipv4" | get 0.address
  let url = $"http://($ip):{{port}}"
  qrtool encode -t ansi256 $url
  print $url
```

En la línea 4 definí la primera tarea, a la que le puse nombre `default` porque es la que se ejecutará por defecto si uno escribe `just`. Puede ser cualquier tarea, pero a mí me gusta que la primera tarea sirva para ver la lista de tareas disponibles, por eso la hice “escondida” usando el modificador `[private]`. Mira cómo se ve:

```sh
$ just
just --list
Available recipes:
    build   # Compila archivos.
    develop # Levanta el servidor de desarrollo.
```

Bastante bonito, ¿no? Te puedes dar cuenta de que los comentarios escritos sobre cada tarea sirven como documentación de esa tarea, y que aparecen al usar el comando `--list`.

Otras aspectos notables:

- En la primera línea definí una constante que después uso escribiendo `{{port}}` en dos lugares.
- Hay una tarea `install` que definí como prerrequisito de dos otras, o sea que cuando, por ejemplo, llame `just build`, se ejecutarán primero los comandos en `install`.
- La tarea `qr` comienza con la línea `#!/usr/bin/env nu`, la cual sirve para definir con qué programa quieres que se ejecuten los comandos de esa tarea. En este caso, escribí un pequeño script de Nushell. Puedes usar Python si quisieras, o Clojure vía [Babashka](https://babashka.org/), o cualquier otro lenguaje aquí. Esta funcionalidad es súper útil.

---

Esa fue mi presentación sobre estas herramientas que uso para configurar mis proyectos. Hay una otra herramienta que no mencioné: [direnv](https://direnv.net/), la cual hace que sea mucho más placentero trabajar con entornos Nix. Tal vez otro día escribiré algo al respecto, no sé.

Ojalá que te haya sido útil, y cuéntame si encontraste algo incorrecto o confuso.
