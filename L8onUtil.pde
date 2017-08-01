public class Apple {
  public int index;
  public float hue;
  
  public Apple(int index, float hue) {
    this.index = index;
    this.hue = hue;
  }
}


// TODO: Use modulator to change hue;
// 
public class SnakeLayer extends LXLayer {
  private static final float BRIGHTNESS = 95.0;
  private static final int NUM_EDGES = 2;
  private static final int NUM_POINTS = (NUM_EDGES * 3) + 3;
  private static final float SNAKE_SPEED = 36.0;
  
  // Radians
  private static final float MAX_ANGLE = 2.5;
  private static final float MIN_ANGLE = PI / 4.0;
  
  private int[] snakeColors = new int[model.size];
  private List<LEDomeEdge> snakeEdges = new ArrayList<LEDomeEdge>();
  private List<LXPoint> snakePoints = new ArrayList<LXPoint>();  
  private List<LXPoint> pointQueue = new ArrayList<LXPoint>();
  private List<Float> pointDistances = new ArrayList<Float>();
  private float totalDistance = 0.0;
  
  public float hue = -1.0;
  
  private LXRangeModulator xMod = new LinearEnvelope(0);
  private LXRangeModulator yMod = new LinearEnvelope(0);
  private LXRangeModulator zMod = new LinearEnvelope(0);

  private BoundedParameter brightness;  
  private BoundedParameter numPoints;
  private BoundedParameter snakeSpeed;
  
  public SnakeLayer(LX lx) {
    this(lx, new BoundedParameter("EDG", NUM_POINTS));  
  }
  
  public SnakeLayer(LX lx, BoundedParameter numPoints) {
    this(lx, numPoints, new BoundedParameter("SPD", SNAKE_SPEED));
  }
  
  public SnakeLayer(LX lx, BoundedParameter numPoints, BoundedParameter snakeSpeed) {
    this(lx, numPoints, snakeSpeed, new BoundedParameter("BRIT", BRIGHTNESS, 0, 100));
  }
  
  public SnakeLayer(LX lx, BoundedParameter numPoints, BoundedParameter snakeSpeed, BoundedParameter brightness) {
    super(lx);    
    this.numPoints = numPoints;
    this.snakeSpeed = snakeSpeed;
    this.brightness = brightness;
    this.restartSnake();
    
    addModulator(this.xMod);
    addModulator(this.yMod);
    addModulator(this.zMod);
  }

  public void run(double deltaMs) {      
    if (this.reachedTarget()) {
      if (this.pointQueue.size() > 1) {
        this.addPointToSnake(this.pointQueue.get(1));
      }
      
      this.pickNextTarget();
      this.startMovement();
      return;
    }
        
    float modBasis = max(this.xMod.getBasisf(), this.yMod.getBasisf(), this.zMod.getBasisf());
   
    for (LXPoint p : model.points) {
      int snakeIndex = this.snakePoints.indexOf(p);
      
      if (snakeIndex < 0 ) {
        snakeColors[p.index] = LX.hsb(0, 0, 0);
        continue;  
      }
      
      // Fade in Head point
      if (snakeIndex == this.snakePoints.size() - 1) {        
        snakeColors[p.index] = LX.hsb(this.hueValue(), 100, modBasis * brightness.getValuef());
        continue;
      }

      // Logarithmic decay
      float b = constrain((1.0 * (log(snakeIndex - modBasis)/ log(this.snakePoints.size()))) * brightness.getValuef(), 0.0, 100.0);      
      snakeColors[p.index] = LX.hsb(this.hueValue(), 100, b);
      continue;
    }
  }
  
  public float hueValue() {
    return (this.hue >= 0.0) ? this.hue : lx.palette.getHuef();
  }
  
  public boolean hasPoint(LXPoint point) {
    return this.snakePoints.contains(point);
  }
  
  public int colorOf(int index) {
    return this.snakeColors[index];  
  }

  private void addPointToSnake(LXPoint point) {
    this.snakePoints.add(point);
    
    while (this.snakePoints.size() > this.maxSnakePoints()) {              
      this.snakePoints.remove(0);      
    }
  }
  
  private int maxSnakePoints() {
    return (int)this.numPoints.getValue();  
  }
  
  private boolean reachedTarget() {
    return !this.xMod.isRunning() && !this.yMod.isRunning() && !this.zMod.isRunning();   
  }
  
