/*
E-CVT model.

Largely based on model by Consulab:
https://www.consulab.com/products#cat_l3-hybrid-electric-vehicle_prod_em-200-29-053137-hybrid-planetary-gearset-trainer

Sun gear:     MG1   (green)
Planet gears: ICE   (red)
Ring gear:    MG2   (blue)

Output: Ring gear (Yellow)
*/

include <gears.scad>

/* [General] */
tiny = 1e-3;
selected_part = "assembly"; // ["assembly", "planetary_gear", "carrier",  "sun_shaft", "planet_shaft", "shaft_handle", "small_gear", "small_gear_reverse", "small_shaft", "small_shaft_h", "base"] 

/* [Tolerances] */
tol = 0.4; // For things that need to stick together 
loose_tol = 0.8; // For things that need to rotate freely
clearance = 0.0; // Used in gear library
pip_clearance = 0.1;// Looser clearance for print in place (planetary) gears

/* [Gear Parameters] */
modul = 1;
sun_teeth = 40;
planet_teeth = 20;
number_planets = 4;
width = 10;
rim_width = 6;
bore = 8;
helix_angle = 30;

inter_play = 0.8; // distance between two things on a shaft


/* [Gear diameters] */
// Computed
wanted_outer_diam = modul * (sun_teeth + 2* planet_teeth +7/3) +2*rim_width;
outer_teeth = floor(wanted_outer_diam / modul) - 2;
outer_diam = (outer_teeth + 2) * modul;
ring_diam = outer_teeth * modul;

echo("Outer diam", outer_diam);
echo("Outer teeth", outer_teeth);

sun_diam = modul * sun_teeth;
planet_diam = modul * planet_teeth;
echo("sun d", sun_diam);
echo("planet d", planet_diam);

/* [Base] */
ring_offset = 4;
base_width = 80;
base_length = 200;
base_height = 6;

feet_diam = 17;
feet_depth = 1;
feet_offset = 3;

/* [Shaft holders] */
holder_thickness = 8;

/* [Shaft coupler screw] */
coupler_screw_diam = 3.5;
coupler_nut_diam = 6.35 + 0.2;
coupler_nut_height = 2.15;

/* [Shaft coupler] */
shaft_coupler_wall = 3;
shaft_coupler_height = coupler_screw_diam + 2* shaft_coupler_wall;
shaft_coupler_diam = bore + tol + 2*shaft_coupler_wall;

/* [Handle] */
handle_thickness = 8;
handle_length = 25;
handle_bore_offset = 4;
handle_height = 20;

/* [Sun gear shaft] */
sun_shaft_height = ring_offset + outer_diam / 2;
sun_shaft_length = width + shaft_coupler_height + 2 * inter_play + holder_thickness + handle_thickness;
sun_shaft_end_diam = bore + 4;

/* [Planet gears carrier] */
carrier_width = bore + 3;
carrier_height = 4;
carrier_offset = 1.5;

/* [Planet gears shaft] */
planet_shaft_length = carrier_height + shaft_coupler_height + holder_thickness + handle_thickness + 2*inter_play;//sun_shaft_length - carrier_offset; // TODO change

/* [ ICE gears ] */
ice_gear_teeth = 36; // Constraint: 3 * ice_gear_teeth >= outer_teeth
ice_gear_diam = ice_gear_teeth * modul;
ice_gear_x = sqrt(pow((ring_diam + ice_gear_diam)/2, 2) - pow((ring_diam - ice_gear_diam)/2, 2));
//ice_gear_angle = atan(ring_diam / ice_gear_x);
ice_input_gear_x = ice_gear_x + sqrt(pow(ice_gear_diam, 2) - pow((ring_diam - ice_gear_diam) /2, 2));

small_shaft_length = width + shaft_coupler_height + 2*holder_thickness + 2*inter_play;
small_shaft_length_h = small_shaft_length + inter_play + handle_thickness;
small_shaft_offset = -(holder_thickness + inter_play);

small_first_height = ice_gear_diam/2 + ring_offset;

/* [Text] */
text_size = 8;
text_depth = 1.4;
text_offset = 2;

/* ------ FUNCTIONS ------ */
function gear_diam(num_teeth) = num_teeth / modul;


/* ------ HELPER MODULES ------ */
module ShaftHole() {
  // Hole in the shaft for through-hole screw
  rotate([0, 0, 45])
  rotate([90, 0, 0])
  cylinder(h=bore+tiny, d=coupler_screw_diam, center=true);
}

