/**
 *  Importing a bunch of stuff.
 *  Artists, keep scrolling to  add your patterns.
 */
import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;
import heronarts.lx.*;
import heronarts.lx.audio.*;
import heronarts.lx.color.*;
import heronarts.lx.effect.*;
import heronarts.lx.midi.*;
import heronarts.lx.model.*;
import heronarts.lx.modulator.*;
import heronarts.lx.output.*;
import heronarts.lx.parameter.*;
import heronarts.lx.pattern.*;
import heronarts.p3lx.*;
import heronarts.p3lx.ui.*;
import heronarts.p3lx.ui.control.*;
import heronarts.p3lx.ui.component.*;

import java.util.Arrays;
import java.util.List;
import java.util.Collections;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.Random;

import javax.sound.midi.ShortMessage;
import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiUnavailableException;

/** 
 * This is the code to be thrown at LEDome! 
 * 
 * This Processing sketch is a fun place to build animations, effects, and 
 * interactions for the LEDome. Most of the ugly modeling and mapping code 
 * is contained in the LEDome class and setup files.
 * artist, you shouldn't need to worry about any of that.
 *
 * Below, you will find definitions of the Patterns, (and eventually) Effects, 
 * and Interactions.
 *
 * If you're an artist, create a new tab in the Processing environment with
 * your name. Implement your classes there, and add them to the list below.
 */
 
 
//Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
//final int VIEWPORT_WIDTH = (int)screenSize.getWidth();;
//final int VIEWPORT_HEIGHT = (int)screenSize.getHeight();

// The raspberry pi can't render 3d out of the box.
// Set RENDER_3D to false to avoid using OpenGL.
final static boolean RENDER_3D = true;
final static int AUTO_TRANSITION_SECONDS = 30;

LEDome model;
LXStudio lx;

WB_Render render;
LEDomeOutputManager outputManager;
BooleanParameter ndbOutputParameter;
KorgNanoKontrol2 nanoKontrol2 = null;

void settings() {
  size(1024, 768, P3D);
  //if (RENDER_3D) {
  //  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, P3D);
  //} else {
  //  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
  //
  noSmooth();  
}

void setup() { 
  surface.setResizable(true);
  textSize(6);

  // Create LEDome instance
  model = new LEDome();
  // Create the LXStudio engine 
  lx = new LXStudio(this, model) {
    @Override
    protected void initialize(LXStudio lx, LXStudio.UI ui) {
      // Add custom LXComponents or LXOutput objects to the engine here,
      // before the UI is constructed
      // Create the NDB output manager
      ndbOutputParameter = new BooleanParameter("NDB", false);
      outputManager = new LEDomeOutputManager(lx, ndbOutputParameter);  
      outputManager.addLXOutputForNDB();
    }
    
    @Override
    protected void onUIReady(LXStudio lx, LXStudio.UI ui) {
      // The UI is now ready, can add custom UI components if desired
      //ui.preview.addComponent(new UIWalls());  
      ui.preview.addComponent(new UIDome());
    }     
  };
   

  setupPatterns();
  setupEffects();  
  setupMidiDevices();
  
  println("model center x: " + model.cx);
  println("model center y: " + model.cy);
  println("model center z: " + model.cz);
  
  if (RENDER_3D) {
    lx.engine.output.enabled.setValue(false);
    //render = new WB_Render(this);
  } else { 
    // Start up network output immediately if no 3d
    lx.engine.output.enabled.setValue(true);
    lx.enableAutoTransition(AUTO_TRANSITION_SECONDS);
  }
}
// LXStudio handles all the drawing.
void draw() {
}

LXPattern[] patterns(P3LX lx) {
  return new LXPattern[] {
             
    // Create New Pattern Instances Below HERE
    new ShadyWaffle(lx),
    
    // Slee
    new ClockPattern(lx),
    
    // BKudria
    new Beachball(lx),
    new Breather(lx),

    // Heather
    new Dancers(lx),
    
    // L8on
    new JumpRopes(lx),
    new Explosions(lx),
    new SnakeApple(lx),
    new Snakes(lx),
    new SpotLights(lx),
    new HeartsBeat(lx),
    new DarkLights(lx),
    new Life(lx),
    new L8onMixColor(lx),
    
    // Cackler
    new ColorSpiral(lx),
    new Stargaze(lx),

    // Kristján
    new Disco(lx),    

    // pld
    new Spiral(lx),
    
    // rohan
    new Sunshine(lx),
    new SunshineHalf(lx),

    // Test Patterns
    new LayerDemoPattern(lx),
//    new FaceIteratorTest(lx),
//    new EdgeIteratorTest(lx), 
//    new HueTestPattern(lx),
//    new IteratorTestPattern(lx)
  };
}

LXEffect[] effects(P3LX lx) {
  return new LXEffect[] {
    new ExplosionEffect(lx),
    new FlashEffect(lx),
    new DesaturationEffect(lx), 
    new BlurEffect(lx)
  };
}