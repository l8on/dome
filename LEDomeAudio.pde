/**
 * This base class implements the basics for connecting a parameter
 * to one of the audio modulators automatically. 
 */
public class LEDomeAudioParameter extends CompoundParameter {  
  /**
   * This normalized value will be used as the range for the modulation. 
   */
  private double modulationRange = LEDomeAudioParameterManager.MODULATOR_RANGE_DEFAULT;
  
  /**
   * This enumerated value will be used to set the polarity of the modulation.   
   */
  private LXParameter.Polarity modulationPolarity = LXParameter.Polarity.UNIPOLAR;
  
  public LEDomeAudioParameter(String label) {
    super(label, 0);
  }
  
  public LEDomeAudioParameter(String label, double value) {
    super(label, value, 1);
  }

  public LEDomeAudioParameter(String label, double value, double max) {
    super(label, value, 0, max);
  }

  public LEDomeAudioParameter(String label, double value, double v0, double v1) {
    super(label, value, v0, v1);
  }  
  
  /**
   * Set the modulation range to be used for this parameter when connected
   * to one of the audio modulators. Will ensure it is a normalized value 
   * between 0 and 1.   
   */
  public LEDomeAudioParameter setModulationRange(double modulationRange) {
    this.modulationRange = LXUtils.constrain(modulationRange, 0, 1);    
    return this;
  }
  
  public double getModulationRange() {
    return this.modulationRange;   
  }
  
  public float getModulationRangef() {
    return (float)this.modulationRange;   
  }
  
  /**
   * Set the modulation polarity to be used for this parameter when connected
   * to one of audio modulators.
   * Possible valueas are:
   * - LXParameter.Polarity.UNIPOLAR - The audio modulation will always be additive in the modulation range.
   *     Example: if the range is .2, the base param value is .5, and the audio level is .5, the modulated value will be (.5 + (.2 * .5)) = .6 
   * - LXParameter.Polarity.BIPOLAR - The audio modulation will move in both directions, so a 0 value on the modulation will result in a negative modulation.
   *     Example: if the range is .2, the base param value is .5, and the audio level is .25, the modulated value will be (.5 + (.2 * (.25 * 2 - 1))) = .45
   */
  public LEDomeAudioParameter setModulationPolarity(LXParameter.Polarity polarity) {
    this.modulationPolarity = polarity;    
    return this;
  }
  
  public LXParameter.Polarity getModulationPolarity() {
    return this.modulationPolarity;
  }
}

/**
 * Use this class to connect a parameter to the average audio level
 * of all frequencies.
 */
public class LEDomeAudioParameterFull extends LEDomeAudioParameter {
  public LEDomeAudioParameterFull(String label) {
    super(label, 0);
  }
  
  public LEDomeAudioParameterFull(String label, double value) {
    super(label, value, 1);
  }

  public LEDomeAudioParameterFull(String label, double value, double max) {
    super(label, value, 0, max);
  }

  public LEDomeAudioParameterFull(String label, double value, double v0, double v1) {
    super(label, value, v0, v1);
  }
}

/**
 * Use this class to connect a parameter to the average audio level
 * of the low (bass) frequencies of from 0 to 250 Hz
 */
public class LEDomeAudioParameterLow extends LEDomeAudioParameter {
  public LEDomeAudioParameterLow(String label) {
    super(label, 0);
  }
  
  public LEDomeAudioParameterLow(String label, double value) {
    super(label, value, 1);
  }

  public LEDomeAudioParameterLow(String label, double value, double max) {
    super(label, value, 0, max);
  }

  public LEDomeAudioParameterLow(String label, double value, double v0, double v1) {
    super(label, value, v0, v1);
  }
}

/**
 * Use this class to connect a parameter to the average audio level
 * of the middle frequencies of from 250 to 2000 Hz 
 */
public class LEDomeAudioParameterMid extends LEDomeAudioParameter {
  public LEDomeAudioParameterMid(String label) {
    super(label, 0);
  }
  
  public LEDomeAudioParameterMid(String label, double value) {
    super(label, value, 1);
  }

  public LEDomeAudioParameterMid(String label, double value, double max) {
    super(label, value, 0, max);
  }

  public LEDomeAudioParameterMid(String label, double value, double v0, double v1) {
    super(label, value, v0, v1);
  }
}

/**
 * Use this class to connect a parameter to the average audio level
 * of the high frequencies of from 2 kHz to 22.5 KHz (or the maximum frequency of the input). 
 */
public class LEDomeAudioParameterHigh extends LEDomeAudioParameter {
  public LEDomeAudioParameterHigh(String label) {
    super(label, 0);
  }
  
