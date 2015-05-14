static class L8onUtil {
  L8onUtil() {
  }
  
  public static float decayed_brightness(color c, float delay,  double deltaMs) {
    float bright_prop = min(((float)deltaMs / delay), 1.0);
    float bright_diff = max((LXColor.b(c) * bright_prop), 1);
    return max(LXColor.b(c) - bright_diff, 0.0);
  }
} 

/*
 * A container to keep state of the different 3d waves in the color remix.
 */
class L8onWave {
  public static final int DIRECTION_X = 1;
  public static final int DIRECTION_Y = 2;
  public static final int DIRECTION_Z = 3;

  int direction;
  float offset_multiplier;
  float hue_value;

  public L8onWave(int direction, float offset_multiplier) {
    this.direction = direction;
    this.offset_multiplier = offset_multiplier;
  }
}

class L8onSpotLight {   
  WB_Sphere sphere;
  float center_x;
  float center_y;
  float center_z;
  float dest_x;
  float dest_y;
  float dest_z;  
  float hue_value;
  float min_dist;
  float time_at_dest_ms;
  
  public L8onSpotLight(WB_Sphere sphere, float center_x, float center_y, float center_z, float dest_x, float dest_y, float dest_z, float min_dist) {    
    this.sphere = sphere;
    WB_Point sphereCenterPoint = sphere.projectToSphere(new WB_Point(center_x, center_y, center_z));
    WB_Point sphereDestPoint = sphere.projectToSphere(new WB_Point(dest_x, dest_y, dest_z));
    this.time_at_dest_ms = 0.0;
    this.center_x = sphereCenterPoint.xf();
    this.center_y = sphereCenterPoint.yf();
    this.center_z = sphereCenterPoint.zf();
    this.dest_x = sphereDestPoint.xf();
    this.dest_y = sphereDestPoint.yf();
    this.dest_z = sphereDestPoint.zf();
    this.min_dist = min_dist;
  }
  
  public void tryNewDestination() {    
    float new_x = model.xMin + random(model.xRange);    
    float new_y = model.yMin + random(model.yRange);
    float new_z = model.zMin + random(model.zRange);
    
    if (min_dist <= dist(center_x, center_y, center_z, new_x, new_y, new_z)) { 
      this.setDestination(new_x, new_y, new_z);  
    } 
  }
  
  public void setDestination(float dest_x, float dest_y, float dest_z) {    
    WB_Point spherePoint = sphere.projectToSphere(new WB_Point(dest_x, dest_y, dest_z));
    this.dest_x = spherePoint.xf();
    this.dest_y = spherePoint.yf();
    this.dest_z = spherePoint.zf();    
    this.time_at_dest_ms = 0.0;
  }
  
  public void addTimeAtDestination(float delta) {
    this.time_at_dest_ms += delta;  
  }
  
  public float distFromDestination() {
    return dist(center_x, center_y, center_z, dest_x, dest_y, dest_z);  
  }
  
  public void movePercentageTowardDestination(float perc) {
    float dist_x = abs(dest_x - center_x) * perc;
    float dist_y = abs(dest_y - center_y) * perc;
    float dist_z = abs(dest_z - center_z) * perc;   
    
    this.moveTowardDestination(dist_x, dist_y, dist_z);
  }
  
  public void moveTowardDestination(float dist_x, float dist_y, float dist_z) {
    if (center_x < dest_x) {
      center_x = min(dest_x, center_x + dist_x);    
    } else {
      center_x = max(dest_x, center_x - dist_x);
    }
    
    if (center_y < dest_y) {
      center_y = min(dest_y, center_y + dist_y);    
    } else {
      center_y = max(dest_y, center_y - dist_y);
    }
    
    if (center_z < dest_z) {
      center_z = min(dest_z, center_z + dist_z);    
    } else {
      center_z = max(dest_z, center_z - dist_z);
    }
    
    WB_Point spherePoint = sphere.projectToSphere(new WB_Point(center_x, center_y, center_z));
    center_x = spherePoint.xf();
    center_y = spherePoint.yf();
    center_z = spherePoint.zf();
  }  
}

/**
 * Base class for keeping the state of a shape for a
 * game of life simulation.
 */
class L8onFaceLife {
  // Index of face
   public Integer index;
   // Boolean which describes if shape is alive.
   public boolean alive;
   // Boolean which describes if strip was just changed;
   public boolean just_changed;
   // Current brightness
   public float current_brightness;

   public L8onFaceLife(Integer index, boolean alive, float current_brightness) {
     this.index = index;
     this.alive = alive;
     this.current_brightness = current_brightness;
     this.just_changed = false;
   }
}

/**
 * Contains the current state of an explosion.
 */
class L8onExplosion {
  float radius;
  float center_x;
  float center_y;
  float center_z;  
  float stroke_width;
  float hue_value;
  float chill_time;
  float time_chillin;
  
  private LXModulator radius_modulator;
  private boolean radius_modulator_triggered = false;  
  
  private float _min_dist;
  private float _max_dist;
  
  public L8onExplosion(float radius, float stroke_width, float center_x, float center_y, float center_z) {    
    this.setRadius(radius, stroke_width);
    this.center_x = center_x;
    this.center_y = center_y;
    this.center_z = center_z;
  }
  
  public L8onExplosion(LXModulator radius_modulator, float stroke_width, float center_x, float center_y, float center_z) {    
    this.setRadiusModulator(radius_modulator, stroke_width);
    this.center_x = center_x;
    this.center_y = center_y;
    this.center_z = center_z;
  }
    
  public void setChillTime(float chill_time) {
    this.chill_time = chill_time;  
    this.time_chillin = 0;
  }
  
  public boolean isChillin(float deltaMs) {
    this.time_chillin += deltaMs;
    
    return time_chillin < this.chill_time;  
  }
  
  public float distanceFromCenter(float x, float y, float z) {
    return dist(this.center_x, this.center_y, this.center_z, x, y, z);
  }

  public void setRadius(float new_radius) {
    this.radius = new_radius;
    this._min_dist = max(0.0, radius - (stroke_width / 2.0));
    this._max_dist = radius + (stroke_width / 2.0);
  }
  
  public void setRadius(float new_radius, float stroke_width) {
    this.stroke_width = stroke_width;
    this.setRadius(new_radius);
  }
  
  public void setRadiusModulator(LXModulator radius_modulator, float stroke_width) {
    this.radius_modulator = radius_modulator;
    this.stroke_width = stroke_width;    
    this.radius_modulator_triggered = false;
  }

  public void setCenter(float x, float y, float z) {
    this.center_x = x;
    this.center_y = y;
    this.center_z = z;  
  }
  
  public void explode() {
    this.radius_modulator_triggered = true;    
    this.radius_modulator.trigger();
  }
  
  public boolean hasExploded() {
    return this.radius_modulator_triggered;  
  }
  
  public boolean isExploding() {
    if (this.radius_modulator == null) {
      return false;
    }
    
    return this.radius_modulator.isRunning();    
  }
  
  public boolean isFinished() {
    if (this.radius_modulator == null) {
      return true;
    }
    
    return !this.radius_modulator.isRunning();    
  }
  
  public boolean onExplosion(float x, float y, float z) {    
    float current_radius = this.radius_modulator.getValuef();
    float min_dist = max(0.0, current_radius - (stroke_width / 2.0));
    float max_dist = current_radius + (stroke_width / 2.0);;
    float point_dist = this.distanceFromCenter(x, y, z);
        
    return (point_dist >= min_dist && point_dist <= max_dist);  
  }
}
