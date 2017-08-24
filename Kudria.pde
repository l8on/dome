public class Beachball extends LEDomePattern {
  private final int stripeSize = 360 / 10;
  private final int maxTwist   = 24;

  private BoundedParameter rateParam = new BoundedParameter("RATE", 3600, 1800, 6000);
  private BoundedParameter blurParam = new BoundedParameter("BLUR", 0.1, 0.01, 1.0);

  private LEDomeAudioParameterFull fullVolume = new LEDomeAudioParameterFull("FF", 5, 0, 100);

  private final SawLFO angle   = new SawLFO(0, 360, rateParam);

  public String getName() { return "Beachball"; }
  public Beachball(LX lx) {
    super(lx);

    fullVolume.setModulationRange(1);

    addParameter(rateParam);
    addParameter(blurParam);
    addParameter(fullVolume);
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
      float pixelAngle     = (p.azimuth * (180.0/PI));
      float sweepingAngle  = pixelAngle + twistAngle - angle.getValuef();

      double stripe = floor( (sweepingAngle % 360) / stripeSize);

      double hue        = (pixelAngle) % 360;
      double saturation = (stripe % 2 == 0) ? 75  : 100;
      double brightness = (stripe % 2 == 0) ? 100 : fullVolume.getValuef();

      int newColor = LXColor.hsb(hue, saturation, brightness);
      colors[p.index] = LXColor.lerp(colors[p.index], newColor, blurParam.getValue());
    }
  }
}

public class Breather extends LEDomePattern {
  private final float E = exp(1);
  private final float SECOND = 1000;

  public String getName() { return "Breather"; }
  private double[] hues      = new double[lx.total];
  private SinLFO[] breathers = new SinLFO[lx.total];

  private BoundedParameter satParam  = new BoundedParameter("SAT", 80, 40, 100);
  private BoundedParameter huesParam = new BoundedParameter("HUES", 70, 30, 100);
  private BoundedParameter rateParam = new BoundedParameter("RATE", 6, 0.6, 15);
  private BoundedParameter varParam  = new BoundedParameter("VAR", 0.5, 0.1, 0.9);

  public Breather(LX lx) {
    super(lx);
    addParameter(satParam);
    addParameter(huesParam);
    addParameter(rateParam);
    addParameter(varParam);
    initBreathers();
    resetHues();
    breathe();
  }

  public double getRate() {
    float varianceRange = varParam.getValuef();
    float rate = rateParam.getValuef();
    float variance = random(-varianceRange, varianceRange) * rate;
    return (rate + variance) * SECOND;
  }

  private void initBreathers() {
    for (int p = 0; p < lx.total; p++) {
      breathers[p] = new SinLFO(-1, 1, getRate());
      breathers[p].setLooping(false);
      addModulator(breathers[p]).start();
    }
  }

  private void resetHues() {
    double startHue = random(0, 360);

    for (int p = 0; p < lx.total; p++) {
      double jitteredHue = startHue + random(-huesParam.getValuef(), huesParam.getValuef());
           if (jitteredHue < 0)   { hues[p] = 360 + jitteredHue; }
      else if (jitteredHue > 360) { hues[p] = jitteredHue - 360; }
      else                        { hues[p] = jitteredHue;      }
    }
  }

  public void resetBreathers() {
    for (int p = 0; p < lx.total; p++) {
      breathers[p].setPeriod(getRate());
      breathers[p].setBasis(random(0.02, 0.15));
      breathers[p].start();
    }
  }

  public void run(double deltaMs) {
    breathe();
  }

  public void breathe() {
    double maxBreath = 0;
    for (LXPoint p : model.points) {
      double breath = norm(-exp(breathers[p.index].getValuef()), -1/E, -E);
      if (breath > maxBreath) { maxBreath = breath; }

      double brightness = breath * 80;
      colors[p.index] = LXColor.hsb(hues[p.index], satParam.getValue(), brightness);
    }

    if (maxBreath <= 0.001) {
      resetHues();
      resetBreathers();
    }
  }
}