  public LEDomeAudioParameterHigh(String label, double value) {
    super(label, value, 1);
  }

  public LEDomeAudioParameterHigh(String label, double value, double max) {
    super(label, value, 0, max);
  }

  public LEDomeAudioParameterHigh(String label, double value, double v0, double v1) {
    super(label, value, v0, v1);
  }
}

/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class LEDomeAudioBeatGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  
  public LEDomeAudioBeatGate(LX lx) {
    this("Beat", lx);
  }

  public LEDomeAudioBeatGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public LEDomeAudioBeatGate(String label, GraphicMeter meter) {
    super(label, meter);
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);    
  }
  
  public LEDomeAudioBeatGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Beat", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public LEDomeAudioBeatGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class LEDomeAudioClapGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  final float CLAP_MIN_FREQ = 2200;
  final float CLAP_MAX_FREQ = 2800;
  
  public LEDomeAudioClapGate(LX lx) {
    this("Clap", lx);
  }

  public LEDomeAudioClapGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public LEDomeAudioClapGate(String label, GraphicMeter meter) {
    super(label, meter);        
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);
    
    this.maxFreq.setValue(CLAP_MAX_FREQ);
    this.minFreq.setValue(CLAP_MIN_FREQ);
  }
  
  public LEDomeAudioClapGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Clap", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public LEDomeAudioClapGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

public static class LEDomeAudioParameterManager implements LXParameterListener, LXChannel.Listener {
  private LX lx;  
  private BooleanParameter audioInputEnabled;  
  private List<LXCompoundModulation> currentModulations = new ArrayList<LXCompoundModulation>();;
  private LXPattern currentConnectedPattern = null;
  private BandGate audioModulatorFull;
  private BandGate audioModulatorLow;
  private BandGate audioModulatorMid;
  private BandGate audioModulatorHigh;
  
  public static final double MODULATOR_RANGE_DEFAULT = .3;
  public static final double GAIN_DEFAULT = 6;
      
  public static final double MAX_FREQ_LOW = 200;

  public static final double MIN_FREQ_MID = 216;
  public static final double MAX_FREQ_MID = 2200;

  public static final double MIN_FREQ_HIGH = 2200;  

  public LEDomeAudioParameterManager(LX lx, BooleanParameter audioInputEnabled) {
    this.lx = lx;
    
    // Listen to changes to the audio input parameter to in order to 
    // attach/detach the audio modulators
    this.audioInputEnabled = audioInputEnabled;
    this.audioInputEnabled.addListener(this);
    
    // Listen to changes to the current pattern in order to attach the 
    // right modulators to the new pattern, and remove modulators from the old.
    LXChannel channel = (LXChannel)lx.engine.getFocusedChannel();
    channel.addListener(this);
     
    // Create the modulators that are connected to the audio input.
    this.createAudioModulators();
  }
  
  public void onParameterChanged(LXParameter parameter) {
    // TODO connect audio params when stuff is enabled
    if (parameter != this.audioInputEnabled) { return; }
    
    if (this.audioInputEnabled.getValueb()) {
      this.connectAudioModulatorsToCurrentPattern();
    } else {
      this.removeAudioModulatorsFromCurrentPattern();
    }
  }
  
  private void createAudioModulators() {
    this.createAverageAudioModulator();
    this.createLowAudioModulator();
    this.createMidAudioModulator();
    this.createHighAudioModulator();
  }
  
  private void createAverageAudioModulator() {
    this.audioModulatorFull = new BandGate("Full", this.lx);
    this.lx.engine.modulation.addModulator(this.audioModulatorFull);
    this.audioModulatorFull.threshold.setValue(1);
    this.audioModulatorFull.floor.setValue(0);
    this.audioModulatorFull.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorFull.maxFreq.setValue(this.audioModulatorFull.maxFreq.range.max);
    this.audioModulatorFull.minFreq.setValue(0);
    
    this.audioModulatorFull.start();
  }
  
  private void createLowAudioModulator() {
    this.audioModulatorLow = new BandGate("Low", this.lx);  
    this.lx.engine.modulation.addModulator(this.audioModulatorLow);
    this.audioModulatorLow.threshold.setValue(1);
    this.audioModulatorLow.floor.setValue(0);
    this.audioModulatorLow.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorLow.maxFreq.setValue(MAX_FREQ_LOW);
    this.audioModulatorLow.minFreq.setValue(0);    
    
    this.audioModulatorLow.start();
  }
  