module ShaftCoupler() { 
  d_hex= shaft_coupler_diam * 2 / sqrt(3);

  difference() {
    rotate([0, 0, -15])
    cylinder(h=shaft_coupler_height, d=d_hex, $fn=6);
    
    cylinder(h=shaft_coupler_height + tiny, d=bore+tol);
    
    translate([0, 0, shaft_coupler_height/2])
    rotate([90, 0, 45]) {
      cylinder(h=shaft_coupler_diam+tiny, d=coupler_screw_diam, center=true);
  
      translate([0, 0, -shaft_coupler_diam/2])
      cylinder(h=coupler_nut_height, d=coupler_nut_diam, $fn=6);
    }
  }
}

module ShaftHolder(hole_height){
  hole_diam = bore + loose_tol;
  bore_offset = 4;
  holder_width = hole_diam + 2 * bore_offset;
  holder_height = hole_height + hole_diam / 2 + bore_offset;
  
  difference() {
    hull() {      
      translate([0, -holder_width/2, 0])
      cube([holder_thickness, holder_width, tiny]);
      
      translate([0, 0, hole_height])
      rotate([0, 90, 0])
      cylinder(h=holder_thickness, d=hole_diam+2*bore_offset);
    } 

    translate([0, 0, hole_height])
    rotate([0, 90, 0])
    cylinder(h=holder_thickness + tiny, d=hole_diam);
  }
}
/* ------ PARTS ------ */

module PlanetaryGearPIP() {
  include <gears.scad>
  // Extra import to set higher clearance
  clearance = pip_clearance;
  
  planetary_gear(
    modul=modul, 
    sun_teeth=sun_teeth, 
    planet_teeth=planet_teeth, 
    number_planets=number_planets, 
    width=width, 
    rim_width=rim_width, 
    bore=bore+tol,
    helix_angle=helix_angle,
    together_built=true, 
    optimized=false
  );    
}

module PlanetaryGear(){
  intersection() {
    PlanetaryGearPIP();
    
    herringbone_gear(
      modul=modul, 
      tooth_number=outer_teeth, 
      width=width, 
      bore=bore+tol, 
      helix_angle=helix_angle, 
      optimized=false
    );
  }
  
  color("green")
  translate([0, 0, width])
  ShaftCoupler();
}

module Carrier() { 
  color("red"){
  difference() {
    for(i = [0:number_planets-1]) {
      rotate([0, 0, i * 360 / number_planets])
      translate([(sun_diam + planet_diam)/2, 0, 0]){
        cylinder(h=width, d=bore-loose_tol);
        
        translate([0, 0, width])
        cylinder(h=carrier_offset, d1=bore-loose_tol, d2=carrier_width);
      }
      
      translate([0, 0, width + carrier_offset])
      hull() {
        rotate([0, 0, i * 360 / number_planets])
        translate([(sun_diam + planet_diam)/2, 0, 0])
        cylinder(carrier_height, d=carrier_width);
      
        cylinder(carrier_height, d=carrier_width);
      }
    }
    
    translate([0, 0, width + carrier_offset]) {
      // Shaft hole
      cylinder(h=carrier_height+tiny, d=bore+tol);
    }
  }
  
  translate([0, 0, width+carrier_offset+carrier_height])
  ShaftCoupler();
  }
}

module SunShaft() {
  color("darkgreen") {
  
  translate([0, 0, width])
  rotate([0, 180, 0]) {
    difference() {
      cylinder(sun_shaft_length, d=bore-tol);
      
      // Hole for handle
      translate([0, 0, sun_shaft_length - handle_thickness / 2])
      ShaftHole();
      
      translate([0, 0, width + shaft_coupler_height / 2])
      ShaftHole();
    }
  }
  }
}

module PlanetShaft() {
  color("darkred") {
  
  difference() {
    cylinder(planet_shaft_length, d=bore);

    translate([0, 0, carrier_height + shaft_coupler_height/2])
    ShaftHole();
    
    // Hole for handle
    translate([0, 0, planet_shaft_length - handle_thickness/2])
    ShaftHole();
  }
  }
}

module HandleHandle(){
  y = 1;
  x = 3;
 
  translate([0, 0, y])
  rotate_extrude(){
    polygon([
      [bore/2, 0],
      [bore/2 + x/2, x/2],
      [bore/2, x]
    ]);
  }
  
