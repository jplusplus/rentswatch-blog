---
layout: post
title: "Writing scrapers with Rentswatch"
excerpt: "Explaining the inner workings of our a rentswatch scraper."
author: pirhoo
date: "2015-11-17"
---

Rentswatch focuses on extracting classified ads. To do so, we set up a large collection
of tiny robots that analyze and extract data from websites. For the sake efficiency
we created a framework that harmonizes the way we code those scrapers.

This post details how to write a scraper in **python** using this framework.

How to install
==============

Install using `pip`...

{% highlight bash %}
pip install rentswatch-scraper
{% endhighlight %}

How to use
==========

Let's take a look at a quick example of a Rentswatch Scraper to
build a simple model-backed scraper to collect data from a website.

First, import the package components to build your scraper:

{% highlight python %}
#!/usr/bin/env python
from rentswatch_scraper.scraper import Scraper
from rentswatch_scraper.browser import geocode, convert
from rentswatch_scraper.fields import RegexField, ComputedField
from rentswatch_scraper import reporting
{% endhighlight %}

To factorize as much code as possible we created an abstract class that
every scraper will implement. For the sake of simplicity we'll use a
*dummy website* as follow:

{% highlight python %}
class DummyScraper(Scraper):
    # Those are the basic meta-properties that define the scraper behavior
    class Meta:
        country         = 'FR'
        site            = "dummy"
        baseUrl         = 'http://dummy.io'
        listUrl         = baseUrl + '/rent/city/paris/list.php'
        adBlockSelector = '.ad-page-link'
{% endhighlight %}

Without any further configuration, this scraper will start to collect
ads from the list page of `dummy.io`. To find links to the ads, it will
use the CSS selector `.ad-page-link` to get `<a>` markups and follow
their `href` attributes.

We have now to teach the scraper how to extract key figures from the ad
page.

{% highlight python %}
class DummyScraper(Scraper):
    # HEADS UP: Meta declarations are hidden here
    # ...
    # ...

    # Extract data using a CSS Selector.
    realtorName = RegexField('.realtor-title')
    # Extract data using a CSS Selector and a Regex.
    serviceCharge = RegexField('.description-list', 'charges : (.*)\s€')
    # Extract data using a CSS Selector and a Regex.
    # This will throw a custom exception if the field is missing.
    livingSpace = RegexField('.description-list', 'surface :(\d*)', required=True, exception=reporting.SpaceMissingError)
    # Extract the value directly, without using a Regex
    totalRent = RegexField('.description-price', required=True, exception=reporting.RentMissingError)
    # Store this value as a private property (begining with an underscore).
    # It won't be saved in the database but it can be helpful, as you we'll see.
    _address = RegexField('.description-address')
{% endhighlight %}

Every attribute will be saved as an Ad's property, according to the [Ad
model](https://github.com/jplusplus/rentswatch-scraper#class-ad).

Some properties may not be extractable from the HTML. You may need to
use a custom function that received existing properties. For this reason
we created a second field type named `ComputedField`. Since the
properties order of declaration is recorded, we can use previously
declared (and extracted) values to compute new ones.

{% highlight python %}
class DummyScraper(Scraper):
    # ...
    # ...

    # Use existing properties `totalRent` and `livingSpace` as they were
    # extracted before this one.
    pricePerSqm = ComputedField(fn=lambda s, values: values["totalRent"] / values["livingSpace"])
    # This full example uses private properties to find latitude and longitude.
    # To do so we use a built-in function named `convert` that transforms an
    # address to a Python dictionary of coordinates.
    _latLng = ComputedField(fn=lambda s, values: geocode(values['_address'], 'FRA') )
    # Gets the Python dictionary field we want.
    latitude = ComputedField(fn=lambda s, values: values['_latLng']['lat'])
    longitude = ComputedField(fn=lambda s, values: values['_latLng']['lng'])
{% endhighlight %}

All you need to do now is to create an instance of your class and run
the scraper.

{% highlight python %}
# When you script is executed directly
if __name__ == "__main__":
  dummyScraper = DummyScraper()
  dummyScraper.run()
{% endhighlight %}

Going further
=============

As we wanted to make the `Scraper` very flexible, we isolated most of the extraction
steps in separated methods. The full methods list is available [on Github
with descriptions](https://github.com/jplusplus/rentswatch-scraper#class-scraper).
By overriding those methods you can completely change the behavior of your scraper.
For instance, `get_series` method is used to extract every ads list and parse
the page to create a iterator with every ads in this list. The `get_ad_href` method
receives a *soup* of an ad's block in order to extract the link to the ad.  
