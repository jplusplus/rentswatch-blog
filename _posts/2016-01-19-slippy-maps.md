---
layout: post
title: "Making a map of all the rents in Europe"
excerpt: "How to create map tiles of all the rents in Europe."
author: nkb
date: 2016-01-19
---

We build Rentswatch to visualize rent prices across borders easily. To do so, we needed to make a map. Several free and easy-to-use tools exist to map data, such as CartoDB and Google Fusion Tables. But they won't let you map several hundred thousand data points fast. We had to find something else.

Inspired by the examples from Comeetie, who mapped [revenue in France block by block](http://www.comeetie.fr/galerie/francepixels/#map/revenus/vardefault/7/46.973/3.378), and by the Berliner Morgenpost, which [mapped the demographic evolution of each city in Europe](http://interaktiv.morgenpost.de/europakarte/#5/48.415/11.294/de), we decided to make our own tiles. The maps you see online are mainly a large collection of square images - _tiles_ - stitched together. For each zoom level, the globe is divided in a number of tiles that have a position on a large grid. At higher zoom levels, the globe is divided in few tiles. The more you zoom, the more tiles you need to cover the globe. This, for instance, is tile number 2125/1367 for zoom level 12, which shows a part of Düsseldorf:

!["The tile 2125/1367, which shows part of Düsseldorf"](http://a.tile.openstreetmap.org/12/2125/1367.png)

We decided to overlay tiles that contain rent prices for each square of 500m x 500m, all across Europe. Instead of having an image of the rent prices, we just had to make a computer program that could generate the thousand of tiles that we needed.

We told the computer to go from the tile at the North-West corner of Europe all the way to the tile at the South-East and to compute the average rent along the way. The code looked something like this:
	
<script src="https://gist.github.com/n-kb/a441b772addd35260a1f.js"></script>

The complete code [is available on Github](https://github.com/jplusplus/rentswatch-stats/blob/master/analyses/tiles/make_tiles.py).

This approach works well for zoom levels where there are few tiles. However, at lower zoom levels, where you need thousands and thousands of tiles to cover Europe, the operation would take days on an average computer. <s>Because we cannot rent a supercomputer</s> Because we strive to be more efficient, we had to devise a better method. Instead of computing rents for all of Europe linearily, including the vast swathes of territory for which we have no data (e.g. the sea), we decided to start from the 600 cities where we had more than 100 data points. For each city, the computer creates the neighboring tiles. The logic looks like this:

<script src="https://gist.github.com/n-kb/7e8e1a28ea434762d511.js"></script>

The complete code [is available on Github](https://github.com/jplusplus/rentswatch-stats/blob/master/analyses/tiles/city_make_tiles.py).

This way, it takes just a few hours to create the tiles for almost all the places in Europe for which we have information on rents.

The result is a slippy map of Europe where the color of each square represents the average renting price. The more red the square, the higher the rents. Each square contains the average price for at least 3 data points. Empty areas are those for which we have less than 3 data points.

The map will be live when we launch, in May 2016. Let's zoom in on Düsseldorf, for instance. You can see the gap between Oberkassel, Carstadt and the rest of the city. But when you zoom out, you can clearly see that this divide is nothing compared to the divide between Germany and Switzerland, for instance.

!["Zoom level 12"](../images/12.jpg)
!["Zoom level 11"](../images/11.jpg)
!["Zoom level 10"](../images/10.jpg)
!["Zoom level 9"](../images/9.jpg)
!["Zoom level 8"](../images/8.jpg)
!["Zoom level 7"](../images/7.jpg)
!["Zoom level 6"](../images/6.jpg)
!["Zoom level 5"](../images/5.jpg)
!["Zoom level 4"](../images/4.jpg)
