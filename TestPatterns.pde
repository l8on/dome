/**
 * This file has a bunch of example patterns, each illustrating the key
 * concepts and tools of the LX framework.
 */
 
class HueTestPattern extends LXPattern {
  private final BasicParameter colorChangeSpeed = new BasicParameter("SPD",  5000, 0, 10000);
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


class FaceIteratorTest extends LXPattern {
  private final SawLFO currIndex = new SawLFO(0, ((LEDome)model).faces.size(), ((LEDome)model).faces.size() * 300);
  public FaceIteratorTest(LX lx) {
    super(lx);     
    
    addModulator(currIndex).start();     
  }
  
  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    
    for(int i = 0; i < ((LEDome)model).faces.size(); i++) {
      LEDomeFace face = ((LEDome)model).faces.get(i);
      if(!face.hasLights()) {
        continue;  
      }
      
      float bv = (i == index) ? 100.0 : 0.0;
     
      for(LXPoint p : face.points) {
        colors[p.index] = LX.hsb(120, 90, bv);    
      }
    }
  }
}

class EdgeIteratorTest extends LXPattern {
  private final SawLFO currIndex = new SawLFO(0, ((LEDome)model).edges.size(), ((LEDome)model).edges.size() * 200);
  
  public EdgeIteratorTest(LX lx) {
    super(lx);
    
    addModulator(currIndex).start();     
  }
  
  public void run(double deltaMs) {
    int index = (int) currIndex.getValuef();
    LEDomeEdge edge = ((LEDome)model).edges.get(index);
    
    for(LXPoint p : model.points) {
      float bv = edge.onEdge(p) ? 100.0 : 0.0;
      colors[p.index] = LX.hsb(120, 90, bv);  
    }
  }
}
 
class LayerDemoPattern extends LXPattern {  
  private final BasicParameter colorSpread = new BasicParameter("Clr", 0.5, 0, 3);
  private final BasicParameter stars = new BasicParameter("Stars", 100, 0, 100);
  
  public LayerDemoPattern(LX lx) {
    super(lx);        
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
          lx.getBaseHuef() + colorSpread.getValuef() * distanceFromCenter,
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
            lx.getBaseHuef() + p.z,
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
        addColor(index, LXColor.hsb(lx.getBaseHuef(), 50, brightness.getValuef()));
      }
    }
  }
}
