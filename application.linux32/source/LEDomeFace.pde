/**
 * The LEDomeFace class represents a face on the LEDome.
 * Use xf(), yf(), and zf() to get the coordinates of the center of the face.
 *
 * Furthermore:
 * It knows if it has any lights on it at all (LEDomeFace#hasLights())
 * It knows what which lights are on it's face (LEDomeFace#points)
 * It knows which faces are nearby (LEDomeFace#neighbors)
 * It knows the 3 faces in which it shares an edge (LEDomeFace#next_door_neighbors)
 * It also has a reference to the face object from the 3d mesh model (LEDomeFace#he_face)
 */
public static class LEDomeFace {
  public HE_Face he_face;
  public List<LXPoint> points;
  public List<LEDomeEdge> edges;
  private List<Integer> neighbors;
  private List<Integer> next_door_neighbors;

  public LEDomeFace(HE_Face face) {
    he_face = face;    
  }

  public LEDomeFace(HE_Face face, List<LXPoint> lxPoints) {
    he_face = face;
    points = lxPoints;    
  }
  
  public float xf() {
    return he_face.getFaceCenter().xf();  
  }
  
  public float yf() {
    return he_face.getFaceCenter().yf();  
  }
  
  public float zf() {
    return he_face.getFaceCenter().zf();  
  }
  
  public double xd() {
    return he_face.getFaceCenter().xd();  
  }
  
  public double yd() {
    return he_face.getFaceCenter().yd();  
  }
  
  public double zd() {
    return he_face.getFaceCenter().zd();  
  }

  public void setPoints(List<LXPoint> lxPoints) {
    this.points = lxPoints;    
  }
  
  public void setEdges(List<LEDomeEdge> edges) {
    this.edges = edges;  
  }
  
  public List<Integer> getNeighbors() {
    if (this.neighbors == null) {      
      this.neighbors = new ArrayList<Integer>();
      for(HE_Vertex he_vertex : this.he_face.getFaceVertices()) {
        for(HE_Face he_neighbor : he_vertex.getFaceStar()) {
          if (he_neighbor.getLabel() == this.he_face.getLabel()) {
            continue;  
          }
          
          if (!this.neighbors.contains(he_neighbor.getLabel())) {
            this.neighbors.add(he_neighbor.getLabel());  
          }
        }
      }
    }
    
    return this.neighbors;
  }    
  
  public List<Integer> getNextDoorNeighbors() {
    if (this.next_door_neighbors == null) {
      this.next_door_neighbors = new ArrayList<Integer>();      
      for(HE_Face he_neighbor : this.he_face.getNeighborFaces()) {                
        if (!this.next_door_neighbors.contains(he_neighbor.getLabel())) {
          this.next_door_neighbors.add(he_neighbor.getLabel());  
        }
      }
    }
    
    return this.next_door_neighbors;
  }
  
  public boolean hasLights() {
    return this.points != null && this.points.size() > 0;    
  }
  
  public boolean onFace(LXPoint point) {
    return this.points != null && this.points.contains(point);
  }
}

public static class LEDomeEdge {  
  public HE_Halfedge he_halfedge;
  public LEDomeFace ledome_face;
  public List<LXPoint> points;  
  
  public LEDomeEdge(LEDomeFace face, HE_Halfedge edge) {
    setFace(face);
    setHalfedge(edge);        
  }
  
  public LEDomeEdge(LEDomeFace face, HE_Halfedge edge, List<LXPoint> points) {
    setFace(face);
    setHalfedge(edge);
    setPoints(points);
  }
  
  public void setFace(LEDomeFace face) {
    this.ledome_face = face;
  }
  
  public void setHalfedge(HE_Halfedge edge) {    
    this.he_halfedge = edge;
  }
  
  public void setPoints(List<LXPoint> points) {
    this.points = points;
  }
  
  public void addPoint(LXPoint point) {
    if(this.points == null) {
      this.points = new ArrayList<LXPoint>();
    }
    
    points.add(point);
  }
  
  public LXPoint closestPoint(float x, float y, float z) {
    float min_dist = 1000 * FEET;
    LXPoint retPoint = this.points.get(0);
    
    for(LXPoint p : this.points) {
      float curr_dist = dist(p.x, p.y, p.z, x, y, z);
      
      if(curr_dist < min_dist) {
        min_dist = curr_dist;
        retPoint = p;
      }
    }
    
    return retPoint;
  }
  
  public LXPoint closestVertexPoint(float x, float y, float z) {
    float min_dist = 1000 * FEET;
    LXPoint retPoint = this.points.get(0);    
    LXPoint[] vertexPoints = new LXPoint[] { this.points.get(0), this.points.get(2) };  

    for(LXPoint p : vertexPoints) {
      float curr_dist = dist(p.x, p.y, p.z, x, y, z);
      
      if(curr_dist < min_dist) {
        min_dist = curr_dist;
        retPoint = p;
      }
    }
    
    return retPoint;
  }
  
  public float xf() {
    return he_halfedge.getEdgeCenter().xf();  
  }
  
  public float yf() {
    return he_halfedge.getEdgeCenter().yf();  
  }
  
  public float zf() {
    return he_halfedge.getEdgeCenter().zf();  
  }
  
  public double xd() {
    return he_halfedge.getEdgeCenter().xd();  
  }
  
  public double yd() {
    return he_halfedge.getEdgeCenter().yd();  
  }
  
  public double zd() {
    return he_halfedge.getEdgeCenter().zd();  
  }
   
  public boolean hasLights() {
   return this.points != null && this.points.size() > 0;    
  }
  
  public boolean onEdge(LXPoint point) {
    return this.points != null && this.points.contains(point);
  }
}
