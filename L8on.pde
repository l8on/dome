class ShadyWaffle extends LEDomePattern { 
  private final float E = exp(1);
  
  private int PINK = LX.hsb(330, 59, 100);
  
  private int[] PINK_EDGES = { 
    // Pentagon opposite door, left 
    127, 130, 109, 103, 106,
    // Pentagon opposite door, right
    187, 190, 166, 196, 163,
    // Pentagon left
    217, 247, 250, 232, 262,
    // Pentagon right
    40, 37, 67, 46, 70, 
    // Top
    85, 145, 205, 289, 25, 
  };
  
  private int YELLOW = LX.hsb(61, 90, 89);
  
  private int[] YELLOW_SPOKES = {
     // Pentagon opposite door, left
    126, 128, 129, 131, 102, 104, 105, 107, 108, 110,
    // Pentagon opposite door, right  
    186, 188, 189, 191, 165, 167, 195, 197, 162, 164,
    // Pentagon left
    216, 218, 246, 248, 249, 251, 231, 233, 261, 263,
    // Pentagon righT
    39,  41,  36,  38,  66,  68,  45,  47,  69,  71,
    // Top
    84,  86, 144, 146, 204, 206, 288, 290,  24,  26
  };
  
  private int BLUE = LX.hsb(239, 61, 100);
  private int[] BLUE_FACES = {
    33, 39, 45, 51, 57,
    63, 68, 73, 78, 83,
    85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99  
  };
 
  private int PURPLE = LX.hsb(293, 72, 82);
  
  private int[] PURPLE_FACES = {
    2, 5, 8, 11, 14, 20, 23, 26, 29,
    62, 64, 67, 69, 72, 74, 77, 79, 82, 84
  };
 
  private int TEAL = LX.hsb(177, 97, 91);
  
  private int[] TEAL_FACES = {
    0, 1, 32, 3, 4, 34,
    6, 7, 38, 9, 10, 40,
    12, 13, 44, 15, 46, 
    19, 50, 21, 22, 52,
    24, 25, 56, 27, 28, 58
  };
 
  private SinLFO[] breathers = new SinLFO[lx.total]; 
  private BasicParameter rateParam = new BasicParameter("RATE", 2.5, 0.5, 12);
  
  public ShadyWaffle(LX lx) {
    super(lx);

    addParameter(rateParam);
    initBreathers();
  }  
  
  public double getRate() {
    float varianceRange = 0.2;
    float rate = rateParam.getValuef();
    float variance = random(-varianceRange, varianceRange) * rate;
    return (rate + variance) * SECONDS;
  }

  private void initBreathers() {
    for (int p = 0; p < lx.total; p++) {
      breathers[p] = new SinLFO(-1, 1, getRate());
      breathers[p].setLooping(false);
      addModulator(breathers[p]).start();
    }
  }
  
  public void resetBreather(int p) {
    breathers[p].setPeriod(getRate());
    breathers[p].setBasis(random(0.02, 0.15));
    breathers[p].start();
  }

  public void run(double deltaMs) {
  
    // Draw spokes first. 
    for(int i : YELLOW_SPOKES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = YELLOW; 
      }
    }
    
    // Cover pink edges of pentagons 
    for(int i : PINK_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = PINK; 
      }
    }
  
    // Color faces
    for(int i : BLUE_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = BLUE; 
      }
    }
    
    for(int i : PURPLE_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = PURPLE; 
      }
    }
    
    for(int i : TEAL_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = TEAL; 
      }
    }
    
    for (LXPoint p : model.points) {
      if(!breathers[p.index].isRunning()) {
        this.resetBreather(p.index);
      }
      
      double breath = norm(-exp(breathers[p.index].getValuef()), -1/E, -E);
      double brightness = 50 + breath * 50;
      colors[p.index] = LXColor.hsb(LXColor.h(colors[p.index]), LXColor.s(colors[p.index]), brightness);
    }
  }
}

class HeartsBeat extends LEDomePattern {
  private final float E = exp(1);  
  private final int NUM_HEARTS = 3;
  
  private int[] HEART_1_FACES = {
    27, 57, 58, 59, 83, 60
  };  
 
  private int[] HEART_1_EDGES = {
    126, 110, 74, 63, 78, 79
  };
  
  private int[] HEART_2_FACES = {
    64, 87, 88, 89, 101, 90
  };  
 
  private int[] HEART_2_EDGES = {
    111, 86, 236, 198, 204, 205
  };
  
  private int[] HEART_3_FACES = {
    13, 43, 44, 45, 71, 73
  };  
 
  private int[] HEART_3_EDGES = {
    248, 275, 279, 231, 259, 260
  };
  
  private SinLFO[] heartColors = new SinLFO[NUM_HEARTS];  
  private SinLFO[] heartBeats = new SinLFO[NUM_HEARTS];
  private SinLFO[] heartSaturations = new SinLFO[NUM_HEARTS];
  private BasicParameter rateParam = new BasicParameter("RATE", 2.5, 0.5, 12);
  private BasicParameter brightnessParam = new BasicParameter("BRIG", 90, 50, 100);  
  
  public HeartsBeat(LX lx) {
    super(lx);    

    addParameter(rateParam);
    addParameter(brightnessParam);
    initHeartModulators();
  }
  
  public double getRate() {
    float varianceRange = 0.3;
    float rate = rateParam.getValuef();
    float variance = random(-varianceRange, varianceRange) * rate;
    return (rate + variance) * SECONDS;
  }

  private void initHeartModulators() {
    for(int i = 0; i< NUM_HEARTS; i++) {
      this.heartColors[i] = new SinLFO(320, 359, 2 * getRate());
      this.heartColors[i].setLooping(false);
      addModulator(this.heartColors[i]).start();
      
      this.heartBeats[i] = new SinLFO(0, 1, getRate());
      this.heartBeats[i].setLooping(false);       
      addModulator(this.heartBeats[i]).start();
      
      this.heartSaturations[i] = new SinLFO(60, 100, getRate());
      this.heartSaturations[i].setLooping(false);
      addModulator(this.heartSaturations[i]).start();
    }
    
  }
  
