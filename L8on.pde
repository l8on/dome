public class ShadyWaffle extends LEDomePattern { 
  private int PINK = LX.hsb(330, 59, 50);
  
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
    
  private int YELLOW = LX.hsb(61, 90, 50);
  
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
  
  private int BLUE = LX.hsb(239, 61, 50);
  private int[] BLUE_FACES = {
    33, 39, 45, 51, 57,
    63, 68, 73, 78, 83,
    85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99  
  };
   
  private int PURPLE = LX.hsb(293, 72, 50);
  
  private int[] PURPLE_FACES = {
    2, 5, 8, 11, 14, 20, 23, 26, 29,
    62, 64, 67, 69, 72, 74, 77, 79, 82, 84
  };
   
  private int TEAL = LX.hsb(177, 97, 50);

  private int[] TEAL_FACES = {
    0, 1, 32, 3, 4, 34,
    6, 7, 38, 9, 10, 40,
    12, 13, 44, 15, 46, 
    19, 50, 21, 22, 52,
    24, 25, 56, 27, 28, 58
  };
 
  private LEDomeAudioParameterFull rateParam = new LEDomeAudioParameterFull("TWNK", 6, 6, 0.75);
  private TwinkleLayer twinkleLayer = new TwinkleLayer(lx, this, rateParam);
  
  public ShadyWaffle(LX lx) {
    super(lx);

    rateParam.setModulationRange(1);
    addParameter(rateParam);
    addLayer(twinkleLayer);    
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
  }
}

public class HeartsBeat extends LEDomePattern {
  private final int NUM_HEARTS = 3;
  
  private int[] HEART_1_FACES = {
    27, 57, 58, 59, 83, 60
  };  
 
  private int[] HEART_1_EDGES = {
    126, 110, 74, 63, 78, 79, 89, 94
  };
  
  private int[] HEART_2_FACES = {
    64, 87, 88, 89, 101, 90
  };  
 
  private int[] HEART_2_EDGES = {
    111, 86, 236, 198, 204, 205, 137, 166
  };
  
  private int[] HEART_3_FACES = {
    13, 43, 44, 45, 71, 73
  };  
 
  private int[] HEART_3_EDGES = {
    248, 275, 279, 231, 259, 260, 241, 267
  };
  
  private SinLFO[] heartColors = new SinLFO[NUM_HEARTS];
  private SinLFO[] heartBeats = new SinLFO[NUM_HEARTS];
  private SinLFO[] heartSaturations = new SinLFO[NUM_HEARTS];
  private BoundedParameter rateParam = new BoundedParameter("RATE", 2.5, 0.5, 12);  
  private LEDomeAudioParameter[] brightnessParams = new LEDomeAudioParameter[] {
    new LEDomeAudioParameterLow("BRLW", 50, 50, 100),
    new LEDomeAudioParameterMid("BRMD", 50, 50, 100),
    new LEDomeAudioParameterHigh("BRHG", 50, 50, 100)
  };
  
  public HeartsBeat(LX lx) {
    super(lx);    

    addParameter(rateParam);    
    
    for (LEDomeAudioParameter brightnessParameter : brightnessParams) {
      brightnessParameter.setModulationRange(.8);
      addParameter(brightnessParameter);
    }
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
      this.heartColors[i] = new SinLFO(320, 380, 2 * getRate());
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
          this.heartColors[0].getValuef() % 360.0,
          this.heartSaturations[0].getValuef(), 
          this.brightnessParams[0].getValuef()
        );
      }
    }
    
    for(int i : HEART_1_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[0].getValuef(), 
          this.heartSaturations[0].getValuef(),
          this.heartBeats[0].getValuef() * this.brightnessParams[0].getValuef()
        );
      }
    }
    
    for(int i : HEART_2_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[1].getValuef(), 
          this.heartSaturations[1].getValuef(),
          this.brightnessParams[1].getValuef()
        ); 
      }
    }
    
    for(int i : HEART_2_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[1].getValuef(), 
          this.heartSaturations[1].getValuef(), 
          this.heartBeats[1].getValuef() * this.brightnessParams[1].getValuef()
        );
      }
    }
    
    for(int i : HEART_3_FACES) {
      for(LXPoint p : model.faces.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[2].getValuef(), 
          this.heartSaturations[2].getValuef(),
          this.brightnessParams[2].getValuef()
        ); 
      }
    }
    
    for(int i : HEART_3_EDGES) {
      for(LXPoint p : model.edges.get(i).points) {
        colors[p.index] = LX.hsb(
          this.heartColors[2].getValuef(), 
          this.heartSaturations[2].getValuef(),
          this.heartBeats[1].getValuef() * this.brightnessParams[2].getValuef()
        );
      }
    }
  }
}

