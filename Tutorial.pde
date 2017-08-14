public class ColorPattern extends LEDomePattern {
  private final LEDomeAudioParameterFull colorChangeSpeed = new LEDomeAudioParameterFull("SPD",  10000, 20000, 5000);
  private final SinLFO whatColor = new SinLFO(0, 360, colorChangeSpeed);

  public ColorPattern(LX lx) {
    super(lx);
    addParameter(colorChangeSpeed);
    addModulator(whatColor).trigger();
  }

  public void run(double deltaMs){
    for (LXPoint p : model.points) {
      float h = whatColor.getValuef();
      int s = 100;
      int b = 70;
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
}