  translate([0, 0, handle_thickness - y - x])
  rotate_extrude(){
    polygon([
      [bore/2, 0],
      [bore/2 + x/2, x/2],
      [bore/2, x]
    ]);
  }
  
  cylinder(h=handle_height+handle_thickness, d=bore+tiny);
}

module ShaftHandle() {  
  shaft_diam = bore + tol + 2 * handle_bore_offset;
  
  translate([0, 0, -handle_thickness])
  difference() {
    hull() {
      cylinder(h=handle_thickness, d=shaft_diam);
      
      translate([handle_length, 0, 0])
      cylinder(h=handle_thickness, d=shaft_diam);    
    }
    
    cylinder(h=handle_thickness, d=bore + tol);
    
    // Slot or hole for shaft attachment
    translate([0, 0, handle_thickness/2])
    rotate([90, 0, 0]) {
      cylinder(h=shaft_diam+tiny, d=coupler_screw_diam, center=true);
      translate([0, 0, -shaft_diam/2])
      cylinder(h=coupler_nut_height, d=coupler_nut_diam, $fn=6);
    }
        
    translate([handle_length, 0, 0])
    minkowski(){
      HandleHandle();
      sphere(d=loose_tol);
    }
  }
  
  translate([handle_length, 0, -handle_thickness]) {
    HandleHandle();
  }
}

module SmallGear(reverse=false) {
  herringbone_gear(
  modul=modul,
  tooth_number=ice_gear_teeth,
  width=width,
  bore=bore+tol,
  helix_angle=reverse ? -helix_angle : helix_angle,
  optimized=false    
  );
  
  translate([0, 0, width])
  ShaftCoupler();
}

module SmallShaft(handle=false) {
  h = handle ? small_shaft_length_h: small_shaft_length;
  
  translate([0, 0, small_shaft_offset])
  difference() {
    cylinder(h, d=bore);
    
    translate([0, 0, width + 0.5 *shaft_coupler_height + holder_thickness + inter_play])
    ShaftHole();
    
    if(handle) {
      translate([0, 0, h - handle_thickness/2])
      ShaftHole();
    }
  }
}

module BaseText(txt) {
  rotate([0, 0, 90])
  linear_extrude(text_depth){
    text(txt, size=text_size, halign="center", valign="top");
  }
}

module Base(){
  color("gray"){
  
  difference() {
    translate([-base_width/2 + width/2, - base_length/2, 0])
    cube([base_width, base_length, base_height]);
    
    // Holes for rubber feet
    translate([width/2, 0, 0])
    for(x = [-1, 1]) {
      for (y = [-1, 1]) {
        translate([
          x * (base_width/2 - feet_diam/2 - feet_offset), 
          y * (base_length/2 - feet_diam/2 - feet_offset),
          0
        ])
        cylinder(h=feet_depth, d=feet_diam);
    
      }
    }
  
    // Embossed text
    translate([0, 0, base_height - 1 + tiny]) {
      translate([base_width/2 - text_size/2, 0, 0]) { // TODO technically wrong bc +width
      translate([0, -ice_input_gear_x, 0])
      BaseText("OUT");

      BaseText("ICE");

      translate([0, ice_input_gear_x, 0])
      BaseText("MG2");
      }
      
      translate([-base_width/2 + width/2 + text_size + text_offset, 0, 0])
      rotate([0, 0, 180])
      BaseText("MG1");
    }
  }
  
  // Holders
  translate([0, 0, base_height]) {
    // Holder for sun shaft
    translate([-sun_shaft_length + width + holder_thickness + inter_play, 0, 0])
    ShaftHolder(sun_shaft_height);
  
    // Planet shaft
    translate([
      width + carrier_offset + carrier_height + shaft_coupler_height + inter_play,
      0, 
      0
    ])
    ShaftHolder(sun_shaft_height);
  
    // ICE shafts
    translate([
      small_shaft_offset, 
      ice_gear_x, 
      0
    ]) {
    ShaftHolder(small_first_height);
    
    translate([small_shaft_length - holder_thickness, 0, 0])
    ShaftHolder(small_first_height);
    }
    
    translate([
      small_shaft_offset, 
      ice_input_gear_x, 
      0
    ]) {
    ShaftHolder(sun_shaft_height);
    
    translate([small_shaft_length - holder_thickness, 0, 0])
    ShaftHolder(sun_shaft_height);
    }
    
    // Output shafts
    translate([
      small_shaft_offset, 
      -ice_gear_x, 
      0
    ]) {
    ShaftHolder(small_first_height);
    
    translate([small_shaft_length - holder_thickness, 0, 0])
    ShaftHolder(small_first_height);
    }
    
    translate([
      small_shaft_offset, 
      -ice_input_gear_x, 
      0
    ]) {
    ShaftHolder(sun_shaft_height);
    
    translate([small_shaft_length - holder_thickness, 0, 0])
    ShaftHolder(sun_shaft_height);
    }
    
    // Groove for guiding ring gear
    x = 8;
    y = 40;
    
    wTot = width + 2*(x + inter_play);
    
    translate([width/2, 0, 0])
    difference() {
      rotate([90, 0, 90])
      linear_extrude(wTot, center=true) {
        polygon([
          [-y/2, 0],
          [0, ring_offset + ring_diam/2],
          [y/2, 0]
        ]);
      }
      
      translate([0, 0, ring_offset + ring_diam/2]) 
      rotate([0, 90, 0]) {
        // Side walls
        cylinder(h=wTot+tiny, d=ring_diam  - rim_width - modul*2, center=true);
        
        // Inner groove
        cylinder(h=width+2*inter_play, d=ring_offset*2 + ring_diam, center=true);
      }
    }   
  }
  }
}

