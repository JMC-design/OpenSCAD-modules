//// PARAMETERS

//subtracted or added from diameters based on your printer tolerances
printer_outer_tolerance = 0;
printer_inner_tolerance = 0;

// conveniences
x  = [1,0,0];
_x = [-1,0,0];
y  = [0,1,0];
_y = [0,-1,0];
z  = [0,0,1];
_z = [0,0,-1];
zero = [0,0,0];

// Mortises :todo fn+convenience+multiple
mortise_id = 3;
mortise_thickness = mortise_id / 3;
mortise_od = mortise_id + mortise_thickness+2;
mortise_depth = 1.5 * mortise_id;
mortise_length = 2 * mortise_depth;
mortise_faces = 60;
//function mortise(id=3,thickness=id/3)= [id,thickness];
//module mortise(id=3,thickness=id/3) [id,thickness]
//echo(mortise());

// Bore :todo specify shape, share code with mortise?

bored = mortise_id+1; //.5 is a tight fit

// Hubs :todo specify in connector, shapes from mortises?

hub_diameter = //[5,4,4];
  1 * mortise_od;
hub_shape = "circle";


//// MODULES

// stupidly convoluted manner to turn hulling on or off.

module to_hull(hully){//:fixme hully?
  if (hully)
    {hull()children();
    }
  else
    {children ();
    }
}

// We construct all mortises rotated about the x-axis first, this puts them in place

module rotate_to_axis (axis){
  if (axis==x){children ();}
  else if (axis==y){rotate ([0,0,90])children ();} // :fixme this is where we'd dictate standard behaviour
  else if (axis==z){rotate ([0,-90,0])children ();}
}

// convenience functions

function rotation(axis) = axis[0];
function n(axis)        = axis[1];
function angle(axis)    = axis[2];
function incline(axis)  = axis[3];
function start(axis)    = axis[4];

function axis(rotation=x,n=1,angle=90,incline=0,start=0) = [rotation,n,angle,incline,start];

module draw_axes(axes,diameter,depth){
  for(axis=axes){
    interval = angle(axis);
    end = (n(axis)*interval)-1;
    start = start(axis);
    angle = angle(axis);
    
    rotate_to_axis (rotation(axis)){
      for(i=[start:angle:end+start]){ //:fixme -1
	rotate([i,0,0])
	  rotate([0,incline(axis),0])
	  translate([0,0,depth]) cylinder(d=diameter,h=mortise_length,$fn=mortise_faces);
	echo (i);
      }
    }
  }
}

module connector(axes,shape=hub_shape,bore,hull){
  difference (){
    to_hull(hull){
      union (){
	draw_axes(axes,mortise_od,0);
	if(shape=="circle"){
	  sphere(d=hub_diameter,$fs=.1);}
	if(shape=="square"){
	  cube(hub_diameter,center=true);     
	}
      }}
    if (bore){
      rotate(bore * 90)cylinder(d=bored,h=2*hub_diameter,center=true,$fs=.5);
    }
    draw_axes(axes,mortise_id,mortise_depth);     
  }
}


//// Examples

// Let's start with the basics, there are currently two main parts with more to come.

// First we have the function axis() which needs to be renamed and returns an array description of how mortises should be distributed about an axis.

//function axis(rotation=x,n=1,angle=90,incline=0,start=0) = [rotation,n,angle,incline,start];

// As you can see it simply packages up some variables into an array.
// There's also some convenience functions so you don't have to remember which parameter is stored where. They are conveniently name exactly as the parameters to axis. :fixme some of these need to be renamed.

// At the top level is the module CONNECTOR, which takes a VECTOR[] of axes.
// The default is not very exciting but could be used as a tpu protective cover for a round stool leg

//connector([axis()]);

// As you can see it stands straight up. We're rotating about the x axis by default. Both X and Y start from positive Z, Z starts from negative X. This is an OpenSCAD thing. :fixme standardize behaviour?

// Well, that's very boring. Let's connect 2 things!

//connector([axis(n=2)]);

// Our second mortise is pointing to negative Y. We are rotating counterclockwise or following the right hand rule. The default angle is 90 degrees.

// ok, we can make a square, but that's not very exciting. How about the simplest 3d shape to make, which is not the simplest 3d shape, a cube

//connector([axis(n=2),axis(z)]);

// What about an eight-way connector? like a tinkertoy!

//connector([axis(n=4,start=45),axis(n=4)],hull=true,bore=y); //:fixme rotation is wrong

// We could have done this with 1 axis description, but this is to show that you can have more than 1 about the same axis.  When the ability to specify mortise shapes and sizes gets added this can come in handy.

// We've also introduced two new parameters.
// When HULL is set to true the shapes that make up the connector are hulled.  This makes for support free printing.
// When an axis is specified for BORE, a hole is bored through that axis. In the future bore shape/size will be able to be specified without changing variables.

// That wasn't so hard right?  Now for something a little more complicated.



//// V2 Dome

//  What if we want to make a dome? https://geo-dome.co.uk/2v_tool.asp
// We need two connectors, one for five spokes, and one for six. They have different angles of inclination.
// Since we are making half a sphere we also need a 4 spoke connector

// You will need:
// Hub4 x 10
// Hub5 x 6
// Hub6 x 10

// // Hub5
// translate(x*20)
// connector([axis(z,5,360/5,90-74)],hull=true); //5

// // Hub4
// translate(x*-40)
// connector([[z,4,60,18,90]],hull=true); //4 base :fixme this isn't right either, but 2% difference doesn't do much

// // Hub6
// hub6 = axis(z,6,360/6,90-72);//:fixme on website 2 of the spokes are connect at 16 (those that connect to 5hubs)

// translate(x*-20)
// connector([hub6],shape="square",hull=true,bore=z); 


//BONUS if we want to make a straight walled pagoda at top.

// we need to modify a 6 hub connector, do some complicated thinking to come up with a really simple solution, and get a spoke to connect perpendicular to the ground dependent on where we want the hub to be in space.
// To add a pagoda you will need:
// Floor x 5 ; these replace the top 5 hub6s in the normal dome
// Ceiling x 5
// an extra Hub 5 if you closed the dome beneath the pagoda

// // Floor
// translate(x*40)
// connector([hub6,          // our regular 6 hub 
// 	   axis(incline=90-74,start=180)], // extra slot up top
// 	  hull=true);

// // Ceiling 
// connector([axis(z,2,180-(360/5)),  // connect to sides
// 	      [z,1,1,-90-74,234],     // connect to top :tip we don't need to use axis() if we nerdly remember the order of the parameters in the vector.
// 	      axis()],                // connect to bottom
// 	  hull=true);

