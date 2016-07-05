class Dancers extends LEDomePattern {
 
  private Dancer[] dancers = {
    new Dancer(0, 72, 266, 265, 264, 234, 285, 232, 281, 263, 257, new int[] {252, 278, 250, 253}, new int[] {242, 243}, new int[] {269, 270}, new int[] {244, 247}, new int[] {239, 267}, new int[] {241, 238}, new int[] {272, 273}),
    new Dancer(90, 64, 171, 173, 172, 143, 176, 138, 196, 135, 165, new int[] {159, 158, 157, 163}, new int[] {119, 147}, new int[] {153, 185}, new int[] {134, 117}, new int[] {151, 154}, new int[] {149, 150}, new int[] {184, 187}),
    new Dancer(180, 84, 114, 116, 115, 83, 113, 72, 109, 75, 105, new int[] {98, 99, 97, 103}, new int[] {87, 59}, new int[] {125, 93}, new int[] {57, 65}, new int[] {91, 94}, new int[] {89, 90}, new int[] {124, 127}),
    new Dancer(270, 79, 51, 53, 52, 23, 56, 15, 70, 12, 45, new int[] {9, 44, 40, 43}, new int [] {0, 5}, new int[] {30, 35}, new int[] {3, 8}, new int[] {28, 31}, new int[] {2, 27}, new int[] {34, 37}) 
  };

  public Dancers(LX lx) {
    super(lx);
  }

  public void run(double deltaMs) {
    setColors(0);
    
    for(Dancer curDancer : dancers) {
      for(LXPoint p : model.faces.get(curDancer.torsoFace).points) {
        colors[p.index] = LX.hsb(
          curDancer.hue, 
          100, 
          100
        );
      } 
    
      for(int edge : curDancer.edgesForPosition(3)) {
        for(LXPoint p : model.edges.get(edge).points) {
          colors[p.index] = LX.hsb(
            curDancer.hue,
            100, 
            100
          );
        }
      }  
    }
  }
}

 public class Dancer {
  public float hue;
  
  public int torsoFace;
  public int bottomHead;
  public int leftHead;
  public int rightHead;
  
  public int leftArmUp;
  public int rightArmUp;
  public int leftArmOut;
  public int rightArmOut;
  public int leftArmDown;
  public int rightArmDown;
  
  public int[] femur;
  public int[] leftLegStraight;
  public int[] rightLegStraight;
  public int[] leftLegRightRun;
  public int[] rightLegRightRun;
  public int[] leftLegLeftRun;
  public int[] rightLegLeftRun;
  
  public static final int ARMS_DOWN = 0;
  public static final int ARMS_UP = 1;
  public static final int RIGHT_RUN = 2;
  public static final int LEFT_RUN = 3;
  
  public Dancer(
    float hue,
    int torsoFace,
    int bottomHead,
    int leftHead,
    int rightHead,
    
    int leftArmUp,
    int rightArmUp,
    int leftArmOut,
    int rightArmOut,
    int leftArmDown,
    int rightArmDown,
    
    int[] femur,
    int[] leftLegStraight,
    int[] rightLegStraight,
    int[] leftLegRightRun,
    int[] rightLegRightRun,
    int[] leftLegLeftRun,
    int[] rightLegLeftRun 
  ) {
    this.hue = hue;
    this.torsoFace = torsoFace;
    this.bottomHead = bottomHead;
    this.leftHead = leftHead;
    this.rightHead = rightHead;
    this.leftArmUp = leftArmUp;
    this.rightArmUp = rightArmUp;
    this.leftArmOut = leftArmOut;
    this.rightArmOut = rightArmOut;
    this.leftArmDown = leftArmDown;
    this.rightArmDown = rightArmDown;
    this.femur = femur;
    this.leftLegStraight = leftLegStraight;
    this.rightLegStraight = rightLegStraight;
    this.leftLegRightRun = leftLegRightRun;
    this.rightLegRightRun = rightLegRightRun;
    this.leftLegLeftRun = leftLegLeftRun;
    this.rightLegLeftRun = rightLegLeftRun;
   }
   
  public int[] edgesForPosition(int position) {
    int[] returnEdges = new int[10];
    
    returnEdges[0] = this.femur[0];
    returnEdges[1] = this.femur[1];
    returnEdges[2] = this.femur[2];
    returnEdges[3] = this.femur[3];
    
    switch(position) {          
      case ARMS_DOWN:
        returnEdges[4] = this.leftArmDown; 
        returnEdges[5] = this.rightArmDown;
        returnEdges[6] = this.leftLegStraight[0];
        returnEdges[7] = this.leftLegStraight[1];
        returnEdges[8] = this.rightLegStraight[0];
        returnEdges[9] = this.rightLegStraight[1];
        break;
      case ARMS_UP:
        returnEdges[4] = this.leftArmUp; 
        returnEdges[5] = this.rightArmUp;
        returnEdges[6] = this.leftLegStraight[0];
        returnEdges[7] = this.leftLegStraight[1];
        returnEdges[8] = this.rightLegStraight[0];
        returnEdges[9] = this.rightLegStraight[1];
        break;
      case RIGHT_RUN:
        returnEdges[4] = this.leftArmOut; 
        returnEdges[5] = this.rightArmDown;
        returnEdges[6] = this.leftLegRightRun[0];
        returnEdges[7] = this.leftLegRightRun[1];
        returnEdges[8] = this.rightLegRightRun[0];
        returnEdges[9] = this.rightLegRightRun[1];
        break;
      case LEFT_RUN:
        returnEdges[4] = this.leftArmDown; 
        returnEdges[5] = this.rightArmOut;
        returnEdges[6] = this.leftLegLeftRun[0];
        returnEdges[7] = this.leftLegLeftRun[1];
        returnEdges[8] = this.rightLegLeftRun[0];
        returnEdges[9] = this.rightLegLeftRun[1];
        break;  
    }       
    
    return returnEdges; 
  }
  
 }
