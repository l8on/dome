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


import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.Line;
import javax.sound.sampled.Mixer;
import javax.sound.sampled.TargetDataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.LineUnavailableException;

import javax.sound.midi.ShortMessage;
import javax.sound.midi.MidiSystem;
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

// The raspberry pi can't render 3d out of the box.
// Set RENDER_3D to false to avoid using OpenGL.
// TODO: see if this is true any more with processing 3
final static boolean RENDER_3D = true;
final static int AUTO_TRANSITION_SECONDS = 45;  

LEDome model;
LXStudio lx;

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
    new BeatDancers(lx),
    new ClapDancers(lx),
    
    // L8on
    new L8onMixColor(lx),    
    new DomeEQ(lx),
    new DomeInvertEQ(lx),
    new JumpRopes(lx),
    new Marbles(lx),
    new Explosions(lx),
    new Darksplosions(lx),
    new AudioBelts(lx),    
    new Snakes(lx),
    new SnakeApple(lx),
    new SpotLights(lx),
    new DarkLights(lx),    
    new Life(lx),
    new HeartsBeat(lx),
    new Balls(lx),
    new DarkBalls(lx),
    new SurroundWave(lx),
    new ThunderStorm(lx),
    new SpinEQ(lx),
    new SunriseSunsetRainbow(lx),
    new SunriseSunsetReal(lx),
    new SunriseSunsetStargaze(lx),

    // Cackler
    new Stargaze(lx),
    new ColorSpiral(lx),
    new Rings(lx),

    // Kristján
    //new Disco(lx),

    // pld
    new Spiral(lx),

    // rohan
    //new Sunshine(lx),
    //new SunshineHalf(lx),

    // Test Patterns
    new LayerDemoPattern(lx),
//    new FaceIteratorTest(lx),
//    new EdgeIteratorTest(lx), 
//    new HueTestPattern(lx),
//    new IteratorTestPattern(lx)
  };
}

WB_Render render;
LEDomeOutputManager outputManager;
LEDomeAudioParameterManager audioParameterManager;
KorgNanoKontrol2 nanoKontrol2 = null;
LXStudio.UI lxUI = null;
// TODO: get C-Media audio card and create class to manage input

void settings() {
  size(1024, 768, P3D);  
}

void setup() { 
  surface.setResizable(true);
  if (RENDER_3D) {
    surface.setSize(displayWidth, displayHeight);
  }        

  // Create LEDome instance
  model = new LEDome();
  // Create the LXStudio engine 
  lx = new LXStudio(this, model) {
    @Override
    protected void initialize(LXStudio lx, LXStudio.UI ui) {
      // Add custom LXComponents or LXOutput objects to the engine here,
      // before the UI is constructed
      
      // Create the NDB output manager
      outputManager = new LEDomeOutputManager(lx);  
      outputManager.addLXOutputForNDB();
      
      // Find CableCreation input if available and set by default
      String[] deviceNames = lx.engine.audio.input.device.getOptions();
      for (int i = 0; i < deviceNames.length; i++) {
        if(deviceNames[i].startsWith("CableCreation")) {
          lx.engine.audio.input.device.setValue(i);
        }
      }
    }
    
    @Override
    protected void onUIReady(LXStudio lx, LXStudio.UI ui) {
      // The UI is now ready, can add custom UI components if desired
      lxUI = ui;
      if (RENDER_3D) {
        ui.preview.addComponent(new UIDome());
      } else {
        ui.removeLayer(ui.preview);  
      }
    }
  };
  
  // Create audio parameter manager before setting up patterns so the listner will work out of the box
  audioParameterManager = new LEDomeAudioParameterManager(lx, lx.engine.audio.enabled);
  
  setupPatterns();
  setupEffects();  
  setupMidiDevices();
  
  if (RENDER_3D) {
    lx.engine.output.enabled.setValue(false);    
  } else {
    // Start up network output immediately if no 3d
    lx.engine.output.enabled.setValue(true);
    lx.enableAutoTransition(AUTO_TRANSITION_SECONDS);
  }
  
  // Set the hue mode of the palette to cycle through all the colors.  
  lx.palette.hueMode.setValue(2);
  
  LXChannel channel = (LXChannel)lx.engine.getFocusedChannel(); 
  channel.transitionEnabled.setValue(true);
  channel.transitionTimeSecs.setValue(3);
  
  // Set the audio input to be on by default
  if (lx.engine.audio.input.device.getRange() > 0 || RENDER_3D) {
    lx.engine.audio.enabled.setValue(true);
  }
}

