/*
Aims to replicate this:
https://www.youtube.com/watch?v=jofycaXByTc
*/

include <gears.scad>

$fn = $preview ? 16 : 128;

planetary_gear(
  modul=2, 
  sun_teeth=16, 
  planet_teeth=9, 
  number_planets=4, 
  width=20, 
  rim_width=3, 
  bore=3,
  pressure_angle=20, 
  helix_angle=30, 
  together_built=true, 
  optimized=false
);