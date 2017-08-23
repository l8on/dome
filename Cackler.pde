public class Ring extends LEDomeLayer {
  private final float MIN_THICKNESS = 0.5 * FEET;
  private final float MAX_THICKNESS = 1.0 * FEET;
  private final float MIN_PERIOD = 5.0 * SECONDS;
  private final float MAX_PERIOD = 15.0 * SECONDS;

  private float hue;
  private float thickness;
  private LXProjection projection;
  private SinLFO heightMod;

  public Ring(LX lx) {
    this(lx, random(0, 360));
  }

  public Ring(LX lx, float hue) {
    super(lx);
    this.hue = hue;
    this.thickness = random(MIN_THICKNESS, MAX_THICKNESS);
    this.projection = new LXProjection(lx.model);
    this.heightMod = new SinLFO(lx.model.yMin, lx.model.yMax, random(MIN_PERIOD, MAX_PERIOD));
    addModulator(this.heightMod).start();
  }

  public void run(double deltaMs) {
    this.projection.reset();
    for (LXVector p : this.projection) {
      float pointDistance = dist(p.x, p.y, p.z, p.x, this.heightMod.getValuef(), p.z);
      if (pointDistance <= this.thickness) {
        float brightness = 50 + 50 * (this.thickness - pointDistance) / this.thickness;
        setColor(p.index, LX.hsb(this.hue, 100, brightness));
      }
    }
  }
}

public class Rings extends LEDomePattern {
  private final float BACKGROUND_PERIOD = 30.0 * SECONDS;
  private final int MIN_BACKGROUND_BRIGHTNESS = 10;
  private final int DEFAULT_BACKGROUND_BRIGHTNESS = 25;
  private final int MAX_BACKGROUND_BRIGHTNESS = 40;
  private final int MIN_RING_COUNT = 1;
  private final int DEFAULT_RING_COUNT = 3;
  private final int MAX_RING_COUNT = 5;
  private final float MIN_HUE_DIFF = 30.0;

  private SawLFO backgroundHueMod = new SawLFO(0, 360, BACKGROUND_PERIOD);
  private LEDomeAudioParameterFull brightnessParam = new LEDomeAudioParameterFull(
      "BRT", DEFAULT_BACKGROUND_BRIGHTNESS, MIN_BACKGROUND_BRIGHTNESS, MAX_BACKGROUND_BRIGHTNESS);
  private DiscreteParameter ringCountParam = new DiscreteParameter(
      "NRINGS", DEFAULT_RING_COUNT, MIN_RING_COUNT, MAX_RING_COUNT + 1);
  private List<Ring> rings = new ArrayList<Ring>();
  private Random hueRandomizer = new Random();

  public Rings(LX lx) {
    super(lx);
    addModulator(backgroundHueMod).start();
    addParameter(brightnessParam);
    addParameter(ringCountParam);
  }

  public float getNextRingHue() {
    // randomize ring hues but enforce variety
    List availableHues = new ArrayList<Float>();
    for (int hue = 0; hue < 360; hue++) {
      boolean isAvailable = true;
      for (Ring ring: this.rings) {
        float diff = abs(ring.hue - hue);
        if (diff < MIN_HUE_DIFF || diff > (360 - MIN_HUE_DIFF)) {
          isAvailable = false;
          break;
        }
      }
      if (isAvailable) {
        availableHues.add((float)hue);
      }
    }
    if (availableHues.isEmpty()) {
      return random(0, 360);
    }
    return (float)availableHues.get(this.hueRandomizer.nextInt(availableHues.size()));
  }

  public void updateRings() {
    int ringCount = ringCountParam.getValuei();
    while (this.rings.size() < ringCount) {
      Ring ring = new Ring(lx, this.getNextRingHue());
      this.rings.add(ring);
      addLayer(ring);
    }
    while (this.rings.size() > ringCount) {
      removeLayer(this.rings.get(0));
      this.rings.remove(0);
    }
  }

  public void run(double deltaMs) {
    updateRings();
    setColors(LX.hsb(backgroundHueMod.getValuef(), 50, brightnessParam.getValuef()));
  }
}

public class ColorSpiral extends LEDomePattern {
  private final int FACE_COUNT = model.faces.size();
  private final float MIN_PERIOD = 1.0 * SECONDS;
  private final float DEFAULT_PERIOD = 5.0 * SECONDS;
  private final float MAX_PERIOD = 10.0 * SECONDS;

  private SawLFO currIndex = new SawLFO(0, FACE_COUNT, DEFAULT_PERIOD);

  private LEDomeAudioParameterFull brightnessParam = new LEDomeAudioParameterFull("BRT", 50, 5, 85);
  private BoundedParameter saturationParam  = new BoundedParameter("SAT", 75, 50, 100);
  private BoundedParameter speedParam  = new BoundedParameter(
      "SPD", DEFAULT_PERIOD, MAX_PERIOD, MIN_PERIOD);

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