  private void createMidAudioModulator() {
    this.audioModulatorMid = new BandGate("Mid", this.lx);
    this.lx.engine.modulation.addModulator(this.audioModulatorMid);
    this.audioModulatorMid.threshold.setValue(1);
    this.audioModulatorMid.floor.setValue(0);
    this.audioModulatorMid.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorMid.maxFreq.setValue(MAX_FREQ_MID);
    this.audioModulatorMid.minFreq.setValue(MIN_FREQ_MID);    
    
    this.audioModulatorMid.start();
  }
  
  private void createHighAudioModulator() {
    this.audioModulatorHigh = new BandGate("High", this.lx);
    this.lx.engine.modulation.addModulator(this.audioModulatorHigh);
    this.audioModulatorHigh.threshold.setValue(1);
    this.audioModulatorHigh.floor.setValue(0);
    this.audioModulatorHigh.gain.setValue(GAIN_DEFAULT);    
    
    this.audioModulatorHigh.maxFreq.setValue(this.audioModulatorFull.maxFreq.range.max);
    this.audioModulatorHigh.minFreq.setValue(MIN_FREQ_HIGH);
    
    this.audioModulatorHigh.start();
  }
  
  private void connectAudioModulatorsToCurrentPattern() {    
    this.connectAudioModulatorsToPattern(((LXChannel)this.lx.engine.getFocusedChannel()).getActivePattern());
  }
  
  private void connectAudioModulatorsToPattern(LXPattern pattern) {
    if (!this.shouldConnectToPattern(pattern)) { return; }
    
    for(LXParameter patternParam: pattern.getParameters()) {        
      if (!(patternParam instanceof LEDomeAudioParameter)) { continue; }
      
      LXNormalizedParameter modulationSource = this.getAudioModulationSource(patternParam);
      if (modulationSource == null) {
        println("Subclass of LEDomeAudioParameter should be used instead of the base class in " + pattern.getLabel());
        continue;
      }
      
      LXCompoundModulation compoundModulation = new LXCompoundModulation(modulationSource, (CompoundParameter)patternParam);
      this.lx.engine.modulation.addModulation(compoundModulation);
      this.currentModulations.add(compoundModulation);
      compoundModulation.range.setValue(((LEDomeAudioParameter)patternParam).getModulationRange());
      compoundModulation.polarity.setValue(((LEDomeAudioParameter)patternParam).getModulationPolarity());
    }
    
    this.currentConnectedPattern = pattern;
  }
  
  private boolean shouldConnectToPattern(LXPattern pattern) {
    if (!this.audioInputEnabled.getValueb()) { return false; }
    if (currentConnectedPattern == pattern) { return false; }
    return true;
  }
  private LXNormalizedParameter getAudioModulationSource(LXParameter patternParam) {
    LXNormalizedParameter modulationSource = null;
    if (patternParam instanceof LEDomeAudioParameterFull) {
      modulationSource = this.audioModulatorFull.average;                    
    } else if (patternParam instanceof LEDomeAudioParameterLow) {
      modulationSource = this.audioModulatorLow.average;
    } else if (patternParam instanceof LEDomeAudioParameterMid) {
      modulationSource = this.audioModulatorMid.average;
    } else if (patternParam instanceof LEDomeAudioParameterHigh) {
      modulationSource = this.audioModulatorHigh.average;
    }
    return modulationSource;
  }
  
  private void removeAudioModulatorsFromCurrentPattern() {
    this.removeAudioModulatorsFromPattern(((LXChannel)this.lx.engine.getFocusedChannel()).getActivePattern());
  }
  
  private void removeAudioModulatorsFromPattern(LXPattern pattern) {    
    println("Removing audio modulations from " + pattern.getLabel());
    for(LXCompoundModulation compoundModulation: this.currentModulations) {      
      this.lx.engine.modulation.removeModulation(compoundModulation);
    }
    
    this.currentModulations.clear();
    this.currentConnectedPattern = null;
  }
    
  public void patternWillChange(LXChannel channel, LXPattern pattern, LXPattern nextPattern) {    
    this.removeAudioModulatorsFromPattern(pattern);
    this.connectAudioModulatorsToPattern(nextPattern);
  }
  
  public void patternDidChange(LXChannel channel, LXPattern pattern) { 
    if (this.currentConnectedPattern == null) {
      this.connectAudioModulatorsToPattern(pattern);
    }
  }
  
  public void indexChanged(LXChannel channel) { return; }
  public void patternAdded(LXChannel channel, LXPattern pattern) { return; }
  public void patternRemoved(LXChannel channel, LXPattern pattern) { return; }
  public void patternMoved(LXChannel channel, LXPattern pattern) { return; }
  public void effectAdded(LXBus channel, LXEffect effect) { return; }
  public void effectRemoved(LXBus channel, LXEffect effect) { return; }
  public void effectMoved(LXBus channel, LXEffect effect) { return; }
}