  public void resetHeartBeat(int i) {
    this.heartBeats[i].setPeriod(getRate());
    this.heartBeats[i].setBasis(random(0.02, 0.15));
    this.heartBeats[i].start();
  }
  
  public void resetHeartColor(int i) {
    this.heartColors[i].setPeriod(2 * getRate());
    this.heartColors[i].setBasis(random(0.02, 0.15));
    this.heartColors[i].start();
  }
  
  public void resetHeartSaturation(int i) {
    this.heartSaturations[i].setPeriod(getRate());
    this.heartSaturations[i].setBasis(random(0.02, 0.15));
    this.heartSaturations[i].start(); //<>//
  }
  
  public void run(double deltaMs) {
    setColors(0);
    
    for (int i = 0; i < NUM_HEARTS; i++) {
      if (!this.heartBeats[i].isRunning()) { this.resetHeartBeat(i); }
      if (!this.heartColors[i].isRunning()) { this.resetHeartColor(i); }
    } 
    
    for(int i : HEART_1_FACES) {            
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[0].getValuef(), 
          this.heartSaturations[0].getValuef(), 
          this.brightnessParam.getValuef()
        );
      }
    }
    
    for(int i : HEART_1_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[0].getValuef(), 
          this.heartSaturations[0].getValuef(),
          this.heartBeats[0].getValuef() * this.brightnessParam.getValuef()
        );
      }
    }
    
    for(int i : HEART_2_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[1].getValuef(), 
          this.heartSaturations[1].getValuef(),
          this.brightnessParam.getValuef()
        ); 
      }
    }
    
    for(int i : HEART_2_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[1].getValuef(), 
          this.heartSaturations[1].getValuef(), 
          this.heartBeats[1].getValuef() * this.brightnessParam.getValuef());
      }
    }
    
    for(int i : HEART_3_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[2].getValuef(), 
          this.heartSaturations[2].getValuef(),
          this.brightnessParam.getValuef()
        ); 
      }
    }
    
    for(int i : HEART_3_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[2].getValuef(), 
          this.heartSaturations[2].getValuef(),
          this.heartBeats[1].getValuef() * this.brightnessParam.getValuef()
        );
      }
    }
  }
}

class SnakeApple extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.  
  private List<Apple> apples = new ArrayList<Apple>();
  private List<Integer> appleIndices = new ArrayList<Integer>();
  private Random appleRandom = new Random();
   
  private BasicParameter snakeSpeed = new BasicParameter("SPD", 86.0, 6.0, 520.0);
  private BasicParameter numApples = new BasicParameter("APL", 50.0, 10.0, 100.0);
    
  private final int SNAKES = 3;
  private final int HUES = 6;
  private final int BRIGHTS = 5;
  
  private SnakeLayer[] snakes = new SnakeLayer[SNAKES];
  private BasicParameter[] lengthParameters = new BasicParameter[SNAKES];
  private LXModulator[] hueMods = new SinLFO[HUES];
  private LXModulator[] brightnessMods = new SinLFO[BRIGHTS];
  
  public SnakeApple(LX lx) {
    super(lx);
    
    addParameter(snakeSpeed);
    addParameter(numApples);
    
    initHues();
    initBrights();
    initSnakes();

    resetSnakeApple();
  }
  
  public void run(double deltaMs) {  
    for(LXPoint p : model.points) {
      Apple currApple = null;
      int winnerSnake = -1;
      int numSnakesOn = 0;
      
      
      for(Apple apple : this.apples) {
        if (apple.index == p.index) {
          currApple = apple;
          break;
        }
      }

      for(int i = 0; i < SNAKES; i++) {
        if(this.snakes[i].hasPoint(p)) {
          if (numSnakesOn == 0 || this.lengthParameters[i].getValue() > this.lengthParameters[winnerSnake].getValue() || appleRandom.nextInt(numSnakesOn) == 0) {
            winnerSnake = i;
          }
          
          numSnakesOn++;          
        }
      }
      
      if(numSnakesOn > 0 && currApple != null) {
        this.snakes[winnerSnake].hue = currApple.hue + hueMods[p.index % HUES].getValuef();
        this.apples.remove(currApple);
        this.lengthParameters[winnerSnake].incrementValue(3.0);

        colors[p.index] = this.snakes[winnerSnake].colorOf(p.index);
      } if(numSnakesOn > 0) {
        colors[p.index] = this.snakes[winnerSnake].colorOf(p.index);
      } else if(currApple != null) {
        LXModulator appleHueMod = hueMods[p.index % HUES];
        LXModulator brightnessMod = brightnessMods[p.index % BRIGHTS];
        colors[p.index] = LX.hsb((currApple.hue + appleHueMod.getValuef()) % 360, 100.0, brightnessMod.getValuef());
      } else {
        colors[p.index] = LX.hsb(0, 0, 0);
      }  
    }
    
    if(this.apples.size() == 0) {
      this.resetSnakeApple();
    }
  }
  
  private void initSnakes() {
    for(int i = 0; i < SNAKES; i++) {
      this.lengthParameters[i] = new BasicParameter("LNG" + i, 4.0, 4.0, 582.0);
      this.snakes[i] = new SnakeLayer(lx, this.lengthParameters[i], this.snakeSpeed);
      addLayer(this.snakes[i]);
    }
  }

  private void initHues() {
    for (int i = 0; i < HUES; i++) {
      hueMods[i] = new SinLFO(-40.0, 40.0, 6000 + (appleRandom.nextFloat() * 4000));
      addModulator(hueMods[i]).start();    
    }
  }
  
  private void initBrights() {
    for (int i = 0; i < BRIGHTS; i++) {
      brightnessMods[i] = new SinLFO(45.0, 95.0, 4000 + (appleRandom.nextFloat() * 6000));
      addModulator(brightnessMods[i]).start();
    }
  }
 
  private void resetSnakeApple() {
    placeApples();
    startSnakes();
  }
  
  private void placeApples() {
    this.apples.clear();
    this.appleIndices.clear();
    int totalApples = (int) this.numApples.getValue();
    
    while(this.apples.size() < totalApples) {
      LXPoint point = model.points.get(this.appleRandom.nextInt(model.points.size()));
      if (appleIndices.contains(point.index)) { continue; }

      float hueValue = this.appleRandom.nextFloat() * 360;
      this.apples.add(new Apple(point.index, hueValue));
      this.appleIndices.add(point.index);
    }
  }
  
  private void startSnakes() {
    for(int i = 0; i < SNAKES; i++) {
      this.snakes[i].hue = appleRandom.nextFloat() * 360.0;
      this.lengthParameters[i].reset();
      this.snakes[i].restartSnake();
    }
  } 
}

