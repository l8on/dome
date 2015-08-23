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
 
import java.awt.Dimension;
import java.awt.Toolkit;

// The raspberry pi can't render 3d out of the box.
// Set RENDER_3D to false to avoid using OpenGL.
final boolean RENDER_3D = true;

Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
final int VIEWPORT_WIDTH = (int)screenSize.getWidth();;
final int VIEWPORT_HEIGHT = (int)screenSize.getHeight();

LEDome model;
P2LX lx;
WB_Render render;
LEDomeOutputManager outputManager;
BooleanParameter ndbOutputParameter;
KorgNanoKontrol2 nanoKontrol2 = null;

/*
 * Setup methods. Sets stuff up.
 */
void setup() {
  if (RENDER_3D) {
    size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  } else {
    size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
  }

  frame.setResizable(true);
  noSmooth();
  textSize(6);

  // Create LEDome instance
  model = new LEDome();  
  // Create the P2LX engine
  lx = new P2LX(this, model);    
  // Create the NDB output manager
  ndbOutputParameter = new BooleanParameter("NDB", false);
  outputManager = new LEDomeOutputManager(lx, ndbOutputParameter);

  setupPatterns();
  setupEffects();
  setupUI();
  setupMidiDevices();

  if (RENDER_3D) {
    render = new WB_Render(this);
  } else { 
    // Start up network output immediately if no 3d
    ndbOutputParameter.setValue(true);
    lx.engine.getDefaultChannel().autoTransitionEnabled.setValue(true);
  }
}

void setupPatterns() {
  LXPattern[] domePatterns = patterns(lx);
  for (LXPattern pattern: domePatterns) {
    pattern.setTransition(new DissolveTransition(lx));
  }  
  lx.setPatterns(domePatterns);
}

void setupEffects() {
  lx.addEffects(effects(lx));  
}

void setupUI() {
  if (RENDER_3D) {
    lx.ui.addLayer(
      // A camera layer makes an OpenGL layer that we can easily 
      // pivot around with the mousee
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
      
      .setRotationVelocity(12*PI)
      .setRotationAcceleration(3*PI)
      
      // Let's add a point cloud of our animation points
      .addComponent(new UIPointCloud(lx, model).setPointSize(3))
      
      .addComponent(new UIDome())
    );
  }
  
  // A basic built-in 2-D control for a channel
  lx.ui.addLayer(new UIChannelControl(lx.ui, lx.engine.getDefaultChannel(), 4, 4));
  lx.ui.addLayer(new LEDomeNDBOutputControl(lx.ui, 4, 326));
  lx.ui.addLayer(new UIEffectsControl(lx.ui, lx, width-144, 4));
}

List<String> NANO_NAMES = new ArrayList<String>();
void initNanoNames() {
  NANO_NAMES.add("SLIDER/KNOB");
}

void setupMidiDevices() {
  initNanoNames();
  
  try {    
    // Loop through inputs and find one we recognize.
    for (MidiDevice device : LXMidiSystem.getInputs()) {
      LXMidiInput lxMidiInput = new LXMidiInput(lx, device);
      // Add all inputs to engine to ensure proper functionality.
      lx.engine.midiEngine.addInput(lxMidiInput);      
      
      // Is it the Korg nanoKontrol2 ?
      if (KorgNanoKontrol2.hasName(device.getDeviceInfo().getName())) {
        nanoKontrol2 = new KorgNanoKontrol2(lxMidiInput);
        // Connect knobs to midi device events
        lxMidiInput.addListener(new KorgNanoKontrol2MidiListener(lx));
        // Listen to pattern so knobs can be connected to pattern parameters.
        lx.engine.getDefaultChannel().addListener(new KorgNanoKontrol2MidiListener(lx));
      }
            
    }
  
    // No nanoKontrol is connected, return
    if (nanoKontrol2 == null) { return; }
    
    // Listen to each effect to connect the last 4 sliders to the latest effect.
    for (LXEffect effect: lx.engine.getEffects()) {
      effect.enabled.addListener(new KorgNanoKontrol2EffectParameterListener(effect));  
    }
    
  } catch (MidiUnavailableException mux) {
    mux.printStackTrace();  
  }
}


void draw() {
  background(#292929);  
}

void mousePressed() {
  println("mouseX:" + mouseX + ", mouseY: " + mouseY);  
}
