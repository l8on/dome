static class LEDomeAudioParameterManager implements LXParameterListener {
  private LX lx;
  private BooleanParameter audioInputEnabled;  
  private LXDatagramOutput ndbOutput;
  private List<LXParameter> audioReadyParams;
  private BandGate audioModulator;
      
  public LEDomeAudioParameterManager(LX lx, BooleanParameter audioInputEnabled, LXPattern[] patterns) {
    this.lx = lx;
    this.audioInputEnabled = audioInputEnabled;
    this.audioInputEnabled.addListener(this);
    this.collectAudioReadyParameters(patterns);   
    this.createAudioModulator();
  }
    
  private void collectAudioReadyParameters(LXPattern[] patterns) {
    this.audioReadyParams = new ArrayList<LXParameter>();
    for (LXPattern pattern: patterns) {
      for(LXParameter patternParam: pattern.getParameters()) {
        if (patternParam instanceof CompoundParameter) {
          println("Found an audio ready param for " + pattern.getLabel());
          audioReadyParams.add(patternParam);
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
  
  private void createAudioModulator() {
    this.audioModulator = new BandGate(this.lx);
    this.audioModulator.start();
  }
  
  private void connectAudioModulator() {
   
  }
  
  private void removeAudioModulator() {    
  }
}