class Snakes extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<SnakeLayer> snakes = new ArrayList<SnakeLayer>();
  private BasicParameter numSnakes = new BasicParameter("NUM", 3.0, 1.0, 30.0);
  private BasicParameter snakeSpeed = new BasicParameter("SPD", 86.0, 6.0, 640.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 95.0, 10.0, 100.0);
  private BasicParameter lengthParameter = new BasicParameter("LNGT", 11.0, 3.0, 48.0);  
  
  public String getName() { return "Snakes"; }

  public Snakes(LX lx) {
    super(lx);

    addParameter(numSnakes);
    addParameter(snakeSpeed);    
    addParameter(lengthParameter);

    initSnakes();
  }

  public void run(double deltaMs) {
    calibrateSnakes();
    
    float hueStep = 0;
    for(SnakeLayer snake: this.snakes) {
      snake.hue = LXUtils.wrapdistf(lx.getBaseHuef(), lx.getBaseHuef() + hueStep, 360);
      hueStep += 360.0 / (float)this.snakes.size();
    }
    
    for (LXPoint p : model.points) {
      int numSnakes = 0;
      
      for(SnakeLayer snake: this.snakes) {
        if (!snake.hasPoint(p)) { continue; }
        
        numSnakes++;
        
        if (numSnakes == 1) {
          colors[p.index] = snake.colorOf(p.index);        
        } else {
          colors[p.index] = this.blendSnakes(colors[p.index], snake.colorOf(p.index), numSnakes);
        }
        
      }
      
      if (numSnakes == 0) {        
        colors[p.index] = LX.hsb(LXColor.h(colors[p.index]), LXColor.s(colors[p.index]), 0.0);
      }
    }
  }
  
  public color blendSnakes(int startColor, int nextColor, int numSnakes) {
    if (numSnakes == 1) { return nextColor; }
        
    float h, s, b, minHue, maxHue;
    float startHue = LXColor.h(startColor);
            
    minHue = min(startHue, LXColor.h(nextColor));
    maxHue = max(startHue, LXColor.h(nextColor));
    h = (minHue * 2.0 + maxHue / 2.0) / 2.0;
    s = (LXColor.s(startColor) + LXColor.s(nextColor)) / 2.0;
    b = (LXColor.b(startColor) + LXColor.b(nextColor)) / 2.0;
    
    return LXColor.hsb(h, s, b);
  }

  public void initSnakes() {
    snakes.clear();
    
    for(int i = 0; i < (int)this.numSnakes.getValuef(); i++) {
      SnakeLayer snake = new SnakeLayer(lx, lengthParameter, snakeSpeed, brightnessParameter);
      snakes.add(snake);
      addLayer(snake);
    }
  }
  
  public void calibrateSnakes() {
    if ((int)this.numSnakes.getValue() == this.snakes.size()) { return; }
  
    if ((int)this.numSnakes.getValue() < this.snakes.size()) {
      for(int i = (this.snakes.size() - 1); i >= (int)this.numSnakes.getValue(); i--) {
        this.snakes.remove(i);
      }
    } else {
      for(int i = 0; i < ((int)this.numSnakes.getValuef() - this.snakes.size()); i++) {
        SnakeLayer snake = new SnakeLayer(lx, lengthParameter, snakeSpeed, brightnessParameter);
        snakes.add(snake);
        addLayer(snake);
      }
    }
  }
}

class Explosions extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onExplosion> explosions = new ArrayList<L8onExplosion>();
  private final SinLFO saturationModulator = new SinLFO(70.0, 90.0, 20 * SECONDS);
  private BasicParameter numExplosionsParameter = new BasicParameter("NUM", 2.0, 1.0, 30.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);

  private BasicParameter rateParameter = new BasicParameter("RATE", 4000.0, 500.0, 20000.0);
  private BasicParameter blurParameter = new BasicParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public Explosions(LX lx) {
    super(lx);

    addParameter(numExplosionsParameter);
    addParameter(brightnessParameter);

    addParameter(rateParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();

    initExplosions();
  }

  public void run(double deltaMs) {
    initExplosions();

    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.explosions.size());

    for(L8onExplosion explosion : this.explosions) {
      if (explosion.isChillin((float)deltaMs)) {
        continue;
      }
 
      explosion.hue_value = (float)(base_hue % 360.0);
      base_hue += wave_hue_diff;

      if (!explosion.hasExploded()) {
        explosion.explode();
      } else if (explosion.isFinished()) {
        assignNewCenter(explosion);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      int num_explosions_in = 0;

      for(L8onExplosion explosion : this.explosions) {
        if(explosion.isChillin(0)) {
          continue;
        }

        if(explosion.onExplosion(p.x, p.y, p.z)) {
          num_explosions_in++;

          if(num_explosions_in == 1) {
            hue_value = explosion.hue_value;
          } if(num_explosions_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, explosion.hue_value);
            max_hv = max(hue_value, explosion.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before blending again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, explosion.hue_value);
            max_hv = max(hue_value, explosion.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_explosions_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), 0.0);
      }

      colors[p.index] = c;
    }
  }

  private void initExplosions() {
    int num_explosions = (int) numExplosionsParameter.getValue();

    if (this.explosions.size() == num_explosions) {
      return;
    }

    if (this.explosions.size() < num_explosions) {
      for(int i = 0; i < (num_explosions - this.explosions.size()); i++) {
        float stroke_width = this.new_stroke_width();
        QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
        new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);
        WB_Point new_center = model.randomFaceCenter();
        addModulator(new_radius_env);
        this.explosions.add(
          new L8onExplosion(new_radius_env, stroke_width, new_center.xf(), new_center.yf(), new_center.zf())
        );
      }
    } else {
      for(int i = (this.explosions.size() - 1); i >= num_explosions; i--) {
        this.explosions.remove(i);
      }
    }
  }

  private void assignNewCenter(L8onExplosion explosion) {
    float stroke_width = this.new_stroke_width();
    WB_Point new_center = model.randomFaceCenter();
    float chill_time = (3.0 + random(7)) * SECONDS;
    QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
    new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);

    explosion.setCenter(new_center.xf(), new_center.yf(), new_center.zf());
    addModulator(new_radius_env);
    explosion.setRadiusModulator(new_radius_env, stroke_width);
    explosion.setChillTime(chill_time);
  }

  public float new_stroke_width() {
    return 3 * INCHES + random(6 * INCHES);
  }
}

