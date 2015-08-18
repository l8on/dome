class Breather extends LEDomePattern {
  private final float E = exp(1);
  private final float RATE = 6;
  private final float SECOND = 1000;

  public String getName() { return "Breather"; }
  private final SinLFO breather = new SinLFO(-1, 1, RATE * SECOND);

  public Breather(P2LX lx) {
    super(lx);
    addModulator(breather).start();
    breathe();
  }

  public void run(double deltaMs) {
    breathe();
  }

  public void breathe() {
    double breath = norm(-exp(breather.getValuef()), -1/E, -E);
    double brightness = breath * 80;
    double hue        = 50;

    for (LXPoint p : model.points) {
      colors[p.index] = LXColor.hsb(hue, 20, brightness);
    }
  }
}
