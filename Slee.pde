public class ClockPattern extends LXPattern {
  
  final SinLFO thAmt = new SinLFO(0, 50, startModulator(new SinLFO(5000, 19000, 27000)));
  
  private LEDomeAudioParameterLow falloffLow = new LEDomeAudioParameterLow("LOW", 600, 600, 100);
  private LEDomeAudioParameterMid falloffMid = new LEDomeAudioParameterMid("MID", 600, 600, 100);
  private LEDomeAudioParameterHigh falloffHigh = new LEDomeAudioParameterHigh("HIGH", 600, 600, 100);
  private LEDomeAudioParameterFull falloffFull = new LEDomeAudioParameterFull("FULL", 600, 600, 100);
  private LEDomeAudioParameter[] clockFalloffs = new LEDomeAudioParameter[] {
    falloffLow,
    falloffMid,
    falloffHigh,
    falloffFull
  };
  
  ClockPattern(LX lx) {
    super(lx);
    falloffLow.setModulationRange(1);
    falloffMid.setModulationRange(1);
    falloffHigh.setModulationRange(1);
    falloffFull.setModulationRange(1);
    
    addParameter(falloffLow);
    addParameter(falloffMid);
    addParameter(falloffHigh);
    addParameter(falloffFull);
    
    for (int i = 0; i < 4; ++i) {
      addLayer(new ClockLayer(lx, i, clockFalloffs[i]));
    }
    startModulator(thAmt.randomBasis());
  }
  
  public class ClockLayer extends LXLayer {
    
    final SawLFO angle = new SawLFO(
      0, 
      TWO_PI,
      startModulator(new SinLFO(random(4000, 7000), random(19000, 21000), random(17000, 31000)).randomBasis())
    );
    
    final SinLFO falloffLFO = new SinLFO(200, 500, random(17000, 21000));
    LEDomeAudioParameter falloffParam;
    
    final SinLFO ySpr = new SinLFO(0, 2, random(9000, 17000));
    
    final int i;
    
    ClockLayer(LX lx, int i, LEDomeAudioParameter falloffParam) {
      super(lx);
      this.i = i;
      this.falloffParam = falloffParam;
      startModulator(angle.randomBasis());
      startModulator(falloffLFO.randomBasis());
      startModulator(ySpr.randomBasis());
    }
    
    public void run(double deltaMs) {
      float av = angle.getValuef();
      if (i % 2 == 1) {
        av = TWO_PI - av;
      }
      
      for (LXPoint p : model.points) {        
        float b = 100 - (this.getFalloffValue() - p.y) * LXUtils.wrapdistf(p.azimuth, av, TWO_PI);
        if (b > 0) {
          addColor(p.index, LX.hsb(
            (abs(p.y-model.cy)*ySpr.getValuef() + thAmt.getValuef() * abs(p.azimuth - PI)) % 360,
            100,
            b
          ));
        }
      }
    }
    
    public float getFalloffValue() {
      if (this.lx.engine.audio.enabled.getValueb()) {
        return this.falloffParam.getValuef();  
      } else {
        return this.falloffLFO.getValuef();
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(0);
  }
}