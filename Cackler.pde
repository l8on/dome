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


//# TODO: better snowflake


class SnowflakeLayer extends LXLayer {
  private LXPoint point;
  private final SawLFO heightMod;

  public SnowflakeLayer(LX lx) {
    super(lx);
    setInitialPoint();
    heightMod = new SawLFO(this.point.y, 0, random(1000, 10000));
    addModulator(heightMod).start();
  }

  public void setInitialPoint() {
    LEDomeEdge edge = ((LEDome)model).edges.get(((LEDome)model).edges.size() - 1);
    this.point = edge.points.get(0);
  }

  public void setNextPoint() {
    float min_dist = 1000 * FEET;
    float height = this.heightMod.getValuef();
    LXPoint nextPoint = this.point;
    for (LEDomeEdge edge : ((LEDome)model).edges) {
      for (LXPoint p : edge.points) {
        float curr_dist = dist(p.x, p.y, p.z, this.point.x, height, this.point.z);
        if (curr_dist < min_dist) {
          min_dist = curr_dist;
          nextPoint = p;
        }
      }
    }
    this.point = nextPoint;
  }

  public void run(double deltaMs) {
    this.setNextPoint();
    setColor(this.point.index, LX.hsb(360, 0, 100));
  }
}


class Snowfall extends LXPattern {

  public Snowfall(LX lx) {
    super(lx);
    for (int i = 0; i < 10; i++) {
      addLayer(new SnowflakeLayer(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(0);
  }
}