    for (int i = 0; i < FACE_COUNT; i++) {
      LEDomeFace face = model.faces.get(i);
      if(!face.hasLights()) {
        continue;
      }
      effectiveIndex = (i + index) % FACE_COUNT;
      for (LXPoint p : face.points) {
        hue = effectiveIndex / float(FACE_COUNT) * 360;
        this.colors[p.index] = LX.hsb(hue, saturation, brightness);
      }
    }
  }
}

public class Meteor extends LXLayer {
  private final int METEOR_HUE = 60;
  private final int METEOR_SAT = 40;
  private final int DEFAULT_RATE = 6;
  private final float DEFAULT_SPEED = 75.0;
  private final float SPEED_RAND = 15.0;
  private final int DELAY_MAX = 60000;
  private final int DELAY_RAND = 2000;
  private final int MIN_COUNT = 6;
  private final int MAX_COUNT = 18;
  private final float MAX_ANGLE = PI / 6;
  private final int FADE_TIME = 50;

  private LEDome dome = (LEDome)model;
  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);
  private LXRangeModulator delayMod = new LinearEnvelope(0);

  private List<LEDomeEdge> edges = new ArrayList<LEDomeEdge>();
  private List<LXPoint> points = new ArrayList<LXPoint>();
  private List<LXPoint> queue = new ArrayList<LXPoint>();
  private int count = 0;
  private int maxCount = 0;
  private int rate = DEFAULT_RATE;
  private float speed = DEFAULT_SPEED;
  private boolean autoRestart = false;

  public Meteor(LX lx) {
    this(lx, true);
  }

  public Meteor(LX lx, boolean autoRestart) {
    super(lx);
    addModulator(this.xMod);
    addModulator(this.yMod);
    addModulator(this.zMod);
    addModulator(this.delayMod);
    this.autoRestart = autoRestart;
  }

  private void restart() {
    this.restart(DELAY_MAX / this.rate + (int)random(-1 * DELAY_RAND, DELAY_RAND));
  }

  private void restart(float delayDuration) {
    this.delayMod.setRange(0, 1, delayDuration).trigger();
    this.speed = DEFAULT_SPEED + random(-1 * SPEED_RAND, SPEED_RAND);
    this.edges.clear();
    this.points.clear();
    this.queue.clear();
    this.count = 0;
    this.maxCount = (int)random(MIN_COUNT, MAX_COUNT);
    LEDomeEdge firstEdge = dome.randomEdge();
    this.edges.add(firstEdge);
    this.queue.add(firstEdge.points.get(0));
    this.queue.add(firstEdge.points.get(1));
    this.queue.add(firstEdge.points.get(2));
  }

  private void addEdge() {
    LXPoint origin = this.queue.get(0);
    LEDomeEdge currEdge = this.edges.get(this.edges.size() - 1);
    HE_Vertex originVertex = dome.closestVertex(origin);
    List<HE_Halfedge> neighbors = originVertex.getHalfedgeStar();
    float bestAngle = PI;
    LEDomeEdge bestEdge = null;
    for (HE_Halfedge halfEdge : neighbors) {
      HE_Halfedge pairedHalfEdge = halfEdge.getPair();
      int pairedHalfEdgeLabel = pairedHalfEdge.getLabel();
      if (pairedHalfEdgeLabel < 0) {
        continue;
      }
      LEDomeEdge edge = dome.edges.get(pairedHalfEdgeLabel);
      if (edge == null || this.edges.contains(edge)) {
        continue;
      }
      float angle = dome.angleBetweenEdges(currEdge, edge);
      if (angle < MAX_ANGLE && angle < bestAngle) {
        bestEdge = edge;
        bestAngle = angle;
      }
    }
    if (bestEdge == null) {
      return;
    }
    this.edges.add(bestEdge);
    LXPoint closestPoint = bestEdge.closestVertexPoint(origin.x, origin.y, origin.z);
    if (closestPoint != origin) {
      this.queue.add(closestPoint);
    }
    this.queue.add(bestEdge.points.get(1));
    if (closestPoint == bestEdge.points.get(0)) {
      this.queue.add(bestEdge.points.get(2));
    } else {
      this.queue.add(bestEdge.points.get(0));
    }
  }

  private void move() {
    if (this.queue.size() < 2 && this.count < this.maxCount) {
      this.addEdge();
    }
    if (this.queue.size() > 1) {
      LXPoint origin = this.queue.get(0);
      LXPoint target = this.queue.get(1);
      float travelDist = dist(origin.x, origin.y, origin.z, target.x, target.y, target.z);
      double travelTime = max(travelDist / (this.speed / SECONDS), 0.0);
      this.xMod.setRange((double)origin.x, (double)target.x, travelTime).start();
      this.yMod.setRange((double)origin.y, (double)target.y, travelTime).start();
      this.zMod.setRange((double)origin.z, (double)target.z, travelTime).start();
    }
    this.queue.remove(0);
  }

  public void setRate(int rate) {
    this.rate = rate;
  }

  public Integer getColor(LXPoint point) {
    int index = this.points.indexOf(point);
    if (index < 0) {
      return null;
    }
    float brightness = 100.0 * (index + 1) / this.count;
    return LX.hsb(METEOR_HUE, METEOR_SAT, brightness);
  }

  public void run(double deltaMs) {
    if (this.delayMod.isRunning()) {
      return;
    }
    if (!this.xMod.isRunning() && !this.yMod.isRunning() || !this.zMod.isRunning()) {
      if (this.queue.size() > 0) {
        this.points.add(this.queue.get(0));
        this.count += 1;
        this.move();
      } else if (this.count < 3 * this.points.size()) {
        this.count += 1;
        this.delayMod.setRange(0, 1, FADE_TIME).trigger();
      } else if (this.autoRestart) {
        this.restart();
      }
    }
  }
}

