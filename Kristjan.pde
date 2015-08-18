import java.util.Collections;

class Disco extends LEDomePattern {
  public static final int SET_COUNT = 3;
  public static final float HUE_SEPARATION = 360 / SET_COUNT;

  private LEDome dome;

  private List<LEDomeFace> litFaces;
  private List<List<LEDomeFace>> faceSets ;

  private Random random = new Random();

  public BasicParameter tempo = new BasicParameter("TPO", 500, 250, 3000);
  private SawLFO beat = new SawLFO(0.0, 1.0, tempo);

  public String getName() { return "Disco"; }

  public Disco(LX lx) {
    super(lx);
    addParameter(tempo);
    addModulator(beat).start();
    this.dome = this.model;
    this.litFaces = litFaces();

    this.faceSets = new ArrayList<List<LEDomeFace>>();
    for (int i = 0; i < SET_COUNT; i++) {
      this.faceSets.add(new ArrayList<LEDomeFace>());
    }
    shuffleFaces();
  }

  public void run(double deltaMs) {
    if (beat.getValue() > .95) shuffleFaces();
    for (int i = 0; i < SET_COUNT; i++) {
      for (LEDomeFace face : this.faceSets.get(i)) {
        for (LXPoint p : face.points) {
          colors[p.index] = LXColor.hsb(HUE_SEPARATION * i + HUE_SEPARATION / 2, 100, 100 * (1 - beat.getValue()));
        }
      }
    }
  }

  private List<LEDomeFace> litFaces() {
    List<LEDomeFace> faces = new ArrayList<LEDomeFace>();
    for (LEDomeFace face : this.dome.getFaces()) {
      if (face.hasLights()) faces.add(face);
    }
    return faces;
  }

  private LEDomeFace randomLitFace() {
    return this.litFaces.get(random.nextInt(this.litFaces.size()));
  }

  private void shuffleFaces() {
    for (int i = 0; i < this.faceSets.size(); i++) this.faceSets.get(i).clear();
    Collections.shuffle(this.litFaces);
    for (int i = 0; i < this.litFaces.size(); i++) {
      this.faceSets.get(i % SET_COUNT).add(this.litFaces.get(i));
    }
  }
}
