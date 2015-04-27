import java.util.Arrays;
import java.util.List;

/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class LEDome extends LXModel {  
  private LEDomeLights domelights;  
  
  public static final float DOME_RADIUS = 5.5 * FEET;  
  
  public static final int DIRECTION_RIGHT = 0;
  public static final int DIRECTION_FORWARD = 1;
  public static final int DIRECTION_LEFT = 2;
  public static final int DIRECTION_BACK = 3;
    
  public static final ArrayList<Integer> NO_LIGHT_FACES = new ArrayList<Integer>(Arrays.asList(16, 17, 18, 47, 48, 49, 75, 76));
    

  public LEDome() {
    super(new LEDomeLights());
    domelights = ((LEDomeLights)fixtures.get(0));
  }
 
  public HE_Mesh getLEDomeMesh() {
    return domelights.geodome;
  }
  
  public List<LEDomeFace> getFaces() {
    return domelights.faces;
  }
  
  private static class LEDomeLights extends LXAbstractFixture {    
    public HE_Mesh geodome;
    public List<LEDomeFace> faces = new ArrayList<LEDomeFace>();
        
    public static final double LIGHT_OFFSET = 5;
    
    private LEDomeLights() {
       buildGeodome();
       createLEDFaces();
       // Here's the core loop where we generate the positions
       // of the points in our model
       plotLightsOnDome();
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
        println("Face center " + i + ": " + faceCenter);
        
        if (faceCenter.xf() < minX) {
          minX = faceCenter.xf();
          firstFace = faces.get(i);  
        }        
      }

      return firstFace;      
    }
    
    private void plotLightsOnDome() {    
       for(int i = 0; i < faces.size(); i++) {
         if (NO_LIGHT_FACES.contains(i)) {
           continue;  
         }
         
         plotLightsOnFace(faces.get(i));    
       }
      
//      HE_FaceIterator fItr = new HE_FaceIterator(geodome);
//      
//      while (fItr.hasNext()) {
//        HE_Face face = fItr.next();
//        
//        plotLightsOnFace(face);
//      }      
        

    }
    
    private void plotLightsOnFace(LEDomeFace face) {      
      List<LXPoint> points = new ArrayList<LXPoint>();
      LXPoint lx_point;
      HE_Face he_face = face.he_face;
      WB_Point faceCenter = he_face.getFaceCenter();          
      HE_Vertex isocVertex = findIsocVertex(he_face);
      HE_Vertex currVertex = isocVertex;
      WB_Transform moveTowardCenter = new WB_Transform();
      HE_Halfedge currHalfedge = isocVertex.getHalfedge(he_face);
      HE_FaceEdgeCirculator fecr = new  HE_FaceEdgeCirculator(he_face);    
                           
      do {                       
        moveTowardCenter.clear();        
        moveTowardCenter.addTranslate(.3, new WB_Vector(currVertex.getPoint(), faceCenter));         
        WB_Point vertexPoint = currVertex.getPoint().apply(moveTowardCenter);   
        lx_point = new LXPoint(vertexPoint.xf(), vertexPoint.yf(), vertexPoint.zf());
        points.add(lx_point);
        addPoint(lx_point);                
        
        moveTowardCenter.clear();
        moveTowardCenter.addTranslate(.3, new WB_Vector(currHalfedge.getEdgeCenter(), faceCenter));
        WB_Point edgeCenterPoint = currHalfedge.getEdgeCenter().apply(moveTowardCenter);
        lx_point = new LXPoint(edgeCenterPoint.xf(), edgeCenterPoint.yf(), edgeCenterPoint.zf());
        points.add(lx_point);
        addPoint(lx_point);        

        currHalfedge = currHalfedge.getPrevInFace().getPrevInFace();      
        currVertex = currHalfedge.getVertex();
        
      } while(currVertex != isocVertex);      
    }
    
    private HE_Vertex findTopVertex(HE_Face face) {
      List<HE_Vertex> vertices = face.getFaceVertices();
      HE_Vertex topVertex = vertices.get(0);
      HE_Vertex currVertex;                 
      
      for(int i = 1; i < vertices.size(); i++) {       
        currVertex = vertices.get(i);
        
        if (currVertex.yd() > topVertex.yd()) {
          topVertex = currVertex;
        }
      }
  
      return topVertex;    
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
      
//      HEM_Lattice lattice = new HEM_Lattice().setDepth(LATTICE_DEPTH).setWidth(LATTICE_WIDTH);
//      geodome.modify(lattice);
      
//      println("numFaces: " + geodome.getNumberOfFaces());
    }
  }
  
  private static class LEDomeFace {
    public HE_Face he_face;
    public List<LXPoint> points;     
 
    public LEDomeFace(HE_Face face) {
      he_face = face;      
    }
    
    public LEDomeFace(HE_Face face, List<LXPoint> lxPoints) {
      he_face = face;
      points = lxPoints; 
    }
    
    public void setPoints(List<LXPoint> lxPoints) {
      points = lxPoints;  
    }    
  }
}

