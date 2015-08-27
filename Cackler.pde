class ColorSpiral extends LXPattern {
  private final int minSB = 80;
  private final int faceCount = ((LEDome)model).faces.size();
  private final SawLFO currIndex = new SawLFO(0, faceCount, 5000);

  public ColorSpiral(LX lx) {
    super(lx);
    addModulator(currIndex).start();
  }

  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    int effectiveIndex, satbright;

    for(int i = 0; i < faceCount; i++) {
      LEDomeFace face = ((LEDome)model).faces.get(i);
      effectiveIndex = (i + index) % faceCount;
      satbright = minSB + int((i / float(faceCount)) * (100 - minSB));
      if(!face.hasLights()) {
        continue;
      }
      for(LXPoint p : face.points) {
        colors[p.index] = LX.hsb(effectiveIndex / float(faceCount) * 360, satbright, satbright);
      }
    }
  }
}


// TODO: parameterize brightness and speed; add full restart switch

class SnowflakeLayer extends LXLayer {
  private LEDome dome = (LEDome)model;
  private LXPoint point;
  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);

  private final int MAX_DISTANCE = 1000 * FEET;
  private final int MAX_HEIGHT = 10 * FEET;
  private final int START_RAND = 1 * FEET;
  private final int MIN_FALL_TIME = 2000;
  private final int MAX_FALL_TIME = 6000;
  private final int MIN_BRIGHTNESS = 50;
  private final int MAX_BRIGHTNESS = 75;

  public SnowflakeLayer(LX lx) {
    super(lx);
    addModulator(this.xMod);
    addModulator(this.yMod);
    addModulator(this.zMod);
  }

  private boolean isFalling() {
    return (this.xMod.isRunning() || this.yMod.isRunning() ||
            this.zMod.isRunning());
  }

  private LXPoint getClosestPoint(float x, float y, float z) {
    LXPoint closestPoint = model.points.get(0);
    float currDist, minDist = this.MAX_DISTANCE;
    for (LEDomeEdge edge : this.dome.edges) {
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
    float xStart = random(-this.START_RAND, this.START_RAND);
    float yStart = this.MAX_HEIGHT;
    float zStart = random(-this.START_RAND, this.START_RAND);
    float rEnd = this.dome.DOME_RADIUS;
    float thetaEnd = random(0, 2 * PI);
    float xEnd = rEnd * cos(thetaEnd);
    float zEnd = rEnd * sin(thetaEnd);
    float fallTime = random(this.MIN_FALL_TIME, this.MAX_FALL_TIME);
    this.point = this.getClosestPoint(xStart, yStart, zStart);
    this.xMod.setRange(this.point.x, xEnd, fallTime).trigger();
    this.yMod.setRange(this.point.y, 0, fallTime).trigger();
    this.zMod.setRange(this.point.z, zEnd, fallTime).trigger();
  }

  private void updateSnowflake() {
    float x = this.xMod.getValuef();
    float y = this.yMod.getValuef();
    float z = this.zMod.getValuef();
    this.point = this.getClosestPoint(x, y, z);
  }

  private void colorSnowflake() {
    float brightnessAdj = (this.MAX_BRIGHTNESS - this.MIN_BRIGHTNESS);
    float brightnessFactor = 1 - (2 * abs(0.5 - this.yMod.getBasisf()));
    float brightness = this.MIN_BRIGHTNESS + (brightnessAdj * brightnessFactor);
    this.setColor(this.point.index, LX.hsb(360, 0, brightness));
  }

  public void run(double deltaMs) {
    if (this.isFalling()) {
      this.updateSnowflake();
    } else {
      this.initSnowflake();
    }
    this.colorSnowflake();
  }
}


class Snowfall extends LXPattern {
  private final int SNOWFLAKE_COUNT = 42;

  public Snowfall(LX lx) {
    super(lx);
    for (int i = 0; i < this.SNOWFLAKE_COUNT; i++) {
      addLayer(new SnowflakeLayer(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(0);
  }
}