class SpotLights extends LEDomePattern {
  // Used to store info about each spotlight.
  // See L8onUtil.pde for the definition.
  private List<L8onSpotLight> spotlights = new ArrayList<L8onSpotLight>();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);

  // Controls the radius of the spotlights.
  private BasicParameter radiusParameter = new BasicParameter("RAD", 2.0 * FEET, 1.0, model.xRange / 2.0);
  private BasicParameter numLightsParameter = new BasicParameter("NUM", 3.0, 1.0, 30.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);

  private BasicParameter rateParameter = new BasicParameter("RATE", 4000.0, 1.0, 10000.0);
  private BasicParameter restParameter = new BasicParameter("REST", 900.0, 1.0, 10000.0);
  private BasicParameter delayParameter = new BasicParameter("DELAY", 0, 0.0, 2000.0);
  private BasicParameter minDistParameter = new BasicParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BasicParameter blurParameter = new BasicParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public SpotLights(P2LX lx) {
    super(lx);

    addParameter(radiusParameter);
    addParameter(numLightsParameter);
    addParameter(brightnessParameter);

    addParameter(rateParameter);
    addParameter(restParameter);
    addParameter(delayParameter);
    addParameter(minDistParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();

    initL8onSpotlights();
  }

  public void run(double deltaMs) {
    initL8onSpotlights();
    float spotlight_radius = radiusParameter.getValuef();
    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.spotlights.size());
    float dist_from_dest;

    for(L8onSpotLight spotlight : this.spotlights) {
      spotlight.hue_value = base_hue;
      base_hue += wave_hue_diff;
      dist_from_dest = spotlight.distFromDestination();

      if (dist_from_dest < 0.01) {
        if(spotlight.time_at_dest_ms > restParameter.getValuef()) {
          // Will set a new destination if first guess is greater than min distance.
          // Otherwise, will keep object as is and try again next tick.
          spotlight.tryNewDestination();
        } else {
          spotlight.addTimeAtDestination((float)deltaMs);
        }
      } else {
        float dist_to_travel = rateParameter.getValuef() / ((float)deltaMs * 100);
        float dist_to_travel_perc = min(dist_to_travel / dist_from_dest, 1.0);

        spotlight.movePercentageTowardDestination(dist_to_travel_perc);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      int num_spotlights_in = 0;

      for(L8onSpotLight spotlight : this.spotlights) {
        float dist_from_spotlight = dist(spotlight.center_x, spotlight.center_y, spotlight.center_z, p.x, p.y, p.z);

        if(dist_from_spotlight <= spotlight_radius) {
          num_spotlights_in++;

          if(num_spotlights_in == 1) {
            hue_value = spotlight.hue_value;
          } if(num_spotlights_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, spotlight.hue_value);
            max_hv = max(hue_value, spotlight.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before blending again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, spotlight.hue_value);
            max_hv = max(hue_value, spotlight.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_spotlights_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), L8onUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs));
      }

      colors[p.index] = c;
    }
  }

  /**
   * Initialize the waves.
   */
  private void initL8onSpotlights() {
    int num_spotlights = (int) numLightsParameter.getValue();
    if (this.spotlights.size() == num_spotlights) {
      return;
    }

    if (this.spotlights.size() < num_spotlights) {
      float min_dist = minDistParameter.getValuef();

      for(int i = 0; i < (num_spotlights - this.spotlights.size()); i++) {
        this.spotlights.add(
          new L8onSpotLight(model.sphere,
                            model.xMin + random(model.xRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            model.yMin + random(model.yRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            min_dist)
        );
      }
    } else {
      for(int i = (this.spotlights.size() - 1); i >= num_spotlights; i--) {
        this.spotlights.remove(i);
      }
    }
  }
}

class DarkLights extends LEDomePattern {
  // Used to store info about each spotlight.
  // See L8onUtil.pde for the definition.
  private List<L8onSpotLight> spotlights = new ArrayList<L8onSpotLight>();
  private final int faceCount = model.faces.size();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);
  private final SawLFO currIndex = new SawLFO(0, faceCount, 5000);

  // Controls the radius of the spotlights.
  private BasicParameter radiusParameter = new BasicParameter("RAD", 2.0 * FEET, 1.0, model.xRange / 2.0);
  private BasicParameter numLightsParameter = new BasicParameter("NUM", 20.0, 1.0, 50.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);

  private BasicParameter rateParameter = new BasicParameter("RATE", 4000.0, 1.0, 10000.0);
  private BasicParameter restParameter = new BasicParameter("REST", 1000.0, 1.0, 10000.0);
  private BasicParameter delayParameter = new BasicParameter("DELAY", 0, 0.0, 2000.0);
  private BasicParameter minDistParameter = new BasicParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BasicParameter blurParameter = new BasicParameter("BLUR", 0.55);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public DarkLights(P2LX lx) {
    super(lx);

    addParameter(radiusParameter);
    addParameter(numLightsParameter);
    addParameter(brightnessParameter);

    addParameter(rateParameter);
    addParameter(restParameter);
    addParameter(delayParameter);
    addParameter(minDistParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();
    addModulator(currIndex).start();

    initL8onSpotlights();
  }

  public void run(double deltaMs) {
    int index = (int)currIndex.getValuef();
    int effectiveIndex;    
    float dist_from_dest;
    boolean is_on_spotlight = false;
    
    float hue;
    float saturation = saturationModulator.getValuef();
    float brightness = brightnessParameter.getValuef();    
    float spotlight_radius = radiusParameter.getValuef();

    initL8onSpotlights();
    for(L8onSpotLight spotlight : this.spotlights) {            
      dist_from_dest = spotlight.distFromDestination();

      if (dist_from_dest < 0.01) {
        if(spotlight.time_at_dest_ms > restParameter.getValuef()) {
          // Will set a new destination if first guess is greater than min distance.
          // Otherwise, will keep object as is and try again next tick.
          spotlight.tryNewDestination();
        } else {
          spotlight.addTimeAtDestination((float)deltaMs);
        }
      } else {
        float dist_to_travel = rateParameter.getValuef() / ((float)deltaMs * 100);
        float dist_to_travel_perc = min(dist_to_travel / dist_from_dest, 1.0);

        spotlight.movePercentageTowardDestination(dist_to_travel_perc);
      }
    }

    for (int i = 0; i < faceCount; i++) {
      LEDomeFace face = model.faces.get(i);
      if(!face.hasLights()) {
        continue;
      }
      
      effectiveIndex = (i + index) % faceCount;
      for (LXPoint p : face.points) {
        is_on_spotlight = false;
        
        for(L8onSpotLight spotlight : this.spotlights) {
          float dist_from_spotlight = dist(spotlight.center_x, spotlight.center_y, spotlight.center_z, p.x, p.y, p.z);
          
          if(dist_from_spotlight <= spotlight_radius) {
            is_on_spotlight = true;
            continue;
          }
        }
        
        if (is_on_spotlight) {
          colors[p.index] = LX.hsb(0, 0, 0);
        } else {        
          hue = effectiveIndex / float(faceCount) * 360;        
          colors[p.index] = LX.hsb(hue, saturation, brightness);
        }
      }
    }
  }

  /**
   * Initialize the waves.
   */
  private void initL8onSpotlights() {
    int num_spotlights = (int) numLightsParameter.getValue();
    if (this.spotlights.size() == num_spotlights) {
      return;
    }

    if (this.spotlights.size() < num_spotlights) {
      float min_dist = minDistParameter.getValuef();

      for(int i = 0; i < (num_spotlights - this.spotlights.size()); i++) {
        this.spotlights.add(
          new L8onSpotLight(model.sphere,
                            model.xMin + random(model.xRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            model.yMin + random(model.yRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            min_dist)
        );
      }
    } else {
      for(int i = (this.spotlights.size() - 1); i >= num_spotlights; i--) {
        this.spotlights.remove(i);
      }
    }
  }
}

class HeartExplosions extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onHeartExplosion> hearts = new ArrayList<L8onHeartExplosion>();
  private final SinLFO saturationModulator = new SinLFO(70.0, 90.0, 20 * SECONDS);
  private BasicParameter numHeartsParameter = new BasicParameter("NUM", 2.0, 1.0, 30.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);

  private BasicParameter rateParameter = new BasicParameter("RATE", 4000.0, 500.0, 20000.0);
  private BasicParameter blurParameter = new BasicParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public HeartExplosions(LX lx) {
    super(lx);

    addParameter(numHeartsParameter);
    addParameter(brightnessParameter);

    addParameter(rateParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();

    initHearts();
  }

  public void run(double deltaMs) {
    initHearts();

    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.hearts.size());

    for(L8onHeartExplosion heart : this.hearts) {
      if (heart.isChillin((float)deltaMs)) {
        continue;
      }
 
      heart.hue_value = (float)(base_hue % 360.0);
      base_hue += wave_hue_diff;

      if (!heart.hasExploded()) {
        heart.explode();
      } else if (heart.isFinished()) {
        assignNewCenter(heart);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      int num_explosions_in = 0;

      for(L8onHeartExplosion heart : this.hearts) {
        if(heart.isChillin(0)) {
          continue;
        }

        if(heart.onHeart(p.x, p.y, p.z)) {
          num_explosions_in++;

          if(num_explosions_in == 1) {
            hue_value = heart.hue_value;
          } if(num_explosions_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, heart.hue_value);
            max_hv = max(hue_value, heart.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before blending again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, heart.hue_value);
            max_hv = max(hue_value, heart.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_explosions_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), 0.0);
      }

      colors[p.index] = c;
    }
  }

  private void initHearts() {
    int num_hearts = (int) numHeartsParameter.getValue();

    if (this.hearts.size() == num_hearts) {
      return;
    }

    if (this.hearts.size() < num_hearts) {
      for(int i = 0; i < (num_hearts - this.hearts.size()); i++) {
        float stroke_width = this.new_stroke_width();
        QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, 3 * model.xRange, rateParameter);
        new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);
        WB_Point new_center = model.randomFaceCenter();
        addModulator(new_radius_env);
        this.hearts.add(
          new L8onHeartExplosion(new_radius_env, stroke_width, new_center.xf(), new_center.yf(), new_center.zf())
        );
      }
    } else {
      for(int i = (this.hearts.size() - 1); i >= num_hearts; i--) {
        this.hearts.remove(i);
      }
    }
  }

  private void assignNewCenter(L8onHeartExplosion heart) {
    float stroke_width = this.new_stroke_width();
    WB_Point new_center = model.randomFaceCenter();
    float chill_time = (3.0 + random(7)) * SECONDS;
    QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
    new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);

    heart.setCenter(new_center.xf(), new_center.yf(), new_center.zf());
    addModulator(new_radius_env);
    heart.setRadiusModulator(new_radius_env, stroke_width);
    heart.setChillTime(chill_time);
  }

  public float new_stroke_width() {
    return 3 * INCHES + random(6 * INCHES);
  }
}

