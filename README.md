# Core Image Filtering
Discover the power of CIFilters

 ![screenshot](/screenshotimagecore.png)

1- CoreImageSwift runs different filters on an image :

   In the application press on the button filter in blue will ACTIVATE that filter on
   the image. The button label color will then change to yellow to indicate that
   this is the active filter applied.

2- If a slider is enabled as a result - one may change the intensity by dragging
   the SLIDER (Some filters (e.g. Sepia) require also an intensity factor and
   that is conveyed in the slider)

3- Mind the use of THREADS here : they are essential for providing a
   satisfactory user experience. Without them UI gets stuck when you use slider
   (you may try running only on main UI thread and see for yourself...)

4- Recommended warmly to check out API Reference of 'CIFilter'. There are many
   more filters, many of them with lots of rendering factors
   (background picture, sharpness, etc. etc...)

5- No license. All project is totally FREE as far as I'm concerned (to
   copy, use and modify)