public class Stargaze extends LXPattern {
  private final int SKY_COLOR = LX.hsb(240, 80, 40);
  private final int STAR_HUE = 60;
  private final int STAR_SAT = 20;
  private final int TWINKLE_MIN = 1000;
  private final int TWINKLE_MAX = 5000;

  private LEDome dome = (LEDome)model;
  private List<LEDomeFace> faces = new ArrayList<LEDomeFace>(dome.faces);

  private List<LXPoint> stars = new ArrayList<LXPoint>();
  private List<SinLFO> twinklers = new ArrayList<SinLFO>();

  private Meteor autoMeteor = new Meteor(lx, true);
  private Meteor clapMeteor = new Meteor(lx);

  private BoundedParameter brightnessParam = new BoundedParameter("BRT", 70, 40, 100);
  private BoundedParameter numStarsParam = new BoundedParameter("STAR", 40, 10, 90);
  private BoundedParameter meteorRateParam = new BoundedParameter("MET", 6, 1, 20);

  private LEDomeAudioClapGate clapGate = new LEDomeAudioClapGate("XCLAP", lx);
  private BooleanParameter triggerParameter;

  public Stargaze(LX lx) {
    super(lx);
    addParameter(this.brightnessParam);
    addParameter(this.numStarsParam);
    addParameter(this.meteorRateParam);
    Collections.shuffle(this.faces);
    for (LEDomeFace face : this.faces) {
      if (!face.hasLights()) {
        continue;
      }
      this.stars.add(face.points.get((int)random(0, 6)));
      SinLFO twinkler = new SinLFO(0, 1, random(TWINKLE_MIN, TWINKLE_MAX));
      this.twinklers.add(twinkler);
      addModulator(twinkler).trigger();
    }
    addLayer(this.autoMeteor);
    addLayer(this.clapMeteor);
    addModulator(this.clapGate).start();
    this.triggerParameter = this.clapGate.gate;
    this.triggerParameter.addListener(this);
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == this.meteorRateParam) {
      this.autoMeteor.setRate((int)this.meteorRateParam.getValue());
    }
    if (parameter == this.triggerParameter) {
      this.clapMeteor.restart(0);
    }
  }

  public void blendColor(int index, int newColor) {
    int existingColor = this.colors[index];
    float h1 = LXColor.h(existingColor);
    float s1 = LXColor.s(existingColor);
    float b1 = LXColor.b(existingColor);
    float h2 = LXColor.h(newColor);
    float s2 = LXColor.s(newColor);
    float b2 = LXColor.b(newColor);
    float b3 = max(b1, b2);
    float h3 = h2 + (h1 - h2) * (1 - (b3 - b1) / (101 - b1));
    float s3 = s2 + (s1 - s2) * (1 - (b3 - b1) / (101 - b1));
    this.colors[index] = LX.hsb(h3, s3, b3);
  }

  public void run(double deltaMs) {
    float brightness = this.brightnessParam.getValuef();
    for (LXPoint point : model.points) {
      this.colors[point.index] = SKY_COLOR;
    }
    for (int i = 0; i < this.numStarsParam.getValue(); i++) {
      LXPoint point = this.stars.get(i);
      SinLFO twinkler = this.twinklers.get(i);
      twinkler.setRange(brightness / 2, brightness);
      this.colors[point.index] = LX.hsb(STAR_HUE, STAR_SAT, twinkler.getValuef());
    }
    for (LXPoint point : model.points) {
      Integer autoMeteorColor = this.autoMeteor.getColor(point);
      if (autoMeteorColor != null) {
        this.blendColor(point.index, (int)autoMeteorColor);
      }
      Integer clapMeteorColor = this.clapMeteor.getColor(point);
      if (clapMeteorColor != null) {
        this.blendColor(point.index, (int)clapMeteorColor);
      }
    }
  }
}