class HeartLights extends LEDomePattern {
  // Used to store info about each heartlight.
  // See L8onUtil.pde for the definition.
  private List<L8onHeartLight> heartlights = new ArrayList<L8onHeartLight>();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);

  // Controls the radius of the spotlights.
  private BasicParameter radiusParameter = new BasicParameter("RAD", 4.0 * FEET, 2.0, model.xRange);
  private BasicParameter numLightsParameter = new BasicParameter("NUM", 3.0, 1.0, 30.0);
  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 50, 10, 80);

  private BasicParameter rateParameter = new BasicParameter("RrATE", 4000.0, 1.0, 10000.0);
  private BasicParameter restParameter = new BasicParameter("REST", 900.0, 1.0, 10000.0);
  private BasicParameter delayParameter = new BasicParameter("DELAY", 0, 0.0, 2000.0);
  private BasicParameter minDistParameter = new BasicParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BasicParameter blurParameter = new BasicParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public HeartLights(P2LX lx) {
    super(lx);

    addParameter(radiusParameter);
    addParameter(numLightsParameter);
    addParameter(brightnessParameter);

    addParameter(rateParameter);
    addParameter(restParameter);
    addParameter(delayParameter);
    addParameter(minDistParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();

    initL8onHeartlights();
  }

  public void run(double deltaMs) {
    initL8onHeartlights();    
    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.heartlights.size());
    float dist_from_dest;

    for(L8onHeartLight heartlight : this.heartlights) {
      heartlight.hue_value = base_hue;
      base_hue += wave_hue_diff;
      dist_from_dest = heartlight.distFromDestination();

      if (dist_from_dest < 0.01) {
        if(heartlight.time_at_dest_ms > restParameter.getValuef()) {
          // Will set a new destination if first guess is greater than min distance.
          // Otherwise, will keep object as is and try again next tick.
          heartlight.tryNewDestination();
        } else {
          heartlight.addTimeAtDestination((float)deltaMs);
        }
      } else {
        float dist_to_travel = rateParameter.getValuef() / ((float)deltaMs * 100);
        float dist_to_travel_perc = min(dist_to_travel / dist_from_dest, 1.0);

        heartlight.movePercentageTowardDestination(dist_to_travel_perc);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      int num_spotlights_in = 0;

      for(L8onHeartLight heartlight : this.heartlights) {        
        if(heartlight.onHeart(p.x, p.y, p.z)) {
          num_spotlights_in++;

          if(num_spotlights_in == 1) {
            hue_value = heartlight.hue_value;
          } if(num_spotlights_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, heartlight.hue_value);
            max_hv = max(hue_value, heartlight.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before blending again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, heartlight.hue_value);
            max_hv = max(hue_value, heartlight.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_spotlights_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), L8onUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs));
      }

      colors[p.index] = c;
    }
  }

  /**
   * Initialize the waves.
   */
  private void initL8onHeartlights() {
    int num_heartlights = (int) numLightsParameter.getValue();
    if (this.heartlights.size() == num_heartlights) {
      return;
    }

    if (this.heartlights.size() < num_heartlights) {
      float min_dist = minDistParameter.getValuef();

      for(int i = 0; i < (num_heartlights - this.heartlights.size()); i++) {
        this.heartlights.add(
          new L8onHeartLight(model.sphere,
                            this.radiusParameter,
                            model.xMin + random(model.xRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            model.yMin + random(model.yRange), model.yMin + random(model.yRange), model.zMin + random(model.zRange),
                            min_dist)
        );
      }
    } else {
      for(int i = (this.heartlights.size() - 1); i >= num_heartlights; i--) {
        this.heartlights.remove(i);
      }
    }
  }
}

