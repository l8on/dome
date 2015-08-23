class Beachball extends LEDomePattern {
  private final int stripeSize = 360 / 10;
  private final int maxTwist   = 24;
  private final int spinRate   = 2600;

  private final SawLFO angle   = new SawLFO(0, 360, spinRate);

  public String getName() { return "Beachball"; }
  public Beachball(P2LX lx) {
    super(lx);
    addModulator(angle).start();
    drawBeachball();
  }

  public void run(double deltaMs) {
    drawBeachball();
  }

  public void drawBeachball() {
    for (LXPoint p : model.points) {
      float dist       = dist(model.cx, model.cz, p.x, p.z);
      float radius     = map(dist, 0, LEDome.DOME_RADIUS, 0, 1);

      float twistAngle = LXUtils.lerpf(0.0, maxTwist, radius);
      float pixelAngle     = (p.ztheta * (180.0/PI));
      float sweepingAngle  = pixelAngle + twistAngle - angle.getValuef();

      double stripe = floor( (sweepingAngle % 360) / stripeSize);

      double hue        = (pixelAngle) % 360;
      double saturation = (stripe % 2 == 0) ? 75  : 100;
      double brightness = (stripe % 2 == 0) ? 100 : 75;

      colors[p.index] = LXColor.hsb(hue, saturation, brightness);
    }
  }
}
