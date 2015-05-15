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
import heronarts.lx.model.*;
import heronarts.lx.modulator.*;
import heronarts.lx.output.*;
import heronarts.lx.parameter.*;
import heronarts.lx.pattern.*;
import heronarts.lx.transition.*;
import heronarts.p2lx.*;
import heronarts.p2lx.ui.*;
import heronarts.p2lx.ui.control.*;
import heronarts.p2lx.ui.component.*;
import ddf.minim.*;
import processing.opengl.*;
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.Random;

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

LXPattern[] patterns(P2LX lx) {
  return new LXPattern[] {
    // Create New Pattern Instances Below HERE

    // L8on
    new Explosions(lx),
    new SpotLights(lx),
    new Life(lx),
    new L8onMixColor(lx),

    // Test Patterns
    new LayerDemoPattern(lx),
    new IteratorTestPattern(lx).setTransition(new DissolveTransition(lx))
  };
}

LXEffect[] effects(P2LX lx) {
  return new LXEffect[] {    
    new ExplosionEffect(lx),
    new FlashEffect(lx),
    new DesaturationEffect(lx), 
    new BlurEffect(lx)
  };
}
