public static class KorgNanoKontrol2 extends LXMidiRemote {
  private static final boolean DEBUG = true;
  private int channelIndex = -1;
  private LX lx;
  
  public static final int SLIDER_1 = 0;
  public static final int SLIDER_2 = 1;
  public static final int SLIDER_3 = 2;
  public static final int SLIDER_4 = 3;
  public static final int SLIDER_5 = 4;
  public static final int SLIDER_6 = 5;
  public static final int SLIDER_7 = 6;
  public static final int SLIDER_8 = 7;  

  public static final int[] SLIDERS = { SLIDER_1, SLIDER_2, SLIDER_3, SLIDER_4, SLIDER_5, SLIDER_6, SLIDER_7, SLIDER_8 };

  public static final int KNOB_1 = 16;
  public static final int KNOB_2 = 17;
  public static final int KNOB_3 = 18;
  public static final int KNOB_4 = 19;
  public static final int KNOB_5 = 20;
  public static final int KNOB_6 = 21;
  public static final int KNOB_7 = 22;
  public static final int KNOB_8 = 23;
 
  public static final int[] KNOBS = { KNOB_1, KNOB_2, KNOB_3, KNOB_4, KNOB_5, KNOB_6, KNOB_7, KNOB_8 };

  public static final int S_BUTTON_1 = 32;
  public static final int S_BUTTON_2 = 33;
  public static final int S_BUTTON_3 = 34;
  public static final int S_BUTTON_4 = 35;
  public static final int S_BUTTON_5 = 36;
  public static final int S_BUTTON_6 = 37;
  public static final int S_BUTTON_7 = 38;
  public static final int S_BUTTON_8 = 39;

  public static final int[] S_BUTTONS = { S_BUTTON_1, S_BUTTON_2, S_BUTTON_3, S_BUTTON_4, S_BUTTON_5, S_BUTTON_6, S_BUTTON_7, S_BUTTON_8 };

  public static final int M_BUTTON_1 = 48;
  public static final int M_BUTTON_2 = 49;
  public static final int M_BUTTON_3 = 50;
  public static final int M_BUTTON_4 = 51;
  public static final int M_BUTTON_5 = 52;
  public static final int M_BUTTON_6 = 53;
  public static final int M_BUTTON_7 = 54;
  public static final int M_BUTTON_8 = 55;  

  public static final int[] M_BUTTONS = { M_BUTTON_1, M_BUTTON_2, M_BUTTON_3, M_BUTTON_4, M_BUTTON_5, M_BUTTON_6, M_BUTTON_7, M_BUTTON_8 };
  
  public static final int R_BUTTON_1 = 64;
  public static final int R_BUTTON_2 = 65;
  public static final int R_BUTTON_3 = 66;
  public static final int R_BUTTON_4 = 67;
  public static final int R_BUTTON_5 = 68;
  public static final int R_BUTTON_6 = 69;
  public static final int R_BUTTON_7 = 70;
  public static final int R_BUTTON_8 = 71;  

  public static final int[] R_BUTTONS = { R_BUTTON_1, R_BUTTON_2, R_BUTTON_3, R_BUTTON_4, R_BUTTON_5, R_BUTTON_6, R_BUTTON_7, R_BUTTON_8 };

  public static final String[] DEVICE_NAMES = { "CoreMIDI4J - SLIDER/KNOB", "nanoKONTROL2", "NANOKONTROL2", "SLIDER/KNOB" };

  public static final int TRACK_LEFT = 58;
  public static final int TRACK_RIGHT = 59;
 
  public static final int CYCLE = 46;
  
  public static final int MARKER_SET = 60;
  public static final int MARKER_LEFT = 61;
  public static final int MARKER_RIGHT = 62;
  
  public static final int REWIND = 43;
  public static final int PLAY = 41;
  public static final int FORWARD = 44;
  public static final int LOOP = 49;
  public static final int STOP = 42;
  public static final int RECORD = 45;    
  
  public static boolean hasName(String name) {    
    for(String deviceName: DEVICE_NAMES) {
      if (name.contains(deviceName)) {
        return true;
      }
    }
        
    return false;
  }

  public KorgNanoKontrol2(LXMidiInput input, LX lx) {
    super(input);
    this.lx = lx;
    println("Input created! " + input.getName());    
  }

