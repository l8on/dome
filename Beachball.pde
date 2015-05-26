class Beachball extends LXPattern {
  private BasicParameter rateParameter = new BasicParameter("RATE", 3000.0, 500.0, 20000.0); // Number of ms to make a full revolution

  private final SawLFO hueAngle = new SawLFO(0, 360, rateParameter);

  public String getName() { return "Beachball"; }
  public Beachball(P2LX lx) {
    super(lx);

    addParameter(rateParameter);
    addModulator(hueAngle).start();

    drawBeachball();
  }

  public void run(double deltaMs) {
    drawBeachball();
  }

  public void drawBeachball() {
    for (LXPoint p : model.points) {
      double hue = (hueAngle.getValue() + cartesianToDegrees(p.x, p.z)) % 360;
      colors[p.index] = LXColor.hsb(hue, 100, 100);
    }
  }

  private float cartesianToDegrees(float x, float y) {
    return atan2(y, x) * (180/PI) + 180;
  }

}

