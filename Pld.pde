public class Spiral extends LEDomePattern {
  private final int numFaces = model.faces.size();
  private final BoundedParameter tail = new BoundedParameter("Tail", 4, 1, numFaces / 3);
  private final BoundedParameter offset = new BoundedParameter("Offset", 15, 1, numFaces / 2);
  private final BoundedParameter faceVariation = new BoundedParameter("Face", 0, 0, 2);
  private final BoundedParameter numTrails = new BoundedParameter("Trails", 4, 1, 4);
  private final BoundedParameter solidFaces = new BoundedParameter("Solid", 0, 0, 1);
  
  private LEDomeAudioParameterLow spiralPeriod = new LEDomeAudioParameterLow("SpiralPeriod", numFaces * 100, numFaces * 100, numFaces * 50); 

  public Spiral(LX lx) {
    super(lx);     
    addParameter(tail);
    addParameter(offset);
    addParameter(faceVariation);
    addParameter(numTrails);
    addParameter(solidFaces);
    addParameter(spiralPeriod);
    addLayer(new SpiralLayer(lx, spiralPeriod));    
  }

  public void run(double deltaMs) {
    // The layers run automatically
  }

  private class SpiralLayer extends LXLayer {      
    private final TriangleLFO currIndex;
    private final TriangleLFO minBright = new TriangleLFO(10, 25, numFaces * 25);
    private HashMap<Integer, Float> trailToHue = new HashMap();

    private SpiralLayer(LX lx, LXParameter spiralPeriod) {
      super(lx);
      currIndex = new TriangleLFO(0, numFaces, spiralPeriod);
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
        int numTrailsValue = Math.round(numTrails.getValuef());
        boolean solidFacesValue = Math.round(solidFaces.getValuef()) != 0;
        int currTrail = 0;

        float saturation = 100;
        float brightness = 0;
        float hue = 0;
        boolean active = false;

        for (; currTrail < numTrailsValue; currTrail++) {
          if (abs(i - index + currTrail * (offsetValue + tailValue)) < tailValue) {
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
            hue = getHue(p, active, solidFacesValue, currTrail);
            colors[p.index] = LX.hsb(hue, saturation, brightness);    
          }
        }
      }
    }

    private float getHue(LXPoint p, boolean active, boolean isSolid, int currTrail) {
        float hue = 0;

        // Ty BK!
        float pixelAngle = (p.azimuth * (180.0/PI));
        hue = pixelAngle % 360;

        if (!active) {
          return 360 - hue;
        }

        if (isSolid) {
          // avoid black
          if (hue > 210 & hue < 240) {
            hue = 210;
          } else if (hue >= 240 && hue < 270) {
            hue = 270;
          }

          if (trailToHue.containsKey(currTrail)) {
            hue = trailToHue.get(currTrail);
          } else {
            trailToHue.put(currTrail, hue);
          }
        }

        return hue;
    }
  } 
}