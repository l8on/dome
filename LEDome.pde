/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This file implements the mapping needed to generate, identify and order 
 * each face dome and plots the lights on the faces. It should only be modified
 * when physical changes or tuning is being done to the structure.
 */

// Let's work in inches
final static int INCHES = 1;
final static int FEET = 12*INCHES;

// Let's work with human level times.
final static int SECONDS = 1000;
final static int MINUTES = 60 * SECONDS;

// Configure the NDB and the number of connected lights.
final static int NUM_CONNECTED_LIGHTS = 48;
final static String NDB_IP_ADDRESS = "10.0.0.116";

/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class LEDome extends LXModel {
  public List<LEDomeFace> faces;
  public WB_Sphere sphere;  
  
  private LEDomeLights domelights;
  
  public static final float DOME_RADIUS = 5.5 * FEET;  
  
  public static final int DIRECTION_RIGHT = 0;
  public static final int DIRECTION_FORWARD = 1;
  public static final int DIRECTION_LEFT = 2;
  public static final int DIRECTION_BACK = 3;
    
  public static final ArrayList<Integer> NO_LIGHT_FACES = new ArrayList<Integer>(Arrays.asList(16, 17, 18, 47, 48, 49, 75, 76));
    
  public static final ArrayList<Integer> TEST_LIST = new ArrayList<Integer>(Arrays.asList(20, 19, 50, 51, 78, 77, 95, 96));
  
  public static final ArrayList<Integer> FACE_LIST_0 = new ArrayList<Integer>(Arrays.asList(20, 19, 50, 51, 78, 77, 95, 96, 104));  
  public static final ArrayList<Integer> FACE_LIST_1 = new ArrayList<Integer>(Arrays.asList(21, 22, 23, 54, 53, 52, 80, 79, 97, 98));
  public static final ArrayList<Integer> FACE_LIST_2 = new ArrayList<Integer>(Arrays.asList(25, 24, 56, 55, 81, 82, 83, 84, 99, 100));
  public static final ArrayList<Integer> FACE_LIST_3 = new ArrayList<Integer>(Arrays.asList(26, 27, 28, 58, 57, 59, 60, 61, 86, 85));
  public static final ArrayList<Integer> FACE_LIST_4 = new ArrayList<Integer>(Arrays.asList(1, 0, 29, 30, 31, 32, 63, 62, 87, 101));
  public static final ArrayList<Integer> FACE_LIST_5 = new ArrayList<Integer>(Arrays.asList(2, 3, 4, 34, 33, 35, 65, 64, 88, 89));
  public static final ArrayList<Integer> FACE_LIST_6 = new ArrayList<Integer>(Arrays.asList(7, 6, 5, 36, 37, 38, 66, 67, 90, 102));
  public static final ArrayList<Integer> FACE_LIST_7 = new ArrayList<Integer>(Arrays.asList(8, 9, 10, 41, 40, 39, 68, 69, 70, 91));
  public static final ArrayList<Integer> FACE_LIST_8 = new ArrayList<Integer>(Arrays.asList(13, 12, 11, 42, 43, 44, 73, 72, 71, 92));
  public static final ArrayList<Integer> FACE_LIST_9 = new ArrayList<Integer>(Arrays.asList(14, 15, 46, 45, 74, 94, 93, 103));

  public LEDome() {
    super(new LEDomeLights());
    domelights = ((LEDomeLights)fixtures.get(0));
    sphere = new WB_Sphere(domelights.geodome.getCenter(), DOME_RADIUS);
    faces = this.getFaces();
  }
 
  public HE_Mesh getLEDomeMesh() {
    return domelights.geodome;
  }
  
  public List<LEDomeFace> getFaces() {
    return domelights.faces;
  }
  
  public WB_Point projectToSphere(float x, float y, float z) {
    return projectToSphere(new WB_Point(x, y, z));
  }
  
  public WB_Point projectToSphere(WB_Point point) {
    return sphere.projectToSphere(point); 
  }
  
  
  private static class LEDomeLights extends LXAbstractFixture {    
    public HE_Mesh geodome;
    public ArrayList<List<Integer>> lightStringFaceLists = new ArrayList<List<Integer>>();
    public List<LEDomeFace> faces = new ArrayList<LEDomeFace>();
        
    public static final double LIGHT_OFFSET_PROP = 0.3;
    
    private LEDomeLights() {
       buildGeodome();
       createLEDFaces();
       initializeLightStringFaceLists();       
       plotLightsOnDome();
    }
    
    private void buildGeodome() {    
      HEC_Geodesic creator = new HEC_Geodesic();  
      creator.setRadius(DOME_RADIUS); 
      
      // http://stackoverflow.com/questions/3031875/math-for-a-geodesic-sphere
      // N=B+C=number of divisions
      // B=N and C=0 or B=0 and C=N: class I
      // B=C=N/2: class II
      // Other: class III 
      creator.setB(3);
      creator.setC(0);
    
      // class I, II and III: TETRAHEDRON,OCTAHEDRON,ICOSAHEDRON
      // class II only: CUBE, DODECAHEDRON
      creator.setType(HEC_Geodesic.ICOSAHEDRON);
      creator.setCenter(0, 0, 0);
      
      // Make the ZAxis the YAxis. Will generate with correct "top"
      creator.setZAxis(0, 1, 0);
      HE_Mesh geosphere = new HE_Mesh(creator); 
        
      HE_Selection selection = new HE_Selection(geosphere);
      HE_FaceIterator fItr = new HE_FaceIterator(geosphere);    
      
      while (fItr.hasNext()) {
        HE_Face face = fItr.next();
        if (face.getFaceCenter().yd() > -5 * INCHES) {        
          selection.add(face);
        }
      }
      
      geodome = selection.getAsMesh();
      println("numFaces: " + geodome.getNumberOfFaces());     
    }
             
    private void initializeLightStringFaceLists() {      
//      lightStringFaceLists.add(TEST_LIST);
      lightStringFaceLists.add(FACE_LIST_0);
      lightStringFaceLists.add(FACE_LIST_1);
      lightStringFaceLists.add(FACE_LIST_2);
      lightStringFaceLists.add(FACE_LIST_3);
      lightStringFaceLists.add(FACE_LIST_4);
      lightStringFaceLists.add(FACE_LIST_5);
      lightStringFaceLists.add(FACE_LIST_6);
      lightStringFaceLists.add(FACE_LIST_7);
      lightStringFaceLists.add(FACE_LIST_8);
      lightStringFaceLists.add(FACE_LIST_9);
    }

    private void createLEDFaces() {
      int currDirection = DIRECTION_RIGHT;
      HE_Face currFace = getFirstFace();
      HE_Face nextFace;

      for (int i = 0; i < geodome.getNumberOfFaces(); i++) {
        faces.add(new LEDomeFace(currFace));
        currFace.setLabel(i);            
        nextFace = getNextFaceInDirection(currFace, currDirection);
        
        if (nextFace == null) {
          currDirection = nextDirection(currDirection);
          nextFace = getNextFaceInDirection(currFace, currDirection);
        }

        currFace = nextFace;        
      }
    }     

    private HE_Face getNextFaceInDirection(HE_Face face, int direction) {
      List<HE_Face> neighborFaces = face.getNeighborFaces();                  
      HE_Face nextFace = null;            
            
      switch(direction) {          
        case DIRECTION_RIGHT:
          nextFace = nextRightFace(face, neighborFaces);
          break;
        case DIRECTION_FORWARD:
          nextFace = nextForwardFace(face, neighborFaces);
          break;
        case DIRECTION_LEFT:
          nextFace = nextLeftFace(face, neighborFaces);
          break;
        case DIRECTION_BACK:
          nextFace = nextBackFace(face, neighborFaces);
          break;        
      }

      return nextFace;      
    }
    
    private HE_Face nextRightFace(HE_Face face, List<HE_Face> neighborFaces) {
      HE_Face nextFace = null;
      double maxX = face.getFaceCenter().xd();
      
      for(int i = 0; i < neighborFaces.size(); i++) {
        HE_Face currFace = neighborFaces.get(i); 
        if (currFace.getFaceCenter().xd() >  maxX && currFace.getLabel() == -1) {
          maxX = currFace.getFaceCenter().xd();
          nextFace = currFace;
        }
      }

      return nextFace;
    }
   
    private HE_Face nextForwardFace(HE_Face face, List<HE_Face> neighborFaces) {
      HE_Face nextFace = null;
      double maxZ = face.getFaceCenter().zd();
      
      for(int i = 0; i < neighborFaces.size(); i++) {
        HE_Face currFace = neighborFaces.get(i); 
        if (currFace.getLabel() == -1 && currFace.getFaceCenter().zd() >  maxZ) {
          maxZ = currFace.getFaceCenter().zd();
          nextFace = currFace;
        }        
      }

      return nextFace;
    }
   
    private HE_Face nextLeftFace(HE_Face face, List<HE_Face> neighborFaces) {
      HE_Face nextFace = null;
      double minX = face.getFaceCenter().xd();
      
      for(int i = 0; i < neighborFaces.size(); i++) {
        HE_Face currFace = neighborFaces.get(i); 
        if (currFace.getLabel() == -1 && currFace.getFaceCenter().xd() <  minX) {
          minX = currFace.getFaceCenter().xd();
          nextFace = currFace;
        }        
      }

      return nextFace;
    }
    
    private HE_Face nextBackFace(HE_Face face, List<HE_Face> neighborFaces) {
      HE_Face nextFace = null;
      double minZ = face.getFaceCenter().zd();
      
      for(int i = 0; i < neighborFaces.size(); i++) {
        HE_Face currFace = neighborFaces.get(i); 
        if (currFace.getLabel() == -1 && currFace.getFaceCenter().zd() <  minZ) {
          minZ = currFace.getFaceCenter().zd();
          nextFace = currFace;
        }        
      }

      return nextFace;
    } 
    
    private int nextDirection(int direction) {
      return (direction + 1) % 4;  
    }
    
    private HE_Face getFirstFace() {
      WB_Point farLeft = new WB_Point(0, -1000, -1000);
      HE_Vertex firstVertex = geodome.getClosestVertex(farLeft, (WB_KDTree<WB_Point, Long>)(WB_KDTree<?, Long>)geodome.getVertexTree());
      HE_Face firstFace = null;
      float minX = 1000;
      println("FirstVertex: " + firstVertex);
      
      List<HE_Face> faces = firstVertex.getFaceStar();    
      println("Num star faces: " + faces.size());  
      for(int i = 0; i < faces.size(); i++) {
        WB_Point faceCenter = faces.get(i).getFaceCenter();        
        
        if (faceCenter.xf() < minX) {
          minX = faceCenter.xf();
          firstFace = faces.get(i);  
        }        
      }

      return firstFace;      
    }
    
    private void plotLightsOnDome() {          
      for (int i = 0; i < lightStringFaceLists.size(); i++) {
        List<Integer> faceList = lightStringFaceLists.get(i);
        
        for(int j = 0; j < faceList.size(); j++) {
          int index = faceList.get(j);
          plotLightsOnFace(faces.get(index));   
        }
      }
    }
    
    private void plotLightsOnFace(LEDomeFace face) {
      ArrayList<LXPoint> points = new ArrayList<LXPoint>();
      LXPoint lx_point;
      HE_Face he_face = face.he_face;
      WB_Point faceCenter = he_face.getFaceCenter();          
      HE_Vertex isocVertex = findIsocVertex(he_face);
      HE_Vertex currVertex = isocVertex;
      WB_Transform moveTowardCenter = new WB_Transform();
      HE_Halfedge currHalfedge = isocVertex.getHalfedge(he_face);
                           
      do {                       
        moveTowardCenter.clear();        
        moveTowardCenter.addTranslate(LIGHT_OFFSET_PROP, new WB_Vector(currVertex.getPoint(), faceCenter));         
        WB_Point vertexPoint = currVertex.getPoint().apply(moveTowardCenter);   
        lx_point = new LXPoint(vertexPoint.xf(), vertexPoint.yf(), vertexPoint.zf());
        points.add(lx_point);
        addPoint(lx_point);                
        
        moveTowardCenter.clear();
        moveTowardCenter.addTranslate(LIGHT_OFFSET_PROP, new WB_Vector(currHalfedge.getEdgeCenter(), faceCenter));
        WB_Point edgeCenterPoint = currHalfedge.getEdgeCenter().apply(moveTowardCenter);
        lx_point = new LXPoint(edgeCenterPoint.xf(), edgeCenterPoint.yf(), edgeCenterPoint.zf());
        points.add(lx_point);
        addPoint(lx_point);        

        currHalfedge = currHalfedge.getPrevInFace().getPrevInFace();      
        currVertex = currHalfedge.getVertex();
        
      } while(currVertex != isocVertex);

      face.setPoints(points);      
    }
        
    private HE_Vertex findIsocVertex(HE_Face face) {
      List<HE_Vertex> vertices = face.getFaceVertices();            
      HE_Vertex currVertex = vertices.get(0);
      HE_Vertex otherVertex;      
      HE_Vertex isocVertex = null;     
      WB_Point currPoint;
      WB_Point otherPoint;
      float dist1;
      float dist2;      
      float distanceDiff;
      float minDistanceDiff = DOME_RADIUS;
            
      for(int i = 0; i < vertices.size(); i++) {       
        currVertex = vertices.get(i);
        currPoint = currVertex.getPoint();        
        dist1 = dist2 = 0.0;
        
        for (int j = 0; j < vertices.size(); j++) {         
          if(i == j) { continue; }
          
          otherVertex = vertices.get(j);
          otherPoint = otherVertex.getPoint();
          if(dist1 == 0.0) {
            dist1 = dist(currPoint.xf(), currPoint.yf(), currPoint.zf(), otherPoint.xf(), otherPoint.yf(), otherPoint.zf());
          } else {
            dist2 = dist(currPoint.xf(), currPoint.yf(), currPoint.zf(), otherPoint.xf(), otherPoint.yf(), otherPoint.zf());
          }            
        }

        distanceDiff = abs(dist1 - dist2);
        if (minDistanceDiff > distanceDiff) {
          minDistanceDiff = distanceDiff;          
          isocVertex = currVertex;
          
          // Can break if the distances are exactly the same.
          if (distanceDiff == 0.0) { break; }
        }
      }
      
      return isocVertex;
    }       
  }
}

