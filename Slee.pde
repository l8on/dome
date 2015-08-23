class ClockPattern extends LXPattern {
  
  final SinLFO thAmt = new SinLFO(0, 50, startModulator(new SinLFO(5000, 19000, 27000)));
  
  ClockPattern(LX lx) {
    super(lx);
    for (int i = 0; i < 5; ++i) {
      addLayer(new ClockLayer(lx, i));
    } 
    startModulator(thAmt.randomBasis());
  }
  
  class ClockLayer extends LXLayer {
    
    final SawLFO angle = new SawLFO(
      0, 
      TWO_PI,
      startModulator(new SinLFO(random(4000, 7000), random(19000, 21000), random(17000, 31000)).randomBasis())
    );
    
    final SinLFO falloff = new SinLFO(200, 500, random(17000, 21000));
    
    final SinLFO ySpr = new SinLFO(0, 2, random(9000, 17000));
    
    final int i;
    
    ClockLayer(LX lx, int i) {
      super(lx);
      this.i = i;
      startModulator(angle.randomBasis());
      startModulator(falloff.randomBasis());
      startModulator(ySpr.randomBasis());
    }
    
    public void run(double deltaMs) {
      float av = angle.getValuef();
      if (i % 2 == 1) {
        av = TWO_PI - av;
      }
      
      for (LXPoint p : model.points) {
        float b = 100 - (falloff.getValuef() - p.y) * LXUtils.wrapdistf(p.ztheta, av, TWO_PI);
        if (b > 0) {
          addColor(p.index, LX.hsb(
            (abs(p.y-model.cy)*ySpr.getValuef() + thAmt.getValuef() * abs(p.ztheta - PI)) % 360,
            100,
            b
          ));
        }
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(0);
  }
}
