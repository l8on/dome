public static class KorgNanoKontrol2 extends LXMidiDevice {

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

  public static final String[] DEVICE_NAMES = { "SLIDER/KNOB", "nanoKONTROL2", "NANOKONTROL2", };

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

  public static MidiDevice matchInputDevice() {
    return LXMidiSystem.matchInputDevice(DEVICE_NAMES);
  }

  public static KorgNanoKontrol2 getNanoKontrol2(LX lx) {
    LXMidiInput input = LXMidiSystem.matchInput(lx, DEVICE_NAMES);    
    if (input != null) {
      return new KorgNanoKontrol2(input);
    }    
    return null;
  }
  
  public static boolean hasName(String name) {    
    for(String deviceName: DEVICE_NAMES) {
      if (name.contains(deviceName)) {        
        return true;
      }
    }
        
    return false;
  }

  public KorgNanoKontrol2(LXMidiInput input) {
    super(input);
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
    List<LXParameter> patternParameters = pattern.getParameters();
    if(patternParameters.size() == 0) { return this; }
    
    int numKnobs = min(KorgNanoKontrol2.KNOBS.length, patternParameters.size());
    int numSliders = min(KorgNanoKontrol2.SLIDERS.length, patternParameters.size() - KorgNanoKontrol2.KNOBS.length);

    for(int i = 0; i < numKnobs; i++) {
      this.bindKnob(patternParameters.get(i), i);
    }
    
    for(int j = 0; j < numSliders; j++) {
      this.bindSlider(patternParameters.get(j + numKnobs), j);
    }
    
    return this;
  }
  
  public KorgNanoKontrol2 unbindPatternKnobsAndSliders() {
    this.unbindKnobs();
    this.unbindPatternSliders();
    
    return this;
  }
  
  public KorgNanoKontrol2 bindSlidersToEffect(LXEffect effect) {
    List<LXParameter> effectParameters = effect.getParameters();
    if(effectParameters.size() == 0) { return this; }
        
    int numSliders = min(4, effectParameters.size());

    for(int i = 0; i < numSliders; i++) {
      this.bindSlider(effectParameters.get(i), i + 4);
    }
    return this;
  }
}
  
/**
 * The LEDomeMidiListener connects the midi controller to the interface.
 */
public class KorgNanoKontrol2MidiListener implements LXMidiListener, LXChannel.Listener {
  private boolean DEBUG = false;   
  private LX lx;
 

 public KorgNanoKontrol2MidiListener(LX lx) {
   this.lx = lx;
 }
 
 public void aftertouchReceived(LXMidiAftertouch aftertouch) {
   if (DEBUG) {
     println("aftertouchReceived aftertouch: " + aftertouch.getAftertouch());
   }
 } 
           
 public void controlChangeReceived(LXMidiControlChange cc) {   
   // Wire up specific buttons.
   // Bind does not work for toggling as the value toggle both ways on each key press.
   switch(cc.getCC()) {
     case KorgNanoKontrol2.MARKER_SET:
       if (cc.getValue() > 0) { ndbOutputParameter.toggle(); }
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
       if (cc.getValue() > 0) { lx.engine.getDefaultChannel().autoTransitionEnabled.toggle(); }
       break;
     case KorgNanoKontrol2.R_BUTTON_8:
       if (cc.getValue() > 0) { lx.setPatterns(patterns((P2LX)lx)); }
       break;      
   }

   if (DEBUG) {
     println("controlChangeReceived cc: " + cc.getCC());
     println("controlChangeReceived value: " + cc.getValue());
   }
 } 
           
 public void noteOffReceived(LXMidiNote note) {
   if (DEBUG) {
     println("noteOffReceived pitch: " + note.getPitch());
     println("noteOffReceived velocity: " + note.getVelocity());  
   }   
 } 
           
 public void noteOnReceived(LXMidiNoteOn note) {
   if (DEBUG) {
     println("noteOnReceived pitch: " + note.getPitch());
     println("noteOnReceived velocity: " + note.getVelocity());
   } 
 } 
           
 public void pitchBendReceived(LXMidiPitchBend pitchBend) {
   if (DEBUG) {
     println("noteOnReceived pitch: " + pitchBend.getPitchBend());
   }  
 } 
           
 public void programChangeReceived(LXMidiProgramChange pc) {
   if (DEBUG) {
     println("LXMidiProgramChange pitch: " + pc.getProgram());
   }
 }
 
 public void effectAdded(LXChannel channel, LXEffect effect) {} 
           
 public void effectRemoved(LXChannel channel, LXEffect effect) {} 

 public void faderTransitionDidChange(LXChannel channel, LXTransition faderTransition) {} 
           
 public void patternAdded(LXChannel channel, LXPattern pattern) {} 
           
 public void patternDidChange(LXChannel channel, LXPattern pattern) {
   if (nanoKontrol2 == null) { return; }
      
   nanoKontrol2.unbindPatternKnobsAndSliders();
   nanoKontrol2.bindKnobsAndSlidersToPattern(pattern);
 } 
           
 public void patternRemoved(LXChannel channel, LXPattern pattern) {} 
           
 public void patternWillChange(LXChannel channel, LXPattern pattern, LXPattern nextPattern) {}
}

/**
 * The LEDomeMidiListener connects the midi controller to the interface.
 */
public class KorgNanoKontrol2ChannelListener implements LXChannel.Listener {
 LX lx;

 public KorgNanoKontrol2ChannelListener(LX lx) {
   this.lx = lx;
 }
 
 public void effectAdded(LXChannel channel, LXEffect effect) {   
   if (nanoKontrol2 == null) { return; }

   nanoKontrol2.unbindEffectSliders();
   nanoKontrol2.bindSlidersToEffect(effect);
 } 
           
 public void effectRemoved(LXChannel channel, LXEffect effect) {
 } 

 public void faderTransitionDidChange(LXChannel channel, LXTransition faderTransition) {
 } 
           
 public void patternAdded(LXChannel channel, LXPattern pattern) {
 } 
           
 public void patternDidChange(LXChannel channel, LXPattern pattern) {
   if (nanoKontrol2 == null) { return; }
      
   nanoKontrol2.unbindPatternKnobsAndSliders();
   nanoKontrol2.bindKnobsAndSlidersToPattern(pattern);
 } 
           
 public void patternRemoved(LXChannel channel, LXPattern pattern) {
 } 
           
 public void patternWillChange(LXChannel channel, LXPattern pattern, LXPattern nextPattern) {
 }
}

/**
 * The LEDomeMidiListener connects the midi controller to the interface.
 */
public class KorgNanoKontrol2EffectParameterListener implements LXParameterListener { 
 private LXEffect effect; 

 public KorgNanoKontrol2EffectParameterListener(LXEffect effect) {   
   this.effect = effect;
 }
 
 public void onParameterChanged(LXParameter parameter) {      
   if (((BooleanParameter)parameter).getValueb()) {
     nanoKontrol2.unbindSliders();
     nanoKontrol2.bindSlidersToEffect(this.effect);
   }
 }
}