/**
 * 2 slanted breathing waves with bands of color.
 *
 * Each wave is a specific color, their intersection is the mix of those two colors.
 * Between each wave, there are a discrete number of bands of color.
 */
class L8onMixColor extends LEDomePattern {
  // Oscillators for the wave breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 20000);
  private final SinLFO yOffsetMax = new SinLFO( -1 * (model.yRange / 2.0) , model.yRange / 2.0, 20000);
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
  private BasicParameter saturationParameter = new BasicParameter("SAT", 65, 0, 100);
  // Controls the the amount of delay until a light is completely off.
  private BasicParameter delayParameter = new BasicParameter("DELAY", 500, 0.0, 2000.0);

  public L8onMixColor(P2LX lx) {
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
    addParameter(saturationParameter);
    addParameter(delayParameter);

    addModulator(xOffsetMax).trigger();
    addModulator(yOffsetMax).trigger();
    addModulator(zOffsetMax).trigger();
  }

  public void run(double deltaMs) {
    float offset_value_x = xOffsetMax.getValuef();
    float offset_value_z = zOffsetMax.getValuef();
    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.l8on_waves.size());

    for(L8onWave l8on_wave : this.l8on_waves) {
      l8on_wave.hue_value = base_hue;
      base_hue += wave_hue_diff;
    }

    color c;
//    float dist_percentage;
    float hue_value = 0.0;
    float sat_value = saturationParameter.getValuef();
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
//      float sin_x = sin(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float cos_x = cos(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float sin_y = sin(PI / 2 + numWavesY.getValuef() * PI * y_percentage);
//      float cos_y = cos(PI / 2 + numWavesY.getValuef() * PI * y_percentage);
      float sin_z = sin(PI / 2 + numWavesZ.getValuef() * PI * z_percentage);
//      float cos_z = cos(PI / 2 + numWavesZ.getValuef() * PI * z_percentage);

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
            // Jump color by 180 before blending again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, l8on_wave.hue_value);
            max_hv = max(hue_value, l8on_wave.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_waves_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), L8onUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs));
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

/**
 * A "Game of Life" simulation in 2 dimensions with the cubes as cells.
 *
 * The "DELAY parameter controls the rate of change.
 * The "MUT" parameter controls the probability of mutations. Useful when life oscillates between few states.
 * The "SAT" parameter controls the saturation.
 *
 * Thanks to Jack for starting me up, Tim for the parameter code, and Slee for the fade idea.
 */