  public KorgNanoKontrol2 bindSlider(LXParameter parameter, int slider) {
    bindController(parameter, 0, SLIDERS[slider]);
    return this;
  }
  
  public KorgNanoKontrol2 unbindSliders() {
    for (int cc: SLIDERS) {
      unbindController(0, cc);
    }

    return this;
  }
  
  private int getChannelIndex() {
    if (this.channelIndex < 0) {
      this.channelIndex = 0;
    }
    
    return this.channelIndex;
  }
  
  public KorgNanoKontrol2 unbindPatternSliders() {
    for (int i = 0; i < 4; i++) {
      unbindController(0, SLIDERS[i]);
    }
    
    return this;  
  }
  
  public KorgNanoKontrol2 unbindEffectSliders() {
    for (int i = 4; i < SLIDERS.length; i++) {
      unbindController(0, SLIDERS[i]);
    }
    
    return this;  
  }

  public KorgNanoKontrol2 bindSButton(LXParameter parameter, int sButton) {
    bindController(parameter, 0, S_BUTTONS[sButton]);
    return this;
  }
  
  public KorgNanoKontrol2 unbindSButtons() {
    for (int cc: S_BUTTONS) {
      unbindController(0, cc);
    }

    return this;
  }

  public KorgNanoKontrol2 bindMButton(LXParameter parameter, int mButton) {
    bindController(parameter, 0, M_BUTTONS[mButton]);
    return this;
  }
  
  public KorgNanoKontrol2 unbindMButtons() {
    for (int cc: M_BUTTONS) {
      unbindController(0, cc);
    }

    return this;
  }
  
  public KorgNanoKontrol2 bindRButton(LXParameter parameter, int rButton) {
    bindController(parameter, 0, R_BUTTONS[rButton]);
    return this;
  }
  
  public KorgNanoKontrol2 unbindRButtons() {
    for (int cc: R_BUTTONS) {
      unbindController(0, cc);
    }

    return this;
  }

  public KorgNanoKontrol2 bindKnob(LXParameter parameter, int knob) {
    bindController(parameter, 0, KNOBS[knob]);
    return this;
  }
  
  public KorgNanoKontrol2 unbindKnobs() {
    for (int cc: KNOBS) {
      unbindController(0, cc);
    }

    return this;
  }
  
  public KorgNanoKontrol2 bindKnobsAndSlidersToPattern(LXPattern pattern) {
    List<LXParameter> patternParameters = new ArrayList<LXParameter>(pattern.getParameters());
    
    if (DEBUG) {
      println("Attempting to bind knobs and sliders to pattern: " + pattern.getLabel());
      println("The pattern has this many parameters: " + patternParameters.size());
      println("Is my channel enabled? : " + this.getInput().enabled.getValueb());
    }
    
    if(patternParameters.size() == 0) { return this; }
    
    int maxKnobs = KorgNanoKontrol2.KNOBS.length;
    int maxSliders = KorgNanoKontrol2.SLIDERS.length;    
    int knobIndex = 0;
    int sliderIndex = 0;
    
    for(LXParameter parameter: patternParameters) {
      if (!(parameter instanceof LXListenableNormalizedParameter)) {
        if (DEBUG) {
          println("Skipping parameter, not instance of LXListenableNormalizedParameter: " + parameter.getLabel());
        }
        continue;
      }
      
      if (lx.engine.audio.enabled.getValueb() && (parameter instanceof LEDomeAudioParameter)) {
        if (DEBUG) {
          println("Skipping parameter, audio enabled and is LEDomeAudioParameter: " + parameter.getLabel());
        }
        continue;
      }
      
      if (knobIndex < maxKnobs) {
        if (DEBUG) {
          println("Binding knob " +  knobIndex + " to " + parameter.getLabel());
        }
        this.bindKnob(parameter, knobIndex);
        knobIndex++;
      } else if (sliderIndex < maxSliders) {
        if (DEBUG) {
          println("Binding slider " +  sliderIndex + " to " + parameter.getLabel());
        }
        this.bindSlider(parameter, sliderIndex);
        sliderIndex++;
      } else {
        // We have bound all we can bind
        break;
      }
    }
    
    return this;
  }
  
  public KorgNanoKontrol2 unbindPatternKnobsAndSliders() {
    this.unbindKnobs();
    this.unbindPatternSliders();
    
    return this;
  }
}
  