public class SnakeApple extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.  
  private List<Apple> apples = new ArrayList<Apple>();
  private List<Integer> appleIndices = new ArrayList<Integer>();
  private Random appleRandom = new Random();
  
  private LEDomeAudioParameterLow snakeSpeedBass = new LEDomeAudioParameterLow("SPDB", 42.0, 6.0, 220.0);
  private LEDomeAudioParameterMid snakeSpeedMid = new LEDomeAudioParameterMid("SPDM", 42.0, 6.0, 220.0);
  private LEDomeAudioParameterHigh snakeSpeedTreble = new LEDomeAudioParameterHigh("SPDT", 42.0, 6.0, 220.0);  
  
  private LEDomeAudioParameter[] snakeSpeeds = new LEDomeAudioParameter[] {snakeSpeedBass, snakeSpeedMid, snakeSpeedTreble};
     
  private BoundedParameter numApples = new BoundedParameter("APL", 50.0, 10.0, 100.0);
    
  private final int SNAKES = 3;
  private final int HUES = 6;
  private final int BRIGHTS = 5;
  
  private SnakeLayer[] snakes = new SnakeLayer[SNAKES];
  private BoundedParameter[] lengthParameters = new BoundedParameter[SNAKES];
  private LXModulator[] hueMods = new SinLFO[HUES];
  private LXModulator[] brightnessMods = new SinLFO[BRIGHTS];
  
  public SnakeApple(LX lx) {
    super(lx);
    
    snakeSpeedBass.setModulationRange(.7);
    snakeSpeedMid.setModulationRange(.7);
    snakeSpeedTreble.setModulationRange(.7);    
    
    addParameter(snakeSpeedBass);
    addParameter(snakeSpeedMid);
    addParameter(snakeSpeedTreble);    

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
      this.lengthParameters[i] = new BoundedParameter("LNG" + i, 4.0, 4.0, 582.0);
      this.snakes[i] = new SnakeLayer(lx, this.lengthParameters[i], this.snakeSpeeds[i % 3]);
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
      LXPoint point = model.getPoints().get(this.appleRandom.nextInt(model.size));
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

public class Snakes extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<SnakeLayer> snakes = new ArrayList<SnakeLayer>();
  private BoundedParameter numSnakes = new BoundedParameter("NUM", 4.0, 1.0, 30.0);
  private BoundedParameter snakeSpeed = new BoundedParameter("SPD", 86.0, 6.0, 640.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 95.0, 10.0, 100.0);
  private BoundedParameter lengthParameter = new BoundedParameter("LNGT", 11.0, 3.0, 48.0);  
  
  private LEDomeAudioParameterLow snakeSpeedBass = new LEDomeAudioParameterLow("SPDB", 42.0, 6.0, 420.0);
  private LEDomeAudioParameterMid snakeSpeedMid = new LEDomeAudioParameterMid("SPDM", 42.0, 6.0, 420.0);
  private LEDomeAudioParameterHigh snakeSpeedTreble = new LEDomeAudioParameterHigh("SPDT", 42.0, 6.0, 420.0);
  private LEDomeAudioParameterFull snakeSpeedFull = new LEDomeAudioParameterFull("SPDF", 42.0, 6.0, 420.0);
  
  private LEDomeAudioParameter[] snakeSpeeds = new LEDomeAudioParameter[] {snakeSpeedBass, snakeSpeedMid, snakeSpeedTreble, snakeSpeedFull};
  
  public String getName() { return "Snakes"; }

  public Snakes(LX lx) {
    super(lx);
    
    snakeSpeedBass.setModulationRange(.7);
    snakeSpeedMid.setModulationRange(.7);
    snakeSpeedTreble.setModulationRange(.7);
    snakeSpeedFull.setModulationRange(.7);
    
    addParameter(snakeSpeedBass);
    addParameter(snakeSpeedMid);
    addParameter(snakeSpeedTreble);
    addParameter(snakeSpeedFull);

    addParameter(numSnakes);
    addParameter(lengthParameter);

    initSnakes();
  }

  public void run(double deltaMs) {
    calibrateSnakes();    
    
    float hueStep = 0;
    for(SnakeLayer snake: this.snakes) {      
      snake.hue = (lx.palette.getHuef() + hueStep) % 360;      
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
      int snakeSpeedIndex = i % 4;
      SnakeLayer snake = new SnakeLayer(lx, lengthParameter, snakeSpeeds[snakeSpeedIndex], brightnessParameter);
      snakes.add(snake);
      addLayer(snake);
    }
  }
  
  public void calibrateSnakes() {
    if ((int)this.numSnakes.getValue() == this.snakes.size()) { return; }
  
    if ((int)this.numSnakes.getValue() < this.snakes.size()) {
      for(int i = (this.snakes.size() - 1); i >= (int)this.numSnakes.getValue(); i--) {
        removeLayer(this.snakes.get(i));
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

public class Explosions extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onExplosion> explosions = new ArrayList<L8onExplosion>();
  private final SinLFO saturationModulator = new SinLFO(80.0, 100.0, 20 * SECONDS);
  private BoundedParameter numExplosionsParameter = new BoundedParameter("NUM", 4.0, 1.0, 30.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);
  
  private LEDomeAudioParameterFull rateParameter = new LEDomeAudioParameterFull("RATE", 8000.0, 8000.0, 750.0);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);
  
  private LEDomeAudioBeatGate beatGate = new LEDomeAudioBeatGate("XBEAT", lx);
  private LEDomeAudioClapGate clapGate = new LEDomeAudioClapGate("XCLAP", lx);

  public Explosions(LX lx) {
    super(lx);

    addParameter(numExplosionsParameter);
    addParameter(brightnessParameter);

    rateParameter.setModulationRange(1);
    addParameter(rateParameter);
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();
    addModulator(beatGate).start();
    addModulator(clapGate).start();

    initExplosions();
  }

  public void run(double deltaMs) {
    initExplosions();

    float base_hue = lx.palette.getHuef();
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

    for (LXPoint p : model.points) {
      int num_explosions_in = 0;

      for(L8onExplosion explosion : this.explosions) {
        if(explosion.isChillin(0)) {
          continue;
        }

        if(explosion.onExplosion(p.x, p.y, p.z)) {
          num_explosions_in++;
          hue_value = LEDomeUtil.natural_hue_blend(explosion.hue_value, hue_value, num_explosions_in);
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
        BandGate explosionGate = (this.explosions.size() % 2 == 1) ? this.beatGate : this.clapGate;        
        this.explosions.add(
          new L8onExplosion(new_radius_env, explosionGate.gate, stroke_width, new_center.xf(), new_center.yf(), new_center.zf())
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
    float chill_time = (15.0 + random(15)) * SECONDS;
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

public class SpotLights extends LEDomePattern {
  // Used to store info about each spotlight.
  // See L8onUtil.pde for the definition.
  private List<L8onSpotLight> spotlights = new ArrayList<L8onSpotLight>();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);

  // Controls the radius of the spotlights.
  private BoundedParameter radiusParameter = new LEDomeAudioParameterLow("RAD", 2.0 * FEET, 1.0, model.xRange / 2.0);
  private BoundedParameter numLightsParameter = new BoundedParameter("NUM", 3.0, 1.0, 30.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);

  private BoundedParameter rateParameter = new BoundedParameter("RATE", 4000.0, 1.0, 10000.0);
  private BoundedParameter restParameter = new BoundedParameter("REST", 2000.0, 1.0, 10000.0);
  private BoundedParameter delayParameter = new BoundedParameter("DELAY", 0, 0.0, 2000.0);
  private BoundedParameter minDistParameter = new BoundedParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public SpotLights(LX lx) {
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
    float base_hue = lx.palette.getHuef();
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
        c = LX.hsb(LXColor.h(c), LXColor.s(c), LEDomeUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs));
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

public class DarkLights extends LEDomePattern {
  // Used to store info about each spotlight.
  // See L8onUtil.pde for the definition.
  private List<L8onSpotLight> spotlights = new ArrayList<L8onSpotLight>();
  private final int faceCount = model.faces.size();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);
  private final SawLFO currIndex = new SawLFO(0, faceCount, 5000);

  // Controls the radius of the spotlights.
  private CompoundParameter radiusParameter = new LEDomeAudioParameterLow("RAD", 2.2 * FEET, 1.0, model.xRange / 2.0);
  private BoundedParameter numLightsParameter = new BoundedParameter("NUM", 12.0, 1.0, 50.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);

  private BoundedParameter rateParameter = new BoundedParameter("RATE", 4000.0, 1.0, 10000.0);
  private BoundedParameter restParameter = new BoundedParameter("REST", 2000.0, 1.0, 10000.0);
  private BoundedParameter delayParameter = new BoundedParameter("DELAY", 0, 0.0, 2000.0);
  private BoundedParameter minDistParameter = new BoundedParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.55);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public DarkLights(LX lx) {
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

public class HeartExplosions extends LEDomePattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onHeartExplosion> hearts = new ArrayList<L8onHeartExplosion>();
  private final SinLFO saturationModulator = new SinLFO(70.0, 90.0, 20 * SECONDS);
  private BoundedParameter numHeartsParameter = new BoundedParameter("NUM", 2.0, 1.0, 30.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);

  private BoundedParameter rateParameter = new BoundedParameter("RATE", 4000.0, 500.0, 20000.0);
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);

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

    float base_hue = lx.palette.getHuef();
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

public class HeartLights extends LEDomePattern {
  // Used to store info about each heartlight.
  // See L8onUtil.pde for the definition.
  private List<L8onHeartLight> heartlights = new ArrayList<L8onHeartLight>();

  private final SinLFO saturationModulator = new SinLFO(75.0, 95.0, 20 * SECONDS);

  // Controls the radius of the spotlights.
  private BoundedParameter radiusParameter = new BoundedParameter("RAD", 4.0 * FEET, 2.0, model.xRange);
  private BoundedParameter numLightsParameter = new BoundedParameter("NUM", 3.0, 1.0, 30.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);

  private BoundedParameter rateParameter = new BoundedParameter("RrATE", 4000.0, 1.0, 10000.0);
  private BoundedParameter restParameter = new BoundedParameter("REST", 900.0, 1.0, 10000.0);
  private BoundedParameter delayParameter = new BoundedParameter("DELAY", 0, 0.0, 2000.0);
  private BoundedParameter minDistParameter = new BoundedParameter("DIST", 100.0, 10.0, model.xRange);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);

  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public HeartLights(LX  lx) {
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
    float base_hue = lx.palette.getHuef();
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
        c = LX.hsb(LXColor.h(c), LXColor.s(c), LEDomeUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs));
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
public class L8onMixColor extends LEDomePattern {
  // Oscillators for the wave breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 20000);
  private final SinLFO yOffsetMax = new SinLFO( -1 * (model.yRange / 2.0) , model.yRange / 2.0, 20000);
  private final SinLFO zOffsetMax = new SinLFO( -1 * (model.zRange / 2.0) , model.zRange / 2.0, 20000);

  // Used to store info about each wave.
  // See L8onUtil.pde for the definition.
  private List<L8onWave> l8on_waves;

  // Controls the radius of the string.
  private LEDomeAudioParameterLow radiusParameterX = new LEDomeAudioParameterLow("RADX", 2.0, 2.0, 2 * FEET);
  private LEDomeAudioParameterMid radiusParameterY = new LEDomeAudioParameterMid("RADY", 2.0, 2.0, 2 * FEET);
  private LEDomeAudioParameterHigh radiusParameterZ = new LEDomeAudioParameterHigh("RADZ", 2.0, 2.0, 2 * FEET);  
 
  // The center of the waves by axis
  final float CENTERX = (model.xMin + model.xMax) / 2.0;
  final float CENTERY = (model.yMin + model.yMax) / 2.0;
  final float CENTERZ = (model.zMin + model.zMax) / 2.0;
  
  // Number of Waves by axis
  final float WAVX = 2.0;
  final float WAVY = 3.0;
  final float WAVZ = 3.0;
  
  // Controls brightness of on lights
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);
  private BoundedParameter saturationParameter = new BoundedParameter("SAT", 100, 0, 100);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", .6);
  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);

  public L8onMixColor(LX  lx) {
    super(lx);

    initL8onWaves();

    radiusParameterX.setModulationRange(1);
    radiusParameterY.setModulationRange(1);
    radiusParameterZ.setModulationRange(1);
    
    addParameter(radiusParameterX);
    addParameter(radiusParameterY);
    addParameter(radiusParameterZ);    
    addParameter(brightnessParameter);
    addParameter(saturationParameter);    
    addParameter(blurParameter);

    addModulator(xOffsetMax).trigger();
    addModulator(yOffsetMax).trigger();
    addModulator(zOffsetMax).trigger();
    
    addLayer(blurLayer);
  }

  public void run(double deltaMs) {
    float offset_value_x = xOffsetMax.getValuef();
    float offset_value_z = zOffsetMax.getValuef();
    float base_hue = lx.palette.getHuef();
    float wave_hue_diff = (float) (360.0 / this.l8on_waves.size());

    for(L8onWave l8on_wave : this.l8on_waves) {
      l8on_wave.hue_value = base_hue;
      base_hue += wave_hue_diff;
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationParameter.getValuef();
    float brightness_value = brightnessParameter.getValuef();
    float wave_center_x;
    float wave_center_y;
    float wave_center_z;
    float wave_radius;    

    for (LXPoint p : model.points) {
      float x_percentage = (p.x - model.xMin) / model.xRange;
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float z_percentage = (p.z - model.zMin) / model.zRange;
      float cos_x = cos(PI / 2 + WAVX * PI * x_percentage);
      float sin_y = sin(PI / 2 + WAVY * PI * y_percentage);
      float sin_z = sin(PI / 2 + WAVZ * PI * z_percentage);

      int num_waves_in = 0;

      for(L8onWave l8on_wave : this.l8on_waves) {
        wave_center_x = p.x;
        wave_center_y = p.y;
        wave_center_z = p.z;

        if(l8on_wave.direction == L8onWave.DIRECTION_X) {
          wave_center_z = CENTERZ + (l8on_wave.offset_multiplier * offset_value_z * cos_x);
          wave_radius = radiusParameterX.getValuef();
        } else if(l8on_wave.direction == L8onWave.DIRECTION_Y) {
          wave_center_x = CENTERX + (l8on_wave.offset_multiplier * offset_value_x * sin_y);
          wave_radius = radiusParameterY.getValuef();
        } else {
          wave_center_x = CENTERX + (l8on_wave.offset_multiplier * offset_value_x * sin_z);
          wave_radius = radiusParameterZ.getValuef();
        }

        float dist_from_wave = distance_from_wave(p, wave_center_x, wave_center_y, wave_center_z);

        if(dist_from_wave <= wave_radius) {
          num_waves_in++;
          hue_value = LEDomeUtil.natural_hue_blend(l8on_wave.hue_value, hue_value, num_waves_in);
        }
      }

      if(num_waves_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), 0);
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
public class Life extends LEDomePattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BoundedParameter rateParameter = new BoundedParameter("DELAY", 700, 0.0, 10 * SECONDS);
  // Controls the probability of a mutation in the cycleOfLife
  private BoundedParameter mutationParameter = new LEDomeAudioParameterLow("MUT", 0.03, 0.0, 0.2);
  // Controls the saturation.
  private LEDomeAudioParameterFull saturationParameter = new LEDomeAudioParameterFull("SAT", 50.0, 0.0, 100.0);
  
  private BoundedParameter neighborCountParameter = new BoundedParameter("NEIG", 0.0, -2.0, 2.0);

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

  public Life(LX  lx) {
     super(lx);
     this.faces = model.faces;

     //Print debug info about the faces/edges.
     // outputFaceInfo();

     initFaceStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_lives = new ArrayList<Boolean>(this.faces.size());
     
     saturationParameter.setModulationPolarity(LXParameter.Polarity.BIPOLAR);

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

public class ExplosionEffect extends LEDomeEffect {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<ExplosionLayer> explosion_layers = new ArrayList<ExplosionLayer>();

  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 90, 10, 80);
  private BoundedParameter saturationParameter = new BoundedParameter("SAT", 60, 0, 100);
  private BoundedParameter rateParameter = new BoundedParameter("RATE", 400.0, 100.0, 20000.0);
  private BoundedParameter delayParameter = new BoundedParameter("DELAY", 1000.0, 10.0, 3000.0);    
  private BoundedParameter strokeParameter;
  
  private LEDomeAudioClapGate clapGate = new LEDomeAudioClapGate(lx);
  
  public class ExplosionLayer {    
    QuadraticEnvelope boom;
    L8onExplosion explosion;
    LEDome model;    

    public ExplosionLayer(LX lx) {      
      this.model = (LEDome)lx.model;            
      float maxr = sqrt(model.xMax*model.xMax + model.yMax*model.yMax + model.zMax*model.zMax) + 10;      
          
      boom = new QuadraticEnvelope(0, maxr, rateParameter);
      boom.setEase(QuadraticEnvelope.Ease.OUT);      
      addModulator(boom);
      
      WB_Point new_center = model.randomFaceCenter();
      explosion = new L8onExplosion(boom, clapGate.gate, strokeParameter.getValuef(), new_center.xf(), new_center.yf(), new_center.zf());
      trigger();
    }

    void trigger() {
      WB_Point new_center = model.randomFaceCenter();
      explosion.setCenter(new_center.xf(), new_center.yf(), new_center.zf());
      explosion.explode();
    }

    public void run(double deltaMs, int[] colors) { 
      float brightv = brightnessParameter.getValuef();
      float satv = saturationParameter.getValuef();
      float huev = lx.palette.getHuef();
      for (LXPoint p : this.model.points) {
        if (explosion.onExplosion(p.x, p.y, p.z)) {
          addColor(p.index, LX.hsb(huev, satv, brightv));
        } else {          
          color c = colors[p.index];
          addColor(p.index, LX.hsb(LXColor.h(c), LXColor.s(c), LEDomeUtil.decayed_brightness(c, delayParameter.getValuef(), deltaMs)));
        }
      }
    }
  }

  public ExplosionEffect(LX lx) {
    super(lx);
    
    float maxr = sqrt(lx.model.xMax*lx.model.xMax + lx.model.yMax*lx.model.yMax + lx.model.zMax*lx.model.zMax) + 10;
    strokeParameter = new BoundedParameter("STRK", 15.0, 3.0, maxr / 2.0);

    addParameter(brightnessParameter);
    addParameter(saturationParameter);
    addParameter(rateParameter);
    addParameter(delayParameter);
    addParameter(strokeParameter);; 
  }

  public void onEnable() {    
    println("On enable called");
    for (ExplosionLayer l : explosion_layers) {
      if (!l.explosion.isExploding()) {
        l.trigger();
        return;
      }
    }
    explosion_layers.add(new ExplosionLayer(this.lx));
  }

  public void run(double deltaMs, double enabledAmount) {    
    for (ExplosionLayer l : explosion_layers) {
      if (l.explosion != null && l.explosion.isExploding()) {
        l.run(deltaMs, colors);
      }
    }
  }
}

// Adapted from Slee's wonderful Clock animation
public class JumpRopes extends LEDomePattern {
  
  final SinLFO thAmt = new SinLFO(0, 50, startModulator(new SinLFO(5000, 19000, 27000)));
  
  private LEDomeAudioParameterLow falloffLow = new LEDomeAudioParameterLow("LOW", 600, 600, 100);
  private LEDomeAudioParameterMid falloffMid = new LEDomeAudioParameterMid("MID", 600, 600, 100);
  private LEDomeAudioParameterHigh falloffHigh = new LEDomeAudioParameterHigh("HIGH", 600, 600, 100);
  private LEDomeAudioParameterFull falloffFull = new LEDomeAudioParameterFull("FULL", 600, 600, 100);
  private LEDomeAudioParameter[] clockFalloffs = new LEDomeAudioParameter[] {
    falloffLow,
    falloffMid,
    falloffHigh,
    falloffFull
  };
  
  JumpRopes(LX lx) {
    super(lx);
    falloffLow.setModulationRange(1);
    falloffMid.setModulationRange(1);
    falloffHigh.setModulationRange(1);
    falloffFull.setModulationRange(1);
    
    addParameter(falloffLow);
    addParameter(falloffMid);
    addParameter(falloffHigh);
    addParameter(falloffFull);

    
    for (int i = 0; i < 4; ++i) {
      addLayer(new JumpRope(lx, i, clockFalloffs[i]));
    } 
    startModulator(thAmt.randomBasis());
  }
  
  public class JumpRope extends LXLayer {
    
    final SawLFO angle = new SawLFO(
      0, 
      TWO_PI,
      startModulator(new SinLFO(random(4000, 7000), random(19000, 21000), random(17000, 31000)).randomBasis())
    );
    
    final SinLFO falloffLFO = new SinLFO(200, 500, random(17000, 21000));
    LEDomeAudioParameter falloffParam;
    
    final SinLFO xSpr = new SinLFO(0, 2, random(10000, 29000));
    
    final int i;
    
    JumpRope(LX lx, int i, LEDomeAudioParameter falloffParam) {
      super(lx);
      this.i = i;
      this.falloffParam = falloffParam;
      startModulator(angle.randomBasis());
      startModulator(falloffLFO.randomBasis());
      startModulator(xSpr.randomBasis());
    }
    
    public void run(double deltaMs) {
      float av = angle.getValuef();
      if (i % 2 == 1) {
        av = TWO_PI - av;
      }
      
      for (LXPoint p : model.points) {
        float b = 100 - (this.getFalloffValue() - p.x) * LXUtils.wrapdistf(p.theta, av, TWO_PI);
        if (b > 0) {
          addColor(p.index, LX.hsb(
            (abs(p.x-model.cx)*xSpr.getValuef() + thAmt.getValuef() * abs(p.theta - PI)) % 360,
            100,
            b
          ));
        }
      }
    }
    
    public float getFalloffValue() {
      if (this.lx.engine.audio.enabled.getValueb()) {
        return this.falloffParam.getValuef();  
      } else {
        return this.falloffLFO.getValuef();
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(0);
  }
}

public class AudioBelts extends LEDomePattern {
  private LEDomeAudioParameterLow bassHeight = new LEDomeAudioParameterLow("BH", 3 * INCHES, 3 * INCHES, 1.5 * FEET);
  private LEDomeAudioParameterMid midHeight = new LEDomeAudioParameterMid("MH", 3 * INCHES, 3 * INCHES, 1.5 * FEET);
  private LEDomeAudioParameterHigh trebleHeight = new LEDomeAudioParameterHigh("HH", 3 * INCHES, 3 * INCHES, 2 * FEET);
  
  private double BASS_MODULATION_RANGE = 1;
  private double MID_MODULATION_RANGE = 1;
  private double TREBLE_MODULATION_RANGE = 1;
    
  private float bassBeltY = -.9;
  private float midBeltY = 23.26;
  private float trebleBeltY = model.yMax - (1.25 * FEET);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.5);
  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);
  
  private BoundedParameter maxBrightnessParameter = new BoundedParameter("BRIG", 70, 0, 100);
  private boolean[] twinkleBits = new boolean[lx.total];
  private LEDomeAudioParameterFull twinkleRate = new LEDomeAudioParameterFull("TWNK", 1, 0.5, 12);
  private TwinkleLayer twinkleLayer = new TwinkleLayer(lx, this, twinkleRate, twinkleBits, maxBrightnessParameter);
  
  AudioBelts(LX lx) {
    super(lx);
    bassHeight.setModulationRange(BASS_MODULATION_RANGE);
    midHeight.setModulationRange(MID_MODULATION_RANGE);
    trebleHeight.setModulationRange(TREBLE_MODULATION_RANGE);    
    
    addParameter(bassHeight);
    addParameter(midHeight);
    addParameter(trebleHeight);

    twinkleRate.setModulationRange(1);
    addParameter(twinkleRate);
    addParameter(maxBrightnessParameter);
    addLayer(twinkleLayer);
    
    addParameter(blurParameter);
    addLayer(blurLayer);
  }
 
  public void run(double deltaMs) {
    //setColors(0); 
    float bassHue = lx.palette.getHuef();
    float midHue = (bassHue + 120) % 360;
    float trebleHue = (midHue + 120) % 360;
       
    for (LXPoint p : model.points) {
      int numBelts = 0;
      float pointHue = LXColor.h(colors[p.index]);
      
      //if (dist(p.x, p.y, p.z, p.x, bassBeltY, p.z) <= bassHeight.getValuef()) {
      if (dist(p.x, p.y, p.z, p.x, bassBeltY, p.z) <= bassHeight.getValuef()) {
        numBelts++;
        pointHue = LEDomeUtil.natural_hue_blend(bassHue, pointHue, numBelts);
        //setColor(p.index, LX.hsb(bassHue, 100, 30));
      }
      //if (dist(p.x, p.y, p.z, p.x, midBeltY, p.z) <= midHeight.getValuef()) {
      if (dist(p.x, p.y, p.z, p.x, midBeltY, p.z) <= midHeight.getValuef()) {
        numBelts++;
        pointHue = LEDomeUtil.natural_hue_blend(midHue, pointHue, numBelts);
        //setColor(p.index, LX.hsb(midHue, 100, 30));
      }
      //if (dist(p.x, p.y, p.z, p.x, trebleBeltY, p.z) <= trebleHeight.getValuef()) {
      if (dist(p.x, p.y, p.z, p.x, trebleBeltY, p.z) <= trebleHeight.getValuef()) {
        numBelts++;
        pointHue = LEDomeUtil.natural_hue_blend(trebleHue, pointHue, numBelts);
        //setColor(p.index, LX.hsb(trebleHue, 100, 30));
      }
      
      if (numBelts > 0) {
        this.twinkleBits[p.index] = true;
        setColor(p.index, LX.hsb(pointHue, 100, 30));
      } else {
        this.twinkleBits[p.index] = false;
        setColor(p.index, 0);        
      }
    }
  }
}

public class DomeEQ extends LEDomePattern {
  private GraphicMeter meter;
  private BandGate bandGate = new BandGate(lx);
  private final int ORIGIN_POINT_INDEX = 8;
  private final int MAX_POINT_INDEX = 544;
  private double originAzimuth = model.points[ORIGIN_POINT_INDEX].azimuth;
  private double projectedMaxAzimuth;
  
  private BoundedParameter brightnessParam = new BoundedParameter("BRIG", 60, 10, 100);
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private BlurLayer blurLayer = new BlurLayer(lx, this, blurParameter);
  private LXModulator huePeriod = new SinLFO(10000, 20000, 60000);
  private LXModulator hueModulator = new SinLFO(0, 360, huePeriod);
  
  private final double GAIN = 6;
  
  public DomeEQ(LX lx) {
    super(lx);
    this.meter = bandGate.meter;
    this.originAzimuth = model.points[ORIGIN_POINT_INDEX].azimuth;  
    this.projectedMaxAzimuth = this.projectAzimuth(model.points[MAX_POINT_INDEX].azimuth);
    
    addParameter(brightnessParam);
    
    addParameter(blurParameter);
    addLayer(blurLayer);
    
    addModulator(huePeriod).start();
    addModulator(hueModulator).start();
    
    bandGate.gain.setValue(GAIN);
    addModulator(bandGate).start();    
  }
  
  public void run(double deltaMs) {   
    for (LXPoint p : model.points) {
      if (p.yn <= this.bandGate.getBand(this.getBandIndex(p))) {    
        float hue = (hueModulator.getValuef() + (p.yn * 360.0)) % 360.0;
        setColor(p.index, LX.hsb(hue, 100, brightnessParam.getValuef()));
      } else {
        setColor(p.index, 0);
      }
    }
  }
  
  private int getBandIndex(LXPoint p) {
    double projectedAzimuth = this.projectAzimuth(p.azimuth);
    double normalizedPosition = LXUtils.constrain(projectedAzimuth / projectedMaxAzimuth, 0.0, 1);
    double bandIndex = LXUtils.constrain(normalizedPosition * this.meter.numBands, 0.0, this.meter.numBands - 1);
    return (int)bandIndex;
  }
  
  private double projectAzimuth(double azimuth) {
    return (azimuth - originAzimuth + LX.TWO_PI) % LX.TWO_PI;
  }
}

public class ThunderStorm extends LEDomePattern {
 
  List<LightningBolt> lightningBolts = new ArrayList<LightningBolt>();
  
  BoundedParameter numBolts = new BoundedParameter("NUM", 4, 1, 20);
  BoundedParameter branchLength = new BoundedParameter("LNTH", 8, 5, 12);
  BoundedParameter strikeDuration = new BoundedParameter("STRK", 500, 200, 1000);
  BoundedParameter cooldownDuration = new BoundedParameter("COOL", 4500, 1000, 10000);
  BoundedParameter chillDuration = new BoundedParameter("CHILL", 20000, 100, 30000);
  LEDomeAudioClapGate clapGate = new LEDomeAudioClapGate(lx);
  LEDomeAudioBeatGate beatGate = new LEDomeAudioBeatGate(lx);
  
  public ThunderStorm(LX lx) {
    super(lx);
    
    addParameter(numBolts);
    addParameter(branchLength);
    addParameter(strikeDuration);
    addParameter(cooldownDuration);
    addParameter(chillDuration);
    
    addModulator(clapGate).start();
    addModulator(beatGate).start();
    
    this.calibrateBolts();
  }
  
  public void run(double deltaMs) {
    this.calibrateBolts();
    setColors(0);
  }
  
  public void calibrateBolts() {
    if ((int)this.numBolts.getValue() == this.lightningBolts.size()) { return; }
  
    if ((int)this.numBolts.getValue() < this.lightningBolts.size()) {
      for(int i = (this.lightningBolts.size() - 1); i >= (int)this.numBolts.getValue(); i--) {
        removeLayer(this.lightningBolts.get(i));
        this.lightningBolts.remove(i);
      }
    } else {
      for(int i = 0; i < ((int)this.numBolts.getValuef() - this.lightningBolts.size()); i++) {
        BandGate triggerGate = (lightningBolts.size() % 2 == 1) ? clapGate : beatGate;
        LightningBolt lightning = new LightningBolt(lx, branchLength, strikeDuration, cooldownDuration, chillDuration, triggerGate.gate);
        this.lightningBolts.add(lightning);
        addLayer(lightning);
      }
    }
  }
}