static class LEDomeOutputManager {
  private P2LX lx;  
  private boolean ndb_output_enabled;  
  private LXDatagramOutput ndb_output; 
  
  public LEDomeOutputManager(P2LX lx) {    
    this.lx = lx;
    this.ndb_output_enabled = false;
  }  
  
  public void toggleNDBOutput() {
    this.toggleNDBOutput(!this.ndb_output_enabled); 
  }
  
  public void toggleNDBOutput(boolean enable) {    
    if (enable) {
      this.addLXOutputForNDB();
    } else {
      this.removeLXOutputForNDB();  
    }
    
    this.ndb_output_enabled = enable;
  }
 
  private void addLXOutputForNDB() {    
    int[] points = new int[NUM_CONNECTED_LIGHTS];
    for (int i = 0; i < points.length; ++i) {
      points[i] = i;
    }
    
    try {
      this.ndb_output = new LXDatagramOutput(this.lx);
      DDPDatagram datagram = (DDPDatagram)new DDPDatagram(points).setAddress(NDB_IP_ADDRESS); // whatever the IP is
      this.ndb_output.addDatagram(datagram);
      this.lx.addOutput(this.ndb_output);
    } catch (Exception x) {
      x.printStackTrace();
    }  
  } 
  
  private void removeLXOutputForNDB() {
    if (this.ndb_output != null) {
      this.lx.removeOutput(this.ndb_output);  
    }
  }
}