class Life extends LEDomePattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 700, 0.0, 10 * SECONDS);
  // Controls the probability of a mutation in the cycleOfLife
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.03, 0.0, 0.2);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 75.0, 0.0, 100.0);
  
  private BasicParameter neighborCountParameter = new BasicParameter("NEIG", 0.0, -2.0, 2.0);

  // Alive probability ranges for randomization
  public final double MIN_ALIVE_PROBABILITY = 0.3;
  public final double MAX_ALIVE_PROBABILITY = 0.5;
  
  // The maximum brightness for an alive cell.
  public final float MAX_ALIVE_BRIGHTNESS = 75.0;

  // Cube position oscillator used to select color. 
  private final SinLFO facePos = new SinLFO(0, model.yRange, 10 * SECONDS);

  // Contains the state of all cubes by index.
  // See L8onUtil.pde for definition of L8onFaceLife.
  private List<L8onFaceLife> face_lives;

  private List<LEDomeFace> faces;
  // Contains the amount of time since the last cycle of life.
  private int time_since_last_run;
  // Boolean describing if life changes were made during the current run.
  private boolean any_changes_this_run;
  // Hold the new lives
  private List<Boolean> new_lives;

  public Life(P2LX lx) {
     super(lx);
     this.faces = model.faces;

     //Print debug info about the faces/edges.
     // outputFaceInfo();

     initFaceStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_lives = new ArrayList<Boolean>(this.faces.size());

     addParameter(rateParameter);
     addParameter(mutationParameter);
     addParameter(saturationParameter);
     addParameter(neighborCountParameter);

     addModulator(facePos).trigger();
  }

  public void run(double deltaMs) {
    any_changes_this_run = false;      
    new_lives.clear();
    time_since_last_run += deltaMs;

    for (L8onFaceLife face_life : this.face_lives) {
      LEDomeFace face = this.faces.get(face_life.index);

      if(shouldLightFace(face_life)) {
        lightLiveFace(face, face_life, deltaMs);
      } else if (face.hasLights()) {
        lightDeadFace(face, face_life, deltaMs);
      }
    }

    // If we have landed in a static state, randomize faces.
    if(!any_changes_this_run) {
      randomizeFaceStates();
      time_since_last_run = 0;
      return;
    } else {
      // Apply new states AFTER ALL new states are decided.
      applyNewLives();
    }

    // Reset "tick" timer
    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }
  }

  /**
   * Light a live face.
   * Uses deltaMs for fade effect.
   */
  private void lightLiveFace(LEDomeFace face, L8onFaceLife face_life, double deltaMs) {
    float face_dist = LXUtils.wrapdistf(face.yf() - model.yMin, facePos.getValuef(), model.yRange);
    float hv = (face_dist / model.yRange) * 360;
    float bv = face_life.current_brightness;

    // Only change brightness if we are between "ticks" or if there is not enough time to fade.
    if(!face_life.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = min(MAX_ALIVE_BRIGHTNESS, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(face_life.current_brightness < bv) {
        face_life.current_brightness = bv;
      } else {
        bv = face_life.current_brightness;
      }
    }

    for (LXPoint p : face.points) {
      colors[p.index] = LX.hsb(
        hv,
        saturationParameter.getValuef(),
        bv
      );
    }
  }

  /**
   * Light a dead face.
   * Uses deltaMs for fade effect.
   */
  private void lightDeadFace(LEDomeFace face, L8onFaceLife face_life, double deltaMs) {
    float face_dist = LXUtils.wrapdistf(face.yf() - model.yMin, facePos.getValuef(), model.yRange);
    float hv = (face_dist / model.yRange) * 360;
    float bv = face_life.current_brightness;

    // Only change brightness if we are between "ticks" or if there is not enough time to fade.
    if(!face_life.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = 1.0 - min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = max(0.0, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(face_life.current_brightness > bv) {
        face_life.current_brightness = bv;
      } else {
        bv = face_life.current_brightness;
      }
    }
    
    for (LXPoint p : face.points) {
      colors[p.index] = LX.hsb(
        hv,
        saturationParameter.getValuef(),
        bv
      );   
    }
  }
 
  /**
   * Output debug info about the dome.
   */
  private void outputFaceInfo() {
    int i = 0;
    for (LEDomeEdge edge : model.edges) {
      println("LEDomeEdge " + i + ": " + edge.xf() + "," + edge.yf() + "," + edge.zf());
      println("LEDomeEdge label: " + edge.he_halfedge.getLabel());
      ++i;
    }
  }

  /**
   * Initialize the list of face states.
   */
  private void initFaceStates() {
    boolean alive = false;
    L8onFaceLife face_life;
    this.face_lives = new ArrayList<L8onFaceLife>(this.faces.size());
    float current_brightness = 0.0;

    for (int i=0; i< this.faces.size(); i++) {
      alive = false;
      face_life = new L8onFaceLife(i, alive, current_brightness);
      this.face_lives.add(face_life);
    }
  }

 /**
  * Randomizes the state of the cubes.
  * A value between MIN_ALIVE_PROBABILITY and MAX_ALIVE_PROBABILITY is chosen.
  * Each cube then has that probability of living.
  */
  private void randomizeFaceStates() {
    println("Randomizing start face and neighbors");  
    // First turn off all faces.
    for (L8onFaceLife face_life : this.face_lives) {
      LEDomeFace face = this.faces.get(face_life.index);
      if (!face.hasLights()) {
        continue;
      }

      face_life.alive = false;
    }
    
    // Pick a random face to start and 3 random neighbors to live with.
    LEDomeFace startFace = model.randomLitFace();
    L8onFaceLife startFaceLife = this.face_lives.get(startFace.index);
    startFaceLife.alive = true;
    
    List<Integer> neighbors = startFace.getNeighbors();
    Collections.shuffle(neighbors);
    int neighborCountDelta = (int) neighborCountParameter.getValue();
    int aliveMaxNeighbors = 3 + neighborCountDelta;
    
    for(int i = 0; i < min(aliveMaxNeighbors, neighbors.size()); i++) {
      LEDomeFace face = this.faces.get(neighbors.get(i));
      if (!face.hasLights()) {
        continue;
      }
      
      println("random alive face: " + face.index);
      this.face_lives.get(face.index).alive = true;
    }
  }

  /**
   * Will initiate a cycleOfLife if it is time.
   * Otherwise responds based on the current state of the face.
   */
  private boolean shouldLightFace(L8onFaceLife face_life) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      face_life.just_changed = false;
      return face_life.alive;
    } else {
      return cycleOfLife(face_life);
    }
  }

  /**
   * The meat of the life algorithm.
   * Uses the count of live neighbors and the face's current state
   * to decide the face's fate as such:
   * - If alive, needs 2 or 3 living neighbors to stay alive.
   * - If dead, needs 2 living neighbors to be born again.
   *
   * Populates the new_lives array and returns the new state of the cube.
   */
  private boolean cycleOfLife(L8onFaceLife face_life) {
    Integer index = face_life.index;
    LEDomeFace face = this.faces.get(index);

    // If the face has no lights, it is always dead.
    // Add to new_lives array to ensure cardinality of lists align.
    if (!face.hasLights()) {
      new_lives.add(false);  
      return false;
    }

    Integer alive_neighbor_count = countLiveNeighbors(face_life);
    boolean before_alive = face_life.alive;
    boolean after_alive = before_alive;
    double mutation = Math.random();
    int neighbor_count_delta = (int) neighborCountParameter.getValue();
    int alive_min_neighbors = (2 + neighbor_count_delta);
    int alive_max_neighbors = (3 + neighbor_count_delta);
    int dead_to_alive_neighbors = (3 + neighbor_count_delta);

    if (face.getNeighbors().size() > 9) {
      neighbor_count_delta++;
    }

    if(face_life.alive) {
      if(alive_neighbor_count < alive_min_neighbors || alive_neighbor_count > alive_max_neighbors) {
        after_alive = false;
      } else {
        after_alive = true;
      }
    } else {
      if(alive_neighbor_count == dead_to_alive_neighbors) {
        after_alive = true;
      } else {
        after_alive = false;
      }
    }

    if(mutation <= mutationParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      face_life.just_changed = true;
      any_changes_this_run = true;
    }

    new_lives.add(after_alive);

    return before_alive;
  }
   
  /**
   * Counts the number of living neighbors of a cube.
   */
  private Integer countLiveNeighbors(L8onFaceLife face_life) {
    Integer count = 0;
    L8onFaceLife neighbor_life;

    for(Integer neighbor_index : this.faces.get(face_life.index).getNeighbors()) {
       neighbor_life = this.face_lives.get(neighbor_index);
       if(neighbor_life.alive) {
         count++;
       }
    }

    return count;
  }

  /**
   * Apply the new states from the new_lives array.
   */
  private void applyNewLives() {
    if (this.new_lives.size() == 0) {
      return;
    }

    for(int index = 0; index < this.face_lives.size(); index++) {
      L8onFaceLife face_life = this.face_lives.get(index);
      face_life.alive = new_lives.get(index);
      index++;
    }
  }
}