  private void restartSnake() {      
    this.snakePoints.clear();      
    this.snakeEdges.clear();      
    this.pointQueue.clear();
    LEDomeEdge firstEdge = ((LEDome)model).randomEdge();
    
    this.snakeEdges.add(firstEdge);    
    
    this.pointQueue.add(firstEdge.points.get(0));
    this.pointQueue.add(firstEdge.points.get(1));
    this.pointQueue.add(firstEdge.points.get(2));
  }
  
  private void startMovement() {
    if (this.pointQueue.size() < 2) { return; }

    LXPoint origin = this.pointQueue.get(0);
    LXPoint target = this.pointQueue.get(1);
    double travelTime = this.timeToTravel(origin, target);
    this.xMod.setRange((double)origin.x, (double)target.x, travelTime).start();
    this.yMod.setRange((double)origin.y, (double)target.y, travelTime).start();
    this.zMod.setRange((double)origin.z, (double)target.z, travelTime).start();
  }
  
  private void pickNextTarget() {      
    // Remove old origin.
    if (this.pointQueue.size() > 1) {
      this.pointQueue.remove(0);
    }
    
    // We still have 2+ points to hit, do nothing. 
    if (this.pointQueue.size() > 1) { return; }
          
    this.findNextEdge();
    
    // If the queue somehow stays empty, restart it yo.
    if (this.pointQueue.size() == 0) {
      this.restartSnake();
    }
  }
  
  private void findNextEdge() {
    LXPoint origin = this.pointQueue.get(0);
    LEDomeEdge currEdge = this.snakeEdges.get(this.snakeEdges.size() - 1);
    HE_Vertex originVertex = ((LEDome)model).closestVertex(origin);
    List<HE_Halfedge> neighbors = originVertex.getHalfedgeStar();
    Collections.shuffle(neighbors);
    boolean foundEdge = false;

    for(HE_Halfedge he_edge : neighbors) {
      // Skip edges without labels
      if (he_edge.getLabel() < 0) { continue; }

      // Find the LEDomeEdge with the correct label. 
      LEDomeEdge edge = ((LEDome)model).edges.get(he_edge.getLabel());

      // Continue if the edge doesn't have lights or if the edge is already in the snake.
      if (edge == null || this.snakeEdges.contains(edge)) { continue; }
      
      // Continue if the angle is too steep
      float angleBetweenEdges = ((LEDome)model).angleBetweenEdges(currEdge, edge);
      if (angleBetweenEdges < MIN_ANGLE || angleBetweenEdges > MAX_ANGLE) { continue; }

      // Hey we found an edge!
      foundEdge = true;

      this.queueEdgePoints(origin, edge);      

      if (this.shouldRemoveTail()) {
        this.removeTail();
      }

      this.snakeEdges.add(edge);
      break;
    }
    
    // Clear the pointQueue if we couldn't find another edge.
    if (!foundEdge) {
      this.restartSnake();
    }
  }
  
  private void queueEdgePoints(LXPoint origin, LEDomeEdge edge) {
    // Get the next vertex
    LXPoint closestPoint = edge.closestVertexPoint(origin.x, origin.y, origin.z);
    
    if (closestPoint != origin) {
      this.pointQueue.add(closestPoint);
    }

    this.pointQueue.add(edge.points.get(1));

    if (closestPoint == edge.points.get(0)) {
      this.pointQueue.add(edge.points.get(2));      
    } else {
      this.pointQueue.add(edge.points.get(0));
    }
  }

  private boolean shouldRemoveTail() {
    return this.snakeEdges.size() >= this.maxSnakeEdges();
  }
  
  private int maxSnakeEdges() {
    return ceil(this.maxSnakePoints() / 3.0);  
  }

  private void removeTail() {
    this.snakeEdges.remove(0);
  }

  private double timeToTravel(LXPoint firstHeadPoint, LXPoint secondHeadPoint) {
    float distToTravel = dist(firstHeadPoint.x, firstHeadPoint.y, firstHeadPoint.z, secondHeadPoint.x, secondHeadPoint.y, secondHeadPoint.z);
    return max(distToTravel / (snakeSpeed.getValuef() / SECONDS), 0.0);      
  }
} //<>//

/*
 * A container to keep state of the different 3d waves in the color remix.
 */
public class L8onWave {
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

public class L8onSpotLight {   
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
public class L8onFaceLife {
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
public class L8onExplosion implements LXParameterListener {  
  float center_x;
  float center_y;
  float center_z;  
  float stroke_width;
  float hue_value;
  float chill_time;
  float time_chillin;

  private BooleanParameter trigger_parameter;
  private LXModulator radius_modulator;  
  private boolean radius_modulator_triggered = false;

