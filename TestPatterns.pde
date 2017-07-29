/**
 * This file has a bunch of example patterns, each illustrating the key
 * concepts and tools of the LX framework.
 */
 
public class HueTestPattern extends LXPattern {
  private final BoundedParameter colorChangeSpeed = new BoundedParameter("SPD",  5000, 0, 10000);
  private final SinLFO whatColor = new SinLFO(0, 360, colorChangeSpeed);
  
  public HueTestPattern(LX lx) {
    super(lx);
    addParameter(colorChangeSpeed);
    addModulator(whatColor).trigger();
  }

  public void run(double deltaMs){
    for (LXPoint p : model.points) {
      float h = whatColor.getValuef();
      int s = 100;
      int b = 70;
      colors[p.index] = LX.hsb(h,s,b);
    }
  }
}

public class FaceIteratorTest extends LEDomePattern implements LXParameterListener {
  private final SawLFO currIndex = new SawLFO(0, ((LEDome)model).faces.size(), ((LEDome)model).faces.size() * 300);
  private final BoundedParameter selectedFace = new BoundedParameter("SEL", 0, 0, ((LEDome)model).faces.size() - 1);
  
  public FaceIteratorTest(LX lx) {
    super(lx);     
        
    addParameter(selectedFace);    
    addModulator(currIndex).start();
  }
  
  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    int selectedIndex = (int) selectedFace.getValuef();
    
    for(int i = 0; i < model.faces.size(); i++) {
      LEDomeFace face = model.faces.get(i);
      if(!face.hasLights()) { continue; }
      
      float bv = (i == index || i == selectedIndex) ? 100.0 : 0.0;
     
      for(LXPoint p : face.points) {
        colors[p.index] = LX.hsb(120, 90, bv);    
      }
    }
  }
  
  public void onParameterChanged(LXParameter parameter) {
    if (parameter != this.selectedFace) { return; }
    
    int selectedIndex = (int) selectedFace.getValuef();    
    LEDomeFace face = model.faces.get(selectedIndex);    
    if(!face.hasLights()) { return; }
    
    println("Face stats for " + selectedIndex);
    println("Center x: " + face.xf());
    println("Center y: " + face.yf());
    println("Center z: " + face.zf());
    
    for(LXPoint p: face.points) {
      println("Point index: " + p.index);
      println("  x: " + p.x);
      println("  y: " + p.y);
      println("  z: " + p.z);
      println("  theta: " + p.theta);
      println("  azimuth: " + p.azimuth);
    }
    
    println();
  }
  
  
}

class EdgeIteratorTest extends LEDomePattern {
  private final SawLFO currIndex = new SawLFO(0, ((LEDome)model).edges.size(), ((LEDome)model).edges.size() * 200);
  private final BoundedParameter selectedEdge = new BoundedParameter("SEL", 0, 0, ((LEDome)model).edges.size() - 1);
  
  public EdgeIteratorTest(LX lx) {
    super(lx);
    
    addParameter(selectedEdge);
    addModulator(currIndex).start();     
  }
  
  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    int selectedIndex = (int) selectedEdge.getValuef();
    LEDomeEdge edge = this.model.edges.get(index);
    LEDomeEdge selectedEdge = this.model.edges.get(selectedIndex);
    
    for(LXPoint p : model.points) {
      float bv = (edge.onEdge(p) || selectedEdge.onEdge(p)) ? 100.0 : 0.0;
      colors[p.index] = LX.hsb(120, 90, bv);  
    }
  }
}
 
public class LayerDemoPattern extends LEDomePattern {  
  private final LEDomeAudioParameterFull colorSpread = new LEDomeAudioParameterFull("Clr", 0.5, 0, 3);
  private final BoundedParameter stars = new BoundedParameter("Stars", 100, 0, 100);
  
  public LayerDemoPattern(LX lx) {
    super(lx);        
    colorSpread.setModulationRange(.6);
    addParameter(colorSpread);
    addParameter(stars);
    addLayer(new CircleLayer(lx));
    addLayer(new RodLayer(lx));
    for (int i = 0; i < 200; ++i) {
      addLayer(new StarLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    // The layers run automatically
  }
  
  private class CircleLayer extends LXLayer {
    
    private final SinLFO xPeriod = new SinLFO(3400, 7900, 11000); 
    private final SinLFO brightnessX = new SinLFO(model.xMin, model.xMax, xPeriod);
  
    private CircleLayer(LX lx) {
      super(lx);
      addModulator(xPeriod).start();
      addModulator(brightnessX).start();
    }
    
    public void run(double deltaMs) {
      // The layers run automatically
      float falloff = 100 / (4*FEET);      
      for (LXPoint p : model.points) {
        float yWave = model.yRange/2 * sin(p.x / model.xRange * PI); 
        float distanceFromCenter = dist(p.x, p.y, model.cx, model.cy);
        float distanceFromBrightness = dist(p.x, abs(p.y - model.cy), brightnessX.getValuef(), yWave);
        colors[p.index] = LXColor.hsb(
          lx.palette.getHuef() + colorSpread.getValuef() * distanceFromCenter,
          100,
          max(0, 100 - falloff*distanceFromBrightness)
        );
      }           
    }
  }
  
  private class RodLayer extends LXLayer {

    private final SinLFO zPeriod = new SinLFO(2000, 5000, 9000);
    private final SinLFO zPos = new SinLFO(model.zMin, model.zMax, zPeriod);
    
    private RodLayer(LX lx) {
      super(lx);
      addModulator(zPeriod).start();
      addModulator(zPos).start();
    }
    
    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        float b = 100 - dist(p.x, p.y, model.cx, model.cy) - abs(p.z - zPos.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            lx.palette.getHuef() + p.azimuth,
            100,
            b
          ));
        }
      }
    }
  }
  
  private class StarLayer extends LXLayer {
    
    private final TriangleLFO maxBright = new TriangleLFO(0, stars, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000)); 
    
    private int index = 0;
    
    private StarLayer(LX lx) { 
      super(lx);
      addModulator(maxBright).start();
      addModulator(brightness).start();
      pickStar();
    }
    
    private void pickStar() {
      index = (int) random(0, model.size-1);
    }
    
    public void run(double deltaMs) {
      if (brightness.getValuef() <= 0) {
        pickStar();
      } else {
        addColor(index, LXColor.hsb(lx.palette.getHuef(), 50, brightness.getValuef()));
      }
    }
  }
}