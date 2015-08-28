class ColorSpiral extends LXPattern {
  private final int faceCount = ((LEDome)model).faces.size();
  private final SawLFO currIndex = new SawLFO(0, faceCount, 5000);

  private BasicParameter brightnessParam  = new BasicParameter("BRT", 50, 0, 100);
  private BasicParameter saturationParam  = new BasicParameter("SAT", 75, 50, 100);
  private BasicParameter speedParam  = new BasicParameter("SPD", 5000, 9000, 1000);

  public ColorSpiral(LX lx) {
    super(lx);
    addParameter(brightnessParam);
    addParameter(saturationParam);
    addParameter(speedParam);
    addModulator(currIndex).start();
  }

  public void run(double deltaMs) {
    int index = (int)currIndex.getValuef();
    int effectiveIndex;
    float hue;
    float brightness = brightnessParam.getValuef();
    float saturation = saturationParam.getValuef();
    currIndex.setPeriod(speedParam.getValuef());

    for (int i = 0; i < faceCount; i++) {
      LEDomeFace face = ((LEDome)model).faces.get(i);
      if(!face.hasLights()) {
        continue;
      }
      effectiveIndex = (i + index) % faceCount;
      for (LXPoint p : face.points) {
        hue = effectiveIndex / float(faceCount) * 360;
        colors[p.index] = LX.hsb(hue, saturation, brightness);
      }
    }
  }
}


class SnowflakeLayer extends LXLayer {
  private LEDome dome = (LEDome)model;

  private final int MAX_DISTANCE = 1000 * FEET;
  private final int MAX_HEIGHT = 10 * FEET;
  private final int START_RAND = 1 * FEET;
  private final int SPEED_RAND = 2000;
  private final int MIN_BRIGHTNESS = 50;

  private boolean isEnabled = false;
  private float maxBrightness = 0;
  private float avgFallTime = 0;

  private LXPoint point;

  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);

  public SnowflakeLayer(LX lx) {
    super(lx);
    addModulator(xMod);
    addModulator(yMod);
    addModulator(zMod);
  }

  private boolean isFalling() {
    return (xMod.isRunning() || yMod.isRunning() || zMod.isRunning());
  }

  private LXPoint getClosestPoint(float x, float y, float z) {
    LXPoint closestPoint = model.points.get(0);
    float currDist, minDist = MAX_DISTANCE;
    for (LEDomeEdge edge : dome.edges) {
      for (LXPoint p : edge.points) {
        currDist = dist(p.x, p.y, p.z, x, y, z);
        if (currDist < minDist) {
          minDist = currDist;
          closestPoint = p;
        }
      }
    }
    return closestPoint;
  }

  private void initSnowflake() {
    float xStart = random(-START_RAND, START_RAND);
    float yStart = MAX_HEIGHT;
    float zStart = random(-START_RAND, START_RAND);
    float rEnd = dome.DOME_RADIUS;
    float thetaEnd = random(0, 2 * PI);
    float xEnd = rEnd * cos(thetaEnd);
    float zEnd = rEnd * sin(thetaEnd);
    float fallTime = avgFallTime + random(-SPEED_RAND, SPEED_RAND);
    point = getClosestPoint(xStart, yStart, zStart);
    xMod.setRange(point.x, xEnd, fallTime).trigger();
    yMod.setRange(point.y, 0, fallTime).trigger();
    zMod.setRange(point.z, zEnd, fallTime).trigger();
  }

  private void updateSnowflake() {
    float x = xMod.getValuef();
    float y = yMod.getValuef();
    float z = zMod.getValuef();
    point = getClosestPoint(x, y, z);
  }

  private void colorSnowflake() {
    float brightnessAdj = maxBrightness - MIN_BRIGHTNESS;
    float brightnessFactor = 1 - (2 * abs(0.5 - yMod.getBasisf()));
    float brightness = MIN_BRIGHTNESS + (brightnessAdj * brightnessFactor);
    setColor(point.index, LX.hsb(360, 0, brightness));
  }

  public void enable(float brightness, float fallTime) {
    isEnabled = true;
    maxBrightness = brightness;
    avgFallTime = fallTime;
  }

  public void disable() {
    isEnabled = false;
  }

  public void run(double deltaMs) {
    if (!isEnabled) {
      return;
    }
    if (isFalling()) {
      updateSnowflake();
    } else {
      initSnowflake();
    }
    colorSnowflake();
  }
}


class Snowfall extends LXPattern {
  private final int SNOWFLAKE_COUNT = 70;

  private BasicParameter brightnessParam  = new BasicParameter("BRT", 75, 50, 100);
  private BasicParameter speedParam = new BasicParameter("SPD", 5000, 7000, 3000);
  private BasicParameter numParam = new BasicParameter("NUM", 40, 10, SNOWFLAKE_COUNT);

  private SnowflakeLayer[] snowflakes = new SnowflakeLayer[SNOWFLAKE_COUNT];

  public Snowfall(LX lx) {
    super(lx);
    addParameter(brightnessParam);
    addParameter(speedParam);
    addParameter(numParam);
    for (int i = 0; i < SNOWFLAKE_COUNT; i++) {
      snowflakes[i] = new SnowflakeLayer(lx);
      addLayer(snowflakes[i]);
    }
  }

  public void run(double deltaMs) {
    float brightness = brightnessParam.getValuef();
    float speed = speedParam.getValuef();
    setColors(0);
    for (int i = 0; i < SNOWFLAKE_COUNT; i++) {
      if (i < numParam.getValue()) {
        snowflakes[i].enable(brightness, speed);
      } else {
        snowflakes[i].disable();
      }
    }
  }
}
