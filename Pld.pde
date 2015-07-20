class Spiral extends LXPattern {
  private final int numFaces = ((LEDome)model).faces.size();
  private final BasicParameter tail = new BasicParameter("Tail", 4, 1, numFaces / 3);
  private final BasicParameter offset = new BasicParameter("Offset", 15, 1, numFaces / 2);
  private final BasicParameter faceVariation = new BasicParameter("Face", 0, 0, 2);
  
  public Spiral(LX lx) {
    super(lx); 
    addParameter(tail);
    addParameter(offset);
    addParameter(faceVariation);    
    addLayer(new SpiralLayer(lx));    
  }
  
  public void run(double deltaMs) {
    // The layers run automatically
  }
  
  private class SpiralLayer extends LXLayer {
    private final TriangleLFO currIndex = new TriangleLFO(0, numFaces, numFaces * 100);
    private final TriangleLFO minBright = new TriangleLFO(10, 25, numFaces * 25);

    private SpiralLayer(LX lx) {
      super(lx);
      addModulator(currIndex).start();
      addModulator(minBright).start();
    }
    
    public void run(double deltaMs) {  
      int index = (int) currIndex.getValuef();        
      
      for(int i = 0; i < numFaces; i++) {
        LEDomeFace face = ((LEDome)model).faces.get(i);
        if(!face.hasLights()) {
          continue;  
        }
        
        int tailValue = (int) tail.getValue();
        int offsetValue = (int) offset.getValue();
        
        // update lfo min
        currIndex.setStartValue(offsetValue + tailValue);
        
        float hue = 0;
        float saturation = 100;
        float brightness = 0;
        boolean active = (abs(i - index) < tailValue || abs(i - index + offsetValue + tailValue) < tailValue); 
                
        for (LEDomeEdge edge : face.edges) {
          brightness = minBright.getValuef();
          
          if (active) {
            // step transition brightness
            brightness = 100 - face.edges.indexOf(edge) * faceVariation.getValuef() * brightness;
          }
            
          for (LXPoint p : edge.points) {
            // ty bk
            float pixelAngle = (p.ztheta * (180.0/PI));
            hue = pixelAngle % 360;
            if (!active) {
              hue = 360 - hue;
            } 
            colors[p.index] = LX.hsb(hue, saturation, brightness);    
          }
        }
      }
    }
  } 
}