/**
 * The LEDomeMidiListener connects the midi controller to the interface.
 */
public class KorgNanoKontrol2MidiListener implements LXMidiListener, LXChannel.Listener {
  private boolean DEBUG = true;   
  private LX lx;
  private KorgNanoKontrol2 nanoKontrol2;
 

 public KorgNanoKontrol2MidiListener(LX lx, KorgNanoKontrol2 nanoKontrol2) {
   this.lx = lx;
   this.nanoKontrol2 = nanoKontrol2;
 }
 
 public void aftertouchReceived(MidiAftertouch aftertouch) {
   if (DEBUG) {
     println("aftertouchReceived aftertouch: " + aftertouch.getAftertouch());
   }
 } 
           
 public void controlChangeReceived(MidiControlChange cc) {   
   // Wire up specific buttons.
   // Bind does not work for toggling as the value toggles both ways on each key press.
   switch(cc.getCC()) {
     case KorgNanoKontrol2.MARKER_SET:   
       if (cc.getValue() > 0) { lx.engine.audio.enabled.toggle(); }
       break;
     case KorgNanoKontrol2.MARKER_LEFT:
     case KorgNanoKontrol2.TRACK_LEFT:
     case KorgNanoKontrol2.REWIND:     
       if (cc.getValue() > 0) { lx.goPrev(); }
       break;
     case KorgNanoKontrol2.MARKER_RIGHT:
     case KorgNanoKontrol2.TRACK_RIGHT:
     case KorgNanoKontrol2.FORWARD:
       if (cc.getValue() > 0) { lx.goNext(); }
       break;
     case KorgNanoKontrol2.CYCLE:
       if (cc.getValue() > 0) { lx.engine.getDefaultChannel().autoCycleEnabled.toggle(); }
       break;
     case KorgNanoKontrol2.R_BUTTON_8:
       if (cc.getValue() > 0) {
         for(LXPattern pattern: lx.getPatterns()) {          
           if (pattern instanceof LEDomePattern) { 
             ((LEDomePattern)pattern).reset(); 
           } else {
             for(LXParameter param: pattern.getParameters()) {
               if (!(param instanceof LXListenableNormalizedParameter)) { continue; }
               param.reset();  
             }
           }
         }
       }
       break;      
   }

   if (DEBUG) {
     println("controlChangeReceived cc: " + cc.getCC());
     println("controlChangeReceived value: " + cc.getValue());
   }
 } 
           
 public void noteOffReceived(MidiNote note) {
   if (DEBUG) {
     println("noteOffReceived pitch: " + note.getPitch());
     println("noteOffReceived velocity: " + note.getVelocity());  
   }   
 } 
           
 public void noteOnReceived(MidiNoteOn note) {
   if (DEBUG) {
     println("noteOnReceived pitch: " + note.getPitch());
     println("noteOnReceived velocity: " + note.getVelocity());
   } 
 } 
           
 public void pitchBendReceived(MidiPitchBend pitchBend) {
   if (DEBUG) {
     println("noteOnReceived pitch: " + pitchBend.getPitchBend());
   }  
 } 
           
 public void programChangeReceived(MidiProgramChange pc) {
   if (DEBUG) {
     println("LXMidiProgramChange pitch: " + pc.getProgram());
   }
 }
 
 public void effectAdded(LXBus channel, LXEffect effect) {} 
           
 public void effectRemoved(LXBus channel, LXEffect effect) {}
 
 public void effectMoved(LXBus channel, LXEffect effect) {}
           
 public void patternAdded(LXChannel channel, LXPattern pattern) {} 
           
 public void patternDidChange(LXChannel channel, LXPattern pattern) {
   if (nanoKontrol2 == null) { return; }
      
   println("The focused Channel index is: " + ((LXChannel)lx.engine.getFocusedChannel()).getIndex());
   nanoKontrol2.unbindPatternKnobsAndSliders();
   nanoKontrol2.bindKnobsAndSlidersToPattern(pattern);
 } 
           
 public void patternRemoved(LXChannel channel, LXPattern pattern) {}
 
 public void patternMoved(LXChannel channel, LXPattern pattern) {}
           
 public void patternWillChange(LXChannel channel, LXPattern pattern, LXPattern nextPattern) {}
 
 public void indexChanged(LXChannel channel) {}
}