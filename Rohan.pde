import java.util.Collections;

class RohanPattern extends LEDomePattern { 
  private final BasicParameter colorChangeSpeed = new BasicParameter("SPD",  0, 0, 10000);
  private final SinLFO whatColor = new SinLFO(0, 1, colorChangeSpeed);
  public RohanPattern(LX lx){
    super(lx);
    addModulator(whatColor).trigger();
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float h = 120;
      int s = 100;
      int b = 100;
      if (p.y <= 0) {
         h = 120;
      } else {
         h = 250; 
      }


      float xRelative= model.xMax * whatColor.getValuef();
      float xStep = (model.xMax - model.xMin) / 10;
      if (p.y > 0 && this.inRange(p, xRelative, xStep)) {
         h = 100; 
      }
      
      colors[p.index] = LX.hsb(h, s, b);
    }
  }
  
  public boolean inRange(LXPoint p, float x, float rangeX) {
    if (p.x > x-rangeX && p.x < x+rangeX) {
      return true;
    } else {
      return false;
    }
  }
    
    
 }
  
  

