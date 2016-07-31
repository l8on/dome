class ColorSpiral extends LEDomePattern {
  private final int faceCount = model.faces.size();
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
      LEDomeFace face = model.faces.get(i);
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


class Meteor extends LXLayer {
  private final int MAX_DISTANCE = 1000 * FEET;

  private LEDome dome = (LEDome)model;
  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);
  private LXRangeModulator delayMod = new LinearEnvelope(0);
  private List<LXPoint> points = new ArrayList<LXPoint>();

  public Meteor(LX lx) {
    super(lx);
    addModulator(xMod);
    addModulator(yMod);
    addModulator(zMod);
    addModulator(delayMod);
  }

  private void init() {
    float rStart = random(0, dome.DOME_RADIUS);
    float rEnd = random(0, dome.DOME_RADIUS);
    float thetaStart = random(0, 2 * PI);
    float thetaEnd = random(0, 2 * PI);

    float xStart = rStart * cos(thetaStart);
    float zStart = rStart * sin(thetaStart);
    float xEnd = rEnd * cos(thetaEnd);
    float zEnd = rEnd * sin(thetaEnd);

    float duration = random(200, 1000);
    float delayDuration = random(5000, 30000);

    xMod.setRange(xStart, xEnd, duration).trigger();
    yMod.setRange(3 * FEET, 3 * FEET, duration).trigger();
    zMod.setRange(zStart, zEnd, duration).trigger();
    delayMod.setRange(0, 1, delayDuration).trigger();

    points.clear();
  }

  private void addPoint() {
    LXPoint closestPoint = null;
    float currDist, minDist = MAX_DISTANCE;
    for (LEDomeEdge edge : dome.edges) {
      for (LXPoint point : edge.points) {
        currDist = dist(point.x, point.y, point.z,
                        xMod.getValuef(), yMod.getValuef(), zMod.getValuef());
        if (currDist < minDist) {
          minDist = currDist;
          closestPoint = point;
        }
      }
    }
    if (closestPoint != null && !points.contains(closestPoint)) {
      points.add(closestPoint);
    }
  }

  private void colorPoints() {
    for (int i = 0; i < points.size(); i++) {
      float brightness = 100.0 * (i + 1) / points.size();
      colors[points.get(i).index] = LX.hsb(60, 40, brightness);
    }
  }

  private boolean isShooting() {
    return (xMod.isRunning() || yMod.isRunning() || zMod.isRunning());
  }

  public void run(double deltaMs) {
    if (isShooting()) {
      addPoint();
      colorPoints();
    } else if (!delayMod.isRunning()) {
      init();
    }
  }
}


class Stargaze extends LXPattern {
  private final int SKY_COLOR = LX.hsb(240, 80, 40);
  private final int STAR_HUE = 60;
  private final int STAR_SAT = 20;

  private LEDome dome = (LEDome)model;
  private List<LEDomeFace> shuffledFaces = new ArrayList<LEDomeFace>(dome.faces);
  private final int faceCount = shuffledFaces.size();

  private List<LXPoint> stars = new ArrayList<LXPoint>();
  private List<SinLFO> twinklers = new ArrayList<SinLFO>();
  private List<Meteor> meteors = new ArrayList<Meteor>();

  private BasicParameter brightnessParam = new BasicParameter("BRT", 75, 10, 100);
  private BasicParameter numStarsParam = new BasicParameter("STAR", 40, 10, faceCount);
  private BasicParameter numMeteorsParam = new BasicParameter("MET", 3, 0, 6);

  public Stargaze(LX lx) {
    super(lx);
    addParameter(brightnessParam);
    addParameter(numStarsParam);
    addParameter(numMeteorsParam);
    initStars();
    initMeteors();
  }

  private void initStars() {
    float brightness = brightnessParam.getValuef();
    Collections.shuffle(shuffledFaces);
    stars.clear();
    twinklers.clear();
    for (int i = 0; i < numStarsParam.getValue(); i++) {
      LEDomeFace face = shuffledFaces.get(i);
      if(!face.hasLights()) {
        continue;
      }
      stars.add(face.points.get((int)random(0, 6)));
      SinLFO twinkler = new SinLFO(brightness / 2, brightness, random(1000, 5000));
      twinklers.add(twinkler);
      addModulator(twinkler).trigger();
    }
  }

  private void initMeteors() {
    for (Meteor meteor : meteors) {
      removeLayer(meteor);
    }
    meteors.clear();
    for (int i = 0; i < numMeteorsParam.getValue(); i++) {
      Meteor meteor = new Meteor(lx);
      meteors.add(meteor);
      addLayer(meteor);
    }
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == numStarsParam) {
      initStars();
    }
    if (parameter == numMeteorsParam) {
      initMeteors();
    }
  }

  public void run(double deltaMs) {
    float brightness = brightnessParam.getValuef();
    for (int i = 0; i < faceCount; i++) {
      LEDomeFace face = shuffledFaces.get(i);
      if(!face.hasLights()) {
        continue;
      }
      for (LXPoint point : face.points) {
        colors[point.index] = SKY_COLOR;
      }
    }
    for (int i = 0; i < stars.size(); i++) {
      LXPoint point = stars.get(i);
      SinLFO twinkler = twinklers.get(i);
      twinkler.setRange(brightness / 2, brightness);
      colors[point.index] = LX.hsb(STAR_HUE, STAR_SAT, twinkler.getValuef());
    }
  }
}