module Assembly() {
Base();

translate([0, 0, base_height]) {
  translate([0, 0, sun_shaft_height])
  rotate([0, 90, 0]) {
  
    translate([0, 0, width])
    rotate([180, 0, 0])
    PlanetaryGear();
    
    // Sun gear shaft
    SunShaft();

    color("green")
    translate([0, 0, -sun_shaft_length + width])
    rotate([0, 0, -45])
    rotate([180, 0, 0])
    ShaftHandle();
    
    // Planetary Gears shaft
    Carrier(); 
    
    translate([0, 0, width + carrier_offset])
    PlanetShaft();
    
    color("red")
    translate([0, 0, width + carrier_offset + planet_shaft_length])
    rotate([0, 0, 45])
    ShaftHandle();
  }

  
  // ICE gears
  translate([0, 0, small_first_height])
  rotate([0, 90, 0]) {
    // First gear
    translate([
      0, 
      ice_gear_x, 
      0
    ]) {             
      color("blue") 
      SmallGear();
      
      color("darkblue")
      SmallShaft(false);
    }
    
    // Input gear
    translate([
      (ice_gear_diam-outer_diam)/2, 
      ice_input_gear_x,//(gear_diam(outer_teeth)) / 2 + 1.5 * ice_gear_diam, 
      0
    ]) {
      //rotate([0, 0, 180 / ice_gear_teeth])
      color("blue")
      SmallGear(true);   
    
      color("darkblue")
      SmallShaft(true);
      
      color("blue")
      translate([0, 0, small_shaft_length_h - holder_thickness - inter_play])
      rotate([0, 0, 45])
      ShaftHandle();
    }
  }
  
  
  // Output gears (mirror of ICE gear)
  translate([0, 0, small_first_height])
  rotate([0, 90, 0]) {
    // First gear
    translate([
      0, 
      -ice_gear_x, 
      0
    ]) {        
      color("yellow") 
      SmallGear();
      
      color("gold")
      SmallShaft(false);
    }
    
    // Input gear
    translate([
      (ice_gear_diam-outer_diam)/2, 
      -ice_input_gear_x,
      0
    ]) {
      color("yellow")
      SmallGear(true);   
    
      color("gold")
      SmallShaft(true);
      
      color("yellow")
      translate([0, 0, small_shaft_length_h - holder_thickness - inter_play])
      rotate([0, 0, 45])
      ShaftHandle();
    }
  }
}
}

/* ------ CODE ------ */
if(selected_part == "assembly"){
  Assembly();
} else if (selected_part == "planetary_gear") {
  PlanetaryGear();
} else if (selected_part == "carrier") {
  Carrier();
} else if (selected_part == "sun_shaft") {
  SunShaft();
} else if (selected_part == "planet_shaft") {
  PlanetShaft();
} else if (selected_part == "shaft_handle") {
  ShaftHandle();
} else if (selected_part == "small_gear") {
  SmallGear();
} else if (selected_part == "small_gear_reverse") {
  SmallGear(reverse=true);
} else if (selected_part == "small_shaft") {
  SmallShaft();
} else if (selected_part == "small_shaft_h") {
  SmallShaft(true);
} else if (selected_part == "base") {
  Base();
} else {
  echo("ERROR: Unknown part!");
}
