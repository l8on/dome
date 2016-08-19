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


class Meteor extends LXLayer {
  private final float MAX_ANGLE = 3.0;
  private final float MIN_ANGLE = 2.2;
  private final int DEFAULT_RATE = 6;
  private final float DEFAULT_SPEED = 60.0;
  private final float SPEED_RAND = 15.0;
  private final int DELAY_RAND = 2000;

  private LEDome dome = (LEDome)model;
  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);
  private LXRangeModulator delayMod = new LinearEnvelope(0);

  private List<LEDomeEdge> edges = new ArrayList<LEDomeEdge>();
  private List<LXPoint> points = new ArrayList<LXPoint>();
  private List<LXPoint> queue = new ArrayList<LXPoint>();
  private int count = 0;
  private int rate = DEFAULT_RATE;
  private float speed = DEFAULT_SPEED;

  public Meteor(LX lx) {
    super(lx);
    addModulator(this.xMod);
    addModulator(this.yMod);
    addModulator(this.zMod);
    addModulator(this.delayMod);
  }

  private void restart() {
    float delayDuration = 60000 / this.rate + (int)random(-1 * DELAY_RAND, DELAY_RAND);
    this.delayMod.setRange(0, 1, delayDuration).trigger();
    this.speed = DEFAULT_SPEED + random(-1 * SPEED_RAND, SPEED_RAND);
    this.edges.clear();
    this.points.clear();
    this.queue.clear();
    this.count = 0;
    LEDomeEdge firstEdge = ((LEDome)model).randomEdge();
    this.edges.add(firstEdge);
    this.queue.add(firstEdge.points.get(0));
    this.queue.add(firstEdge.points.get(1));
    this.queue.add(firstEdge.points.get(2));
  }

  private void addEdge() {
    LXPoint origin = this.queue.get(0);
    LEDomeEdge currEdge = this.edges.get(this.edges.size() - 1);
    HE_Vertex originVertex = ((LEDome)model).closestVertex(origin);
    List<HE_Halfedge> neighbors = originVertex.getHalfedgeStar();
    Collections.shuffle(neighbors);
    for (HE_Halfedge he_edge : neighbors) {
      if (he_edge.getLabel() < 0) {
        continue;
      }
      LEDomeEdge edge = ((LEDome)model).edges.get(he_edge.getLabel());
      if (edge == null || this.edges.contains(edge)) {
        continue;
      }
      float angleBetweenEdges = ((LEDome)model).angleBetweenEdges(currEdge, edge);
      if (angleBetweenEdges < MIN_ANGLE || angleBetweenEdges > MAX_ANGLE) {
        continue;
      }
      this.edges.add(edge);
      LXPoint closestPoint = edge.closestVertexPoint(origin.x, origin.y, origin.z);
      if (closestPoint != origin) {
        this.queue.add(closestPoint);
      }
      this.queue.add(edge.points.get(1));
      if (closestPoint == edge.points.get(0)) {
        this.queue.add(edge.points.get(2));
      } else {
        this.queue.add(edge.points.get(0));
      }
      break;
    }
  }

  private void move() {
    if (this.queue.size() < 2) {
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
    return LX.hsb(60, 40, 100.0 * (index + 1) / this.count);
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
      // kludgy fade-out
      } else if (this.count < 3 * this.points.size()) {
        this.count += 1;
        this.delayMod.setRange(0, 1, 50).trigger();
      } else {
        this.restart();
      }
    }
  }
}


class Stargaze extends LXPattern {
  private final int SKY_COLOR = LX.hsb(240, 80, 40);
  private final int STAR_HUE = 60;
  private final int STAR_SAT = 20;
  private final int TWINKLE_MIN = 1000;
  private final int TWINKLE_MAX = 5000;

  private LEDome dome = (LEDome)model;
  private List<LEDomeFace> faces = new ArrayList<LEDomeFace>(dome.faces);

  private List<LXPoint> stars = new ArrayList<LXPoint>();
  private List<SinLFO> twinklers = new ArrayList<SinLFO>();
  private Meteor meteor = new Meteor(lx);

  private BasicParameter brightnessParam = new BasicParameter("BRT", 75, 10, 100);
  private BasicParameter numStarsParam = new BasicParameter("STAR", 40, 10, 90);
  private BasicParameter meteorRateParam = new BasicParameter("MET", 6, 1, 20);

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
    addLayer(this.meteor);
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == this.meteorRateParam) {
      this.meteor.setRate((int)this.meteorRateParam.getValue());
    }
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
      Integer meteorColor = this.meteor.getColor(point);
      if (meteorColor != null) {
        this.colors[point.index] = (int)meteorColor;
      }
    }
  }
}
