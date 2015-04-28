import java.util.LinkedList;

/**
 * 2 slanted breathing waves with bands of color.
 *
 * Each wave is a specific color, their intersection is the mix of those two colors.
 * Between each wave, there are a discrete number of bands of color.
 */
class L8onMixColor extends LXPattern {
  // Oscillators for the wave breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 20000);
  private final SinLFO yOffsetMax = new SinLFO( -1 * (model.zRange / 2.0) , model.zRange / 2.0, 20000);
  private final SinLFO zOffsetMax = new SinLFO( -1 * (model.zRange / 2.0) , model.zRange / 2.0, 20000);   
  
  // Used to store info about each wave.
  // See L8onUtil.pde for the definition.
  private List<L8onWave> l8on_waves;
  
  // Controls the radius of the string.
  private BasicParameter radiusParameterX = new BasicParameter("RADX", 1 * FEET, 1.0, model.xRange / 2.0);
  private BasicParameter radiusParameterY = new BasicParameter("RADY", 1 * FEET, 1.0, model.yRange / 2.0);
  private BasicParameter radiusParameterZ = new BasicParameter("RADZ", 1 * FEET, 1.0, model.yRange / 2.0);
  // Controls the center X coordinate of the waves.
  private BasicParameter centerXParameter = new BasicParameter("X", (model.xMin + model.xMax) / 2.0, model.xMin, model.xMax);
    // Controles the center Y coordinate of the waves.
  private BasicParameter centerYParameter = new BasicParameter("Y", (model.yMin + model.yMax) / 2.0, model.yMin, model.yMax);
  // Controls the center Z coordinate of the waves.
  private BasicParameter centerZParameter = new BasicParameter("Z", (model.zMin + model.zMax) / 2.0, model.zMin, model.zMax);
  // Controls the number of waves by axis.
  private BasicParameter numWavesX = new BasicParameter("WAVX", 3.0, 1.0, 10.0);
  private BasicParameter numWavesY = new BasicParameter("WAVY", 4.0, 1.0, 10.0);
  private BasicParameter numWavesZ = new BasicParameter("WAVZ", 4.0, 1.0, 10.0);
  // Controls brightness of on lights
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);
  
  public L8onMixColor(LX lx) {
    super(lx);
    
    initL8onWaves();

    addParameter(radiusParameterX);
    addParameter(radiusParameterY);
    addParameter(radiusParameterZ);
    addParameter(numWavesX);
    addParameter(numWavesY);
    addParameter(numWavesZ);
    addParameter(centerXParameter);
    addParameter(centerYParameter);
    addParameter(centerZParameter);
    addParameter(brightnessParameter);

    addModulator(xOffsetMax).trigger();
    addModulator(yOffsetMax).trigger();
    addModulator(zOffsetMax).trigger();    
  }
  
  public void run(double deltaMs) {
    float offset_value_x = xOffsetMax.getValuef();
    float offset_value_y = yOffsetMax.getValuef();
    float offset_value_z = zOffsetMax.getValuef();
    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.l8on_waves.size());

    for(L8onWave l8on_wave : this.l8on_waves) {
      l8on_wave.hue_value = base_hue;
      base_hue += wave_hue_diff;
    }

    color c;
    float dist_percentage;
    float hue_value = 0.0;
    float sat_value = 100.0;
    float brightness_value = brightnessParameter.getValuef();
    float wave_center_x;
    float wave_center_y;
    float wave_center_z;
    float wave_radius;
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      float x_percentage = (p.x - model.xMin) / model.xRange;
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float z_percentage = (p.z - model.zMin) / model.zRange;
      float sin_x = sin(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float cos_x = cos(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float sin_y = sin(PI / 2 + numWavesY.getValuef() * PI * y_percentage);
      float cos_y = cos(PI / 2 + numWavesY.getValuef() * PI * y_percentage);
      float sin_z = sin(PI / 2 + numWavesZ.getValuef() * PI * z_percentage);
      float cos_z = cos(PI / 2 + numWavesZ.getValuef() * PI * z_percentage);

      int num_waves_in = 0;

      for(L8onWave l8on_wave : this.l8on_waves) {
        wave_center_x = p.x;
        wave_center_y = p.y;
        wave_center_z = p.z;

        if(l8on_wave.direction == L8onWave.DIRECTION_X) {
          wave_center_z = centerZParameter.getValuef() + (l8on_wave.offset_multiplier * offset_value_z * cos_x);
          wave_radius = radiusParameterX.getValuef();          
        } else if(l8on_wave.direction == L8onWave.DIRECTION_Y) {
          wave_center_x = centerXParameter.getValuef() + (l8on_wave.offset_multiplier * offset_value_x * sin_y);
          wave_radius = radiusParameterX.getValuef();          
        } else {
          wave_center_x = centerXParameter.getValuef() + (l8on_wave.offset_multiplier * offset_value_x * sin_z);
          wave_radius = radiusParameterZ.getValuef();
        }

        float dist_from_wave = distance_from_wave(p, wave_center_x, wave_center_y, wave_center_z);

        if(dist_from_wave <= wave_radius) {
          num_waves_in++;

          if(num_waves_in == 1) {
            hue_value = l8on_wave.hue_value;
          } if(num_waves_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, l8on_wave.hue_value);
            max_hv = max(hue_value, l8on_wave.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before belnding again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, l8on_wave.hue_value);
            max_hv = max(hue_value, l8on_wave.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_waves_in > 0) {
        c = lx.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = lx.hsb(120.0, 0, 0); // I just like green
      }

      colors[p.index] = c;
    }
  }
  
  /**
   * Calculates the distance between a point the center of the wave with the given coordinates.
   */
  public float distance_from_wave(LXPoint p, float wave_center_x, float wave_center_y, float wave_center_z) {
    return dist(p.x, p.y, p.z, wave_center_x, wave_center_y, wave_center_z);
  }
  
  /**
   * Initialize the waves.
   */
  private void initL8onWaves() {
    this.l8on_waves = new LinkedList<L8onWave>();

    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_X, 1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Y, 1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Z, 1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_X, -1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Y, -1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Z, -1.0) );
  }  
}
