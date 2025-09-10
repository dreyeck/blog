---
id: 830
title: Tiles visualizer
date: "2013-10-27 02:15:55"
categories:
  - interactive
tags:
  - javascript
language: eng
---

![image](/files/2013/10-tiles-visualizer/cordilleravis.jpg "Cordillera Vis")

[Español](/2013/10/tiles-visualizer/#language)

I was contracted to finish a work that had been started but never completed, [a floor and wall tiles in-context visualizer web app.](http://www.cordillera.cl/flash.php) You have a photo, and you can choose among the client's catalog of tiles to place them in the photo's walls and floors to see how they would look in a real setting. Although this work was almost finished, the source code had disappeared. Taking this as an opportunity, I revised the interaction design, ending up with a more focused and approachable app than what was originally conceived. I was originally only going to iron out the remaining programming wrinkles, but ended up doing the interaction design as well as a full code-up.

The biggest design challenge was making the app casually usable, since such a utility would see little action if it is not instantly understood and provides results in seconds. The number of choices is quite large, so I had to make these choices seem fewer. I put the user straight into the action by simply randomly choosing a photo for them to work on, with the ability to swap it. The flow of use goes from just selecting a surface to then one or two tiles for it. The tiles are filtered contextually according to the environment and the surface selected, so, for instance, for a bath wall there will only appear tiles that are appropriate to put on a bath's wall. These tiles are arranged chromatically in a grid, and are all simultaneously visible in their correct relative dimensions, to make it quick to compare and find the desired one without having the need to specify any filtering criteria; however, if needed, several filters are available. When the user's happy with what they did, they can take that with them in the form of a PDF with the image and information of the selected tiles, or they can share a link with friends (which takes them to the same utility, with the tiles pre-filled).

Technically challenging was figuring out a way to display the tiles in correct perspective according to the (flat) photos. Turned out that the easiest was using the same geometric technique that visual artists use, involving two vanishing points plus the horizon line for a flat surface, together with algorithms for finding segment intersections. I've obviously little idea of 3D coding, so this was all new to me, but I got good results! I also experimented with two interesting programming patterns that were new for me, [reactive programming](http://en.wikipedia.org/wiki/Reactive_programming) and [promises,](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/) the combination of which made it easier working with the asynchronous loading of images and other data.

Although I am rather happy with my work on the interaction design end, the result does sadly have many shortcomings...<!-- more -->

<language-break />

Fui contratado para terminar un trabajo que había sido empezado pero nunca completado, [un visualizador de baldosas en contexto](http://www.cordillera.cl/flash.php) para la web del cliente que las produce. Sobre una foto de un ambiente puedes elegir los productos que quieres ver puestos en sus muros y pisos para comprobar cómo se ven los productos en un contexto real. Aunque el proyecto ya estaba casi terminado, el código fuente se traspapeló. Tomé eso como una oportunidad y corregí el diseño interactivo, haciendo posible una aplicación más enfocada y accesible de lo que se había concebido en un comienzo. Originalmente nada más iba a atar algunos cabos sueltos en el código, pero acabé por trabajar su diseño interactivo además de programarla desde cero.

Un reto en el diseño fue lograr que la aplicación sea utilizable en forma casual, ya que no obtendría mucho uso si no es entendible de inmediato y no genera resultados en segundos. El número de selecciones necesarias es bastante alto, así que tuve que hacer que parezcan menos de las que realmente son. Puse al usuario directamente en la acción al elegir al azar una foto para que comience, con la posibilidad de cambiarla. El flujo de uso parte con elegir una superficie y luego una o dos baldosas. Las baldosas se filtran contextualmente, según el ambiente y la superficie que fue seleccionada; es decir, para una pared de baño sólo se muestran las baldosas que es apropiado poner en la pared de un baño. Éstas aparecen dispuestas según color y ordenadas reticularmente, todas visibles al mismo tiempo y con sus dimensiones relativas correctas, lo que permite rápidamente comparar y encontrar la que se busca sin necesidad de especificar criterios de filtrado; sin embargo, también existen varios filtros disponibles en caso de resultar útiles. Cuando el usuario se siente satisfecho con lo que hizo, puede exportarlo en formato PDF con una imagen y datos de las baldosas seleccionadas, o puede compartir un link con sus amigos (que los llevará a lo mismo que está viendo el usuario original, la misma aplicación con las baldosas rellenadas).

En el aspecto técnico, fue complicado encontrar la manera de mostrar las baldosas en correcta perspectiva de acuerdo a las fotos (que son planas). Lo que finalmente resultó más fácil fue emplear la misma técnica geométrica que aplican los artistas visuales, que usa dos puntos de fuga y la línea del horizonte, junto con algoritmos para encontrar puntos de intersección entre segmentos. Obviamente no conozco mucho de programación para 3D, así que esto fue terreno nuevo para mí, pero los resultados son buenos. También experimenté con dos nuevos (para mí) patrones de programación, [programación reactiva](http://en.wikipedia.org/wiki/Reactive_programming) y [promesas](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/), la combinación de los cuales me hizo más fácil lidiar con la carga asincrónica de imágenes y otros datos, por ejemplo.

Aunque me satisface bastante el trabajo que hice con el diseño interactivo de esta aplicación, el resultado sí tiene varios puntos débiles...