void setupPatterns() {
  LXPattern[] domePatterns = patterns(lx);
  LXChannel channel = (LXChannel)lx.engine.getFocusedChannel();  
  // LXStudio has to load with at least 1 pattern.
  // We save it here so we can remove it immediately.
  LXPattern initalPattern = channel.getPatterns().get(0);
  
  // Add all patterns from the main list.
  for (LXPattern pattern: domePatterns) {    
    channel.addPattern(pattern);    
  }
  
  // Remove the initial pattern
  channel.removePattern(initalPattern);
}

void setupEffects() {
  lx.addEffects(effects(lx));  
}

TargetDataLine findCableCreationTargetDataLine(AudioFormat  format) {
  DataLine.Info info = new DataLine.Info(TargetDataLine.class, format);  
  TargetDataLine.Info cableCreationTargetInfo = null;
  Mixer cableCreationMixer = null;
  Mixer.Info[] mixers = AudioSystem.getMixerInfo();    
  
  for (Mixer.Info mixerInfo : mixers) {
    System.out.println("Found Mixer: " + mixerInfo);
    System.out.println("Mixer name: " + mixerInfo.getName());
    if(mixerInfo.getName().startsWith("CableCreation")) { 
      System.out.println("Found CableCreation mixer");
      cableCreationMixer = AudioSystem.getMixer(mixerInfo);
      Line.Info[] lines = cableCreationMixer.getTargetLineInfo(info);
      cableCreationTargetInfo = (TargetDataLine.Info) lines[0];
      break;
    }
  }
  
  if(cableCreationTargetInfo == null || cableCreationMixer == null) { 
    return null; 
  }
  
  try {
    return (TargetDataLine) cableCreationMixer.getLine(cableCreationTargetInfo);
  } catch(LineUnavailableException x) {
    System.err.println(x.getLocalizedMessage());
    return null;
  }
}

void setupMidiDevices() {
  MidiDevice.Info[] deviceInfos = MidiSystem.getMidiDeviceInfo();
  println("There are " + deviceInfos.length + " midi devices");
  
  for (MidiDevice.Info deviceInfo : CoreMidiDeviceProvider.getMidiDeviceInfo()) {
  //for (MidiDevice.Info deviceInfo : MidiSystem.getMidiDeviceInfo()) {
    println("Here be a midi device: " + deviceInfo.getName());
    //try {
    //  MidiDevice device = MidiSystem.getMidiDevice(deviceInfo);
    //  println("Here be a midi device: " + deviceInfo);
    //  //if (device.getMaxTransmitters() != 0) {
    //  //  mutableInputs.add(new LXMidiInput(LXMidiEngine.this, device));
    //  //}
    //  //if (device.getMaxReceivers() != 0) {
    //  //  mutableOutputs.add(new LXMidiOutput(LXMidiEngine.this, device));
    //  //}
    //} catch (MidiUnavailableException mux) {
    //  mux.printStackTrace();
    //}
  }
  
  LXMidiInput korgNanoControl2Input = lx.engine.midi.matchInput(KorgNanoKontrol2.DEVICE_NAMES);  
  if (korgNanoControl2Input == null) {
    println("Midi Remote not connected");
    return;
  }
  
  nanoKontrol2 = new KorgNanoKontrol2(korgNanoControl2Input, lx);
  korgNanoControl2Input.addListener(new KorgNanoKontrol2MidiListener(lx, nanoKontrol2));
  lx.engine.getDefaultChannel().addListener(new KorgNanoKontrol2MidiListener(lx, nanoKontrol2));
  nanoKontrol2.getInput().open();
  
  println("The device is connected?");
}


// LXStudio handles all the drawing.
void draw() {
}

LXEffect[] effects(P3LX lx) {
  return new LXEffect[] {
    new ExplosionEffect(lx),
    new FlashEffect(lx),
    new DesaturationEffect(lx),
    new BlurEffect(lx)
  };
}