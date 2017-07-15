import java.util.Collections;

public class Sunshine extends LEDomePattern {

  private final BoundedParameter colorChangeSpeed = new BoundedParameter("SPD", 0, 0, 10000);
  private final TriangleLFO whatSunFace = new TriangleLFO(0, 1, 5000);

  public boolean sunReversed = false;
  public int sunLastFace = 77;
  public int sunStartFace = 54;

  public Sunshine(LX lx) {
    super(lx);
    whatSunFace.setStartValue(this.sunStartFace);
    whatSunFace.setEndValue(this.sunLastFace);
    addModulator(whatSunFace).trigger();
  }

  public void run(double deltaMs) {
    this.displaySky();
    this.displaySun();
  }

  public int sunIndex() {
    int index = (int)whatSunFace.getValue();
    if (this.sunReversed) {
      index = this.sunLastFace - 1 - index +  this.sunStartFace;
    }
    return index;
  }

  public void displaySky() {
    float h = 250;
    int s = 100;
    int b = 100;

    for (LXPoint p : model.points) {
      if (p.y <= 0) {
        h = 120;
      } else {
        h = 250;
      }
      colors[p.index] = LX.hsb(h, s, b);
    }
  }

  public void displaySun() {
    int index = this.sunIndex();

    this.lightSunForIndex(index);

    if (index < (this.sunLastFace-1)) {
      this.lightSunForIndex(index+1);
    } 
    if (index == (this.sunLastFace-1)) {
      this.sunReversed = !this.sunReversed;
    }
  }

  public void lightSunForIndex(int index) {
    LEDomeFace face = litFaces().get(index);
    for (LEDomeEdge edge : face.edges) {
      float hueSun = 60;
      float satSun = 100;
      float brightSun = 100;
      for (LXPoint p : edge.points) {
        colors[p.index] = LX.hsb(hueSun, satSun, brightSun);
      }
    }
  }

  public List<LEDomeFace> litFaces() {
    List<LEDomeFace> faces = new ArrayList<LEDomeFace>();
    for (LEDomeFace face : this.model.getFaces ()) {
      if (face.hasLights()) faces.add(face);
    }
    return faces;
  }

  public boolean inRange(float pointPosition, float x, float rangeX) {
    if (pointPosition > x-rangeX && pointPosition < x+rangeX) {
      return true;
    } else {
      return false;
    }
  }
}

class SunshineHalf extends Sunshine {

  public SunshineHalf(LX lx) {
    super(lx);
  }

  public void displaySky() {
    int index = this.sunIndex();
    // default sky
    float h = 250;
    int s = 100;
    int b = 100;

    LEDomeFace face = litFaces().get(index); 

    for (LXPoint p : model.points) {
      boolean xPositive = false;
      ;
      LEDomeEdge edge = face.edges.get(0);

      if (edge.points.get(0).x > 0) {
        xPositive = true;
      }

      if (p.y <= 0) {
        h = 120;
      } else {
        h = 250;
      }

      if ((xPositive && p.x > 0) || (!xPositive && p.x < 0)) {
        b = 100;
      } else {
        b = 0;
      }
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
}