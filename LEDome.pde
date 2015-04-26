import java.util.List;

/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class LEDome extends LXModel {  
  private LEDomeLights domelights;  
  
  public static final float DOME_RADIUS = 5.5 * FEET;
  
  public static final int LATTICE_DEPTH = 2;
  public static final int LATTICE_WIDTH = 2;
  
  public LEDome() {    
    super(new LEDomeLights());
    domelights = ((LEDomeLights)fixtures.get(0));
  }
 
  public HE_Mesh getLEDomeMesh() {
    return domelights.geodome;
  }
  
  private static class LEDomeLights extends LXAbstractFixture {    
    public HE_Mesh geodome;    
    
    public static final double LIGHT_OFFSET = 5;
    
    private LEDomeLights() {
       buildGeodome();       
       // Here's the core loop where we generate the positions
       // of the points in our model
       plotLightsOnDome();
    }
    
    private void plotLightsOnDome() {            
      HE_FaceIterator fItr = new HE_FaceIterator(geodome);
      
      while (fItr.hasNext()) {
        HE_Face face = fItr.next();
        
        plotLightsOnFace(face);
      }      
    }
    
    private void plotLightsOnFace(HE_Face face) {
      WB_Point faceCenter = face.getFaceCenter();          
      HE_Vertex isocVertex = findIsocVertex(face);
      HE_Vertex currVertex = isocVertex;
      WB_Transform moveTowardCenter = new WB_Transform();
      HE_Halfedge currHalfedge = isocVertex.getHalfedge(face);
      HE_FaceEdgeCirculator fecr = new  HE_FaceEdgeCirculator(face);    
                           
      do {                       
        moveTowardCenter.clear();        
        moveTowardCenter.addTranslate(.3, new WB_Vector(currVertex.getPoint(), faceCenter));         
        WB_Point vertexPoint = currVertex.getPoint().apply(moveTowardCenter);  
        addPoint(new LXPoint(vertexPoint.xf(), vertexPoint.yf(), vertexPoint.zf()));                
        
        moveTowardCenter.clear();
        moveTowardCenter.addTranslate(.3, new WB_Vector(currHalfedge.getEdgeCenter(), faceCenter));
        WB_Point edgeCenterPoint = currHalfedge.getEdgeCenter().apply(moveTowardCenter);
        addPoint(new LXPoint(edgeCenterPoint.xf(), edgeCenterPoint.yf(), edgeCenterPoint.zf()));
              
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
                
        println("vertex " + i + ", dist1: " + dist1 + ", dist2: " + dist2);
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
}