class ExplosionEffect extends LEDomeEffect {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<ExplosionLayer> explosion_layers = new ArrayList<ExplosionLayer>();

  private BasicParameter brightnessParameter = new BasicParameter("BRGT", 90, 10, 80);
  private BasicParameter saturationParameter = new BasicParameter("SAT", 60, 0, 100);
  private BasicParameter rateParameter = new BasicParameter("RATE", 400.0, 100.0, 20000.0);
  private BasicParameter delayParameter = new BasicParameter("DELAY", 1000.0, 10.0, 3000.0);
  final float maxr = sqrt(model.xMax*model.xMax + model.yMax*model.yMax + model.zMax*model.zMax) + 10;
  private BasicParameter strokeParameter = new BasicParameter("STRK", 15.0, 3.0, maxr / 2.0);
  
  class ExplosionLayer {
    QuadraticEnvelope boom = new QuadraticEnvelope(0, maxr, rateParameter);
    L8onExplosion explosion;

    ExplosionLayer() {
      boom = new QuadraticEnvelope(0, maxr, rateParameter);
      boom.setEase(QuadraticEnvelope.Ease.OUT);
      WB_Point new_center = model.randomFaceCenter();
      addModulator(boom);
      explosion = new L8onExplosion(boom, strokeParameter.getValuef(), new_center.xf(), new_center.yf(), new_center.zf());
      trigger();
    }

    void trigger() {
      WB_Point new_center = model.randomFaceCenter();
      explosion.setCenter(new_center.xf(), new_center.yf(), new_center.zf());
      explosion.explode();
    }

    public void run(double deltaMs) {      
      float brightv = brightnessParameter.getValuef();
      float satv = saturationParameter.getValuef();
      float huev = lx.getBaseHuef();
      for (LXPoint p : model.points) {
        if (explosion.onExplosion(p.x, p.y, p.z)) {
          addColor(p.index, LX.hsb(huev, satv, brightv));
        } else {
          color c = colors[p.index];
          addColor(p.index, LX.hsb(LXColor.h(c), LXColor.s(c), L8onUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs)));
        }
      }
    }
  }

  public ExplosionEffect(LX lx) {
    super(lx, true);

    addParameter(brightnessParameter);
    addParameter(saturationParameter);
    addParameter(rateParameter);
    addParameter(delayParameter);
    addParameter(strokeParameter);; }

 public void onEnable() {
    for (ExplosionLayer l : explosion_layers) {
      if (!l.explosion.isExploding()) {
        l.trigger();
        return;
      }
    }

    explosion_layers.add(new ExplosionLayer());
  }

  public void run(double deltaMs) {
    for (ExplosionLayer l : explosion_layers) {
      if (l.explosion != null && l.explosion.isExploding()) {
        l.run(deltaMs);
      }
    }
  }
}