  public L8onExplosion(LXModulator radius_modulator, BooleanParameter trigger_parameter, float stroke_width, float center_x, float center_y, float center_z) {
    this.setRadiusModulator(radius_modulator, stroke_width);
    
    this.trigger_parameter = trigger_parameter;
    this.trigger_parameter.addListener(this);
    
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
  
  public void onParameterChanged(LXParameter parameter) {    
    if (!(parameter == this.trigger_parameter)) { return; }
        
    if (this.trigger_parameter.getValueb() && this.isFinished()) {            
      this.setChillTime(0);
    }
  }
}

public class L8onHeartExplosion {
  float center_x;
  float center_y;
  float center_z;  
  float stroke_width;
  float hue_value;
  float chill_time;
  float time_chillin;

  private LXModulator radius_modulator;
  private boolean radius_modulator_triggered = false;

  public L8onHeartExplosion(LXModulator radius_modulator, float stroke_width, float center_x, float center_y, float center_z) {
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

 
  public boolean onHeart(float x, float y, float z) {
    float current_radius = this.radius_modulator.getValuef();
    
    float xUnit = current_radius / 3.0;
    float yUnit = current_radius / 3.0;
    float zUnit = current_radius / 3.0;
     
    x = (x - this.center_x) / xUnit;
    y = (y - this.center_y) / yUnit;
    z = (z - this.center_z) / zUnit;
     
    float part1 = pow( ((2.0 * pow(x, 2)) + (2.0 * pow(y, 2)) + pow(z, 2) - 1), 3);
    float part2 = 0.1 * pow(x, 2) * pow(z, 3);
    float part3 = pow(y, 2)* pow(z, 3);
    float result = abs(part1 - part2 - part3);    
    
    return (result <= 0.01);
  }
}

public class L8onHeartLight {
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
  
  WB_Point top_point;
  LXParameter radius_parameter;
  
  public L8onHeartLight(WB_Sphere sphere, LXParameter radius_parameter, float center_x, float center_y, float center_z, float dest_x, float dest_y, float dest_z, float min_dist) {        
    this.radius_parameter = radius_parameter;
    this.sphere = sphere;
    WB_Point center = this.sphere.getCenter();
    WB_Point sphereCenterPoint = sphere.projectToSphere(new WB_Point(center_x, center_y, center_z));
    WB_Point sphereDestPoint = sphere.projectToSphere(new WB_Point(dest_x, dest_y, dest_z));    
    this.time_at_dest_ms = 0.0;
    this.center_x = sphereCenterPoint.xf();
    this.center_y = sphereCenterPoint.yf();
    this.center_z = sphereCenterPoint.zf();
    this.dest_x = sphereDestPoint.xf();
    this.dest_y = max(sphereDestPoint.yf(), 2.0 * FEET);
    this.dest_z = sphereDestPoint.zf();
    this.min_dist = min_dist;
    this.top_point = sphere.projectToSphere(new WB_Point(center.xf(), model.yMax, center.zf()));
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

  public boolean onHeart(float x, float y, float z) {
    float current_radius = this.radius_parameter.getValuef();

    float xUnit = current_radius;
    float yUnit = current_radius;
    float zUnit = current_radius;

    WB_Transform transformToHeartSystem = this.getCoordinateSystem().getTransformFromWorld();
    WB_Point heartPoint = transformToHeartSystem.applyAsPoint(x, y, z);

    x = heartPoint.xf() / xUnit;
    y = heartPoint.yf() / yUnit;
    z = heartPoint.zf() / zUnit;

    float part1 = pow( ((2.0 * pow(x, 2)) + (2.0 * pow(y, 2)) + pow(z, 2) - 1), 3);
    float part2 = 0.1 * pow(x, 2) * pow(z, 3);
    float part3 = pow(y, 2)* pow(z, 3);
    float result = part1 - part2 - part3;

    return (result <= current_radius);
  }    
  
  public WB_CoordinateSystem getCoordinateSystem() {
    WB_CoordinateSystem coordinateSystem = new WB_CoordinateSystem();    
    coordinateSystem.setOrigin(this.center_x, this.center_y, this.center_z);
    coordinateSystem.setY(this.top_point);
    coordinateSystem.setZ(this.sphere.getCenter());
        
    return coordinateSystem;
  }
}

public class LightningBolt extends LXLayer implements LXParameterListener {
  HE_Vertex originVertex;
  List<LEDomeEdge> adjacentEdges = new ArrayList<LEDomeEdge>();
  List<LEDomeEdge> allEdges = new ArrayList<LEDomeEdge>();
  List<List<LEDomeEdge>> branches = new ArrayList<List<LEDomeEdge>>();
  
