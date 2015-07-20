class Spiral extends LXPattern {
  private final int numFaces = ((LEDome)model).faces.size();
  private final BasicParameter tail = new BasicParameter("Tail", 4, 1, numFaces / 3);
  private final BasicParameter offset = new BasicParameter("Offset", 15, 1, numFaces / 2);
  private final BasicParameter faceVariation = new BasicParameter("Face", 0, 0, 2);
  private final BasicParameter numTrails = new BasicParameter("Trails", 2, 1, 4);

  public Spiral(LX lx) {
    super(lx); 
    addParameter(tail);
    addParameter(offset);
    addParameter(faceVariation);
    addParameter(numTrails);
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
        int numTrailsValue = (int) numTrails.getValue();

        float hue = 0;
        float saturation = 100;
        float brightness = 0;
        boolean active = false;

        for (int j = 0; j < numTrailsValue; j++) {
          if (abs(i - index + j * (offsetValue + tailValue)) < tailValue) {
            active = true;
            break;
          }
        }

        // Update LFO minimum so we always see both trails
        currIndex.setStartValue((numTrailsValue - 1) * (offsetValue + tailValue));

        for (LEDomeEdge edge : face.edges) {
          brightness = minBright.getValuef();

          if (active) {
            // Step transition brightness
            brightness = 100 - face.edges.indexOf(edge) * faceVariation.getValuef() * brightness;
          }

          for (LXPoint p : edge.points) {
            // Ty BK!
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
