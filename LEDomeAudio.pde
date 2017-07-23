static class LEDomeAudioParameterManager implements LXParameterListener {
  private LX lx;
  private BooleanParameter audioInputEnabled;  
  private LXDatagramOutput ndbOutput;
  private List<CompoundParameter> audioReadyParams;
  private List<LXCompoundModulation> compoundModulationAverages;
  private BandGate audioModulatorAverage;
  private BandGate audioModulatorLow;
  private BandGate audioModulatorMid;
  private BandGate audioModulatorHigh;
    
  public LEDomeAudioParameterManager(LX lx, BooleanParameter audioInputEnabled, LXPattern[] patterns) {
    this.lx = lx;
    this.audioInputEnabled = audioInputEnabled;
    this.audioInputEnabled.addListener(this);
    this.compoundModulationAverages = new ArrayList<LXCompoundModulation>();
    this.collectAudioReadyParameters(patterns);   
    this.createAudioModulators();
  }
    
  private void collectAudioReadyParameters(LXPattern[] patterns) {
    this.audioReadyParams = new ArrayList<CompoundParameter>();
    for (LXPattern pattern: patterns) {
      for(LXParameter patternParam: pattern.getParameters()) {
        if (patternParam instanceof CompoundParameter) {
          println("Found an audio ready param for " + pattern.getLabel());
          audioReadyParams.add((CompoundParameter)patternParam);
        }
      }
    }   
  }
  
  public void onParameterChanged(LXParameter parameter) {
    // TODO connect audio params when stuff is enabled
    if (parameter != this.audioInputEnabled) { return; }
    
    if (audioInputEnabled.getValueb()) {
      this.connectAudioModulator();
    } else {
      this.removeAudioModulator();
    }
  }
  
  private void createAudioModulators() {
    this.createAverageAudioModulator();
    this.createLowAudioModulator();
    this.createMidAudioModulator();
    this.createHighAudioModulator();
  }
  
  private void createAverageAudioModulator() {
    this.audioModulatorAverage = new BandGate(this.lx);
    //this.audioModulatorAverage.minFreq.setValue(0);
    //this.audioModulatorAverage.maxFreq.setValue(this.audioModulatorAverage.maxFreq.range.max);
    //this.audioModulatorAverage.threshold.setValue(1);
    //this.audioModulatorAverage.floor.setValue(0);    
    
    //this.audioModulatorAverage.gain.setValue(6);
    this.audioModulatorAverage.start();
  }
  
  private void createLowAudioModulator() {
    this.audioModulatorLow = new BandGate(this.lx);    
  }
  
  private void createMidAudioModulator() {
    this.audioModulatorMid = new BandGate(this.lx);
  }
  
  private void createHighAudioModulator() {
    this.audioModulatorHigh = new BandGate(this.lx);
  }
  
  private void connectAudioModulator() {
    for(CompoundParameter audioReadyParam: this.audioReadyParams) {
      LXCompoundModulation compoundModulation = new LXCompoundModulation(this.audioModulatorAverage.average, audioReadyParam);
      compoundModulationAverages.add(compoundModulation);
      compoundModulation.range.setValue(.4);      
      this.lx.engine.modulation.addModulation(compoundModulation);
    }
  }
  
  private void removeAudioModulator() {
    
  }
}