  BoundedParameter branchLength;
  BoundedParameter strikeDuration;
  BoundedParameter cooldownDuration;
  BoundedParameter chillDuration;
  BooleanParameter triggerParameter;
  
  LinearEnvelope strikeModulator;
  QuadraticEnvelope cooldownModulator;
  LinearEnvelope chillModulator;
  
  private final int BRANCH_COUNT = 3;
  
  private static final int PHASE_STRIKE = 0;
  private static final int PHASE_COOLDOWN = 1;
  private static final int PHASE_CHILL = 2;
  
  // Radians
  private static final float MAX_ANGLE = 2;
  private static final float MIN_ANGLE = PI / 3.0;
    
  private Random randomPointIndex = new Random();
  private int currentPhase = 0;
  private float hue = 0;
  
  public LightningBolt(LX lx) {
    this(
      lx,
      new BoundedParameter("LNTH", 4, 4, 4),
      new BoundedParameter("STRK", 100, 0, 10000),
      new BoundedParameter("COOL", 1000, 1, 10000),
      new BoundedParameter("CHILL", 10000, 1, 30000),
      new BooleanParameter("TRIG", false)
    );
  }
  
  public LightningBolt(LX lx, BoundedParameter branchLength, BoundedParameter strikeDuration, BoundedParameter cooldownDuration, BoundedParameter chillDuration, BooleanParameter triggerParameter) {
    super(lx);    
    this.branchLength = branchLength;
    this.strikeDuration = strikeDuration;
    this.cooldownDuration = cooldownDuration;
    this.chillDuration = chillDuration;
    
    this.triggerParameter = triggerParameter;
    this.triggerParameter.addListener(this);
    
    this.initializeModulators();
  }
  
  public void onParameterChanged(LXParameter parameter) {
    if (!(parameter == this.triggerParameter)) { return; }
   
    if (this.currentPhase == PHASE_CHILL && this.triggerParameter.getValueb()) { this.reset(); }
  }
    
  public void run(double deltaMs) {
    switch(this.currentPhase) {
      case PHASE_STRIKE:
        // We just finished the phase, move on.
        if (this.strikeModulator.finished()) {
          this.strikeModulator.reset();
          this.currentPhase++;
        } else {        
          // We haven't yet triggered the modulator, we just entered the phase.
          if (!this.strikeModulator.isRunning()) {
            this.strike();
          }
          
          this.drawStrike();
          break;
        }
        
      case PHASE_COOLDOWN:
        if (this.cooldownModulator.finished()) {
          this.cooldownModulator.reset();
          this.currentPhase++;
          return;
        }
        if (!this.cooldownModulator.isRunning()) {
          this.cooldownModulator.trigger();          
        }
        this.drawCooldowm();
        break;
      
      case PHASE_CHILL:
        if (this.chillModulator.finished()) {
          this.chillModulator.reset();          
          this.currentPhase = PHASE_STRIKE;
          return;
        }
        if (!this.chillModulator.isRunning()) {
          this.chillModulator.trigger();
          this.chillModulator.randomBasis();
        }
        break;        
    }
  }
  
  public void drawStrike() {
    int maxBranchIndex = (int)this.strikeModulator.getValue();
    
    for(List<LEDomeEdge> branch: branches) {
      for(int i = 0; i <= maxBranchIndex; i++) {
        if (i >= branch.size()) { continue; }
        
        for (LXPoint p: branch.get(i).points) {
          setColor(p.index, LX.hsb(this.hue, 40, 100));  
        }
      }
    }
  }
  
  public void drawCooldowm() {
    for(LEDomeEdge edge: this.allEdges) {
      for (LXPoint p: edge.points) {
        setColor(p.index, LX.hsb(this.hue, 40 * this.cooldownModulator.getValuef(), 100 * this.cooldownModulator.getValuef()));  
      }
    }
  }
  
  public void initializeModulators() {
    this.strikeModulator = new LinearEnvelope("STRK", 0, this.branchLength, this.strikeDuration);
    this.cooldownModulator = new QuadraticEnvelope("COOL", 1, 0, this.cooldownDuration);
    this.cooldownModulator.setEase(QuadraticEnvelope.Ease.OUT);
    this.chillModulator = new LinearEnvelope("CHIL", 0, 1, this.chillDuration);
    
    addModulator(this.strikeModulator);
    addModulator(this.cooldownModulator);
    addModulator(this.chillModulator);
  }
  
