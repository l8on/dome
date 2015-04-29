/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This implements the standard `setup` and `draw` methods of a 
 * Processing sketch. It instantiates LEDome model and the sets
 * up the DDP output to the NDB. This file should only be changed 
 * by people who know what their doing.
 */

LEDome model;
P2LX lx;
WB_Render render;

/*
*/

void setupPatterns() {
  lx.setPatterns(patterns(lx));  
}


void setup() {
  size(800, 600, OPENGL);
  smooth(8);
  textSize(6);
  
  model = new LEDome();
  
  // Create the P2LX engine
  lx = new P2LX(this, model);  
  setupPatterns();
  setupUI();
//  setupOutput();
  
  render = new WB_Render(this);  
}

void setupUI() {
  lx.ui.addLayer(
    // A camera layer makes an OpenGL layer that we can easily 
    // pivot around with the mouse
    new UI3dContext(lx.ui) {
      protected void beforeDraw(UI ui, PGraphics pg) {
        // Let's add lighting and depth-testing to our 3-D simulation
        pointLight(0, 0, 40, model.cx, model.cy, -20*FEET);
        pointLight(0, 0, 50, model.cx, model.yMax + 10*FEET, model.cz);
        pointLight(0, 0, 20, model.cx, model.yMin - 10*FEET, model.cz);
        hint(ENABLE_DEPTH_TEST);
      }
      protected void afterDraw(UI ui, PGraphics pg) {
        // Turn off the lights and kill depth testing before the 2D layers
        noLights();
        hint(DISABLE_DEPTH_TEST);
      } 
    }
  
    // Let's look at the center of our model
    .setCenter(model.cx, model.cy, model.cz)
  
    // Let's position our eye some distance away
    .setRadius(22*FEET)
    
    // And look at it from a bit of an angle
    .setTheta(PI/24)
    .setPhi(PI/24)
    
    .setRotateVelocity(12*PI)
    .setRotateAcceleration(3*PI)
    
    // Let's add a point cloud of our animation points
    .addComponent(new UIPointCloud(lx, model).setPointWeight(3))
    
    .addComponent(new UIDome())
  );
  
  // A basic built-in 2-D control for a channel
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx.engine.getChannel(0), 4, 4));
  lx.ui.addLayer(new UIEngineControl(lx.ui, 4, 326));
  lx.ui.addLayer(new UIComponentsDemo(lx.ui, width-144, 4));
}

void setupOutput() {
  int[] points = new int[NUM_CONNECTED_LIGHTS];
  for (int i = 0; i < points.length; ++i) {
    points[i] = i;
  }
  
  try {
    LXDatagramOutput output = new LXDatagramOutput(lx);
    DDPDatagram datagram = (DDPDatagram)new DDPDatagram(points).setAddress("10.0.0.116"); // whatever the IP is
    output.addDatagram(datagram);
    lx.addOutput(output);
  } catch (Exception x) {
    x.printStackTrace();
  }  
}

void draw() {
  background(#292929);  
}

void mousePressed() {
  println("mouseX:" + mouseX + ", mouseY: " + mouseY);  
}