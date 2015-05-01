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
    float current_dist = 0;
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