  private void reset() {
    this.strikeModulator.reset();
    this.cooldownModulator.reset();    
    this.chillModulator.reset();    
    this.currentPhase = PHASE_STRIKE;
  }
  
  private void strike() {
    this.adjacentEdges.clear();
    this.allEdges.clear();
    this.branches.clear();
    
    this.hue = randomPointIndex.nextFloat() * 360;
    this.initializeBranches();
    for(List<LEDomeEdge> branch: this.branches) {
      this.buildBranch(branch);
    }
        
    this.strikeModulator.trigger();    
  }
  
  private void initializeBranches() {
    // Find a new center point for the lightning stike
    LXPoint newCenterPoint = model.points[randomPointIndex.nextInt(model.points.length)];
    this.originVertex = ((LEDome)model).closestVertex(newCenterPoint);
    List<HE_Halfedge> neighbors = originVertex.getHalfedgeStar();    
    Collections.shuffle(neighbors);
        
    for(HE_Halfedge he_edge : neighbors) {
      // Skip edges without labels
      if (he_edge.getLabel() < 0) { continue; }

      // Find the LEDomeEdge with the correct label. 
      LEDomeEdge edge = ((LEDome)model).edges.get(he_edge.getLabel());

      // Continue if the edge doesn't have lights
      if (edge == null) { continue; }
      
      int adjacentLabel = he_edge.getPair().getLabel();
      if(adjacentLabel >= 0) {
        LEDomeEdge adjacentEdge = ((LEDome)model).edges.get(he_edge.getPair().getLabel());
        if (adjacentEdge != null) { this.adjacentEdges.add(adjacentEdge); }
      }      

      // Create the list of edges that will make up the branches starting with this edge.
      List<LEDomeEdge> branch = new ArrayList<LEDomeEdge>();
      branch.add(edge);
      this.allEdges.add(edge);
      this.branches.add(branch);
      
      // Stop creating branches if we have enough.
      if(this.branches.size() >= BRANCH_COUNT) {
        break;
      }
    }
  }
  
  private void buildBranch(List<LEDomeEdge> branch) {    
    float prevX = originVertex.xf();
    float prevY = originVertex.yf();
    float prevZ = originVertex.zf();
    LEDomeEdge prevEdge = branch.get(0);    
    
    while(true) {
      LXPoint farthestPoint = prevEdge.farthestPoint(prevX, prevY, prevZ);
      LEDomeEdge edge = this.findNextBranchEdge(prevEdge, farthestPoint);
      // No edge found, break;
      if (edge == null) { break; }
      
      branch.add(edge);
      this.allEdges.add(edge);
      
      // We've reached the end of the branch, break
      if(branch.size() >= (int)this.branchLength.getValue()) {
        break;
      }
           
      prevEdge = edge;
      prevX = farthestPoint.x;
      prevY = farthestPoint.y;
      prevX = farthestPoint.z;
    }
  }
  
  private LEDomeEdge findNextBranchEdge(LEDomeEdge prevEdge, LXPoint farthestPoint) {    
    HE_Vertex nextVertex = ((LEDome)model).closestVertex(farthestPoint);
    
    List<HE_Halfedge> neighbors = nextVertex.getHalfedgeStar();
    Collections.shuffle(neighbors);
    
    for(HE_Halfedge he_edge : neighbors) {
      // Skip edges without labels
      if (he_edge.getLabel() < 0) { continue; }

      // Find the LEDomeEdge with the correct label. 
      LEDomeEdge edge = ((LEDome)model).edges.get(he_edge.getLabel());

      // Continue if the edge doesn't have lights
      if (edge == null) { continue; }
      
      // Do not add already existing edges
      if (this.allEdges.contains(edge) || this.adjacentEdges.contains(edge)) { continue; }
      
      float angleBetweenEdges = ((LEDome)model).angleBetweenEdges(prevEdge, edge);
      if (angleBetweenEdges < MIN_ANGLE || angleBetweenEdges > MAX_ANGLE) { continue; }      
      
      int adjacentLabel = he_edge.getPair().getLabel();
      if(adjacentLabel >= 0) {
        LEDomeEdge adjacentEdge = ((LEDome)model).edges.get(he_edge.getPair().getLabel());
        if (adjacentEdge != null) { this.adjacentEdges.add(adjacentEdge); }
      }
      
      return edge;
    }
    
    return null;
  }
}