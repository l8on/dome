/**
 * The LEDomeFace class represents a face on the LEDome.
 * Use xf(), yf(), and zf() to get the coordinates of the center of the face.
 *
 * Furthermore:
 * It knows if it has any lights on it at all (LEDomeFace#has_lights)
 * It knows what which lights are on it's face (LEDomeFace#points)
 * It knows which faces are nearby (LEDomeFace#neighbors)
 * It knows the 3 faces in which it shares an edge (LEDomeFace#next_door_neighbors)
 * It also has a reference to the face object from the 3d mesh model (LEDomeFace#he_face)
 */
public static class LEDomeFace {
  public HE_Face he_face;
  public List<LXPoint> points;
  public List<LEDomeEdge> edges;
  public List<Integer> neighbors;
  public List<Integer> next_door_neighbors;

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
    ledome_face = face;
    he_halfedge = edge;
  }
  
  public LEDomeEdge(LEDomeFace face, HE_Halfedge edge, List<LXPoint> lxPoints) {
    ledome_face = face;
    he_halfedge = edge;
    points = lxPoints;
  }
  
  public void setPoints(List<LXPoint> lxPoints) {
    points = lxPoints;
  }
  
  public void addPoint(LXPoint lxPoint) {
    if(this.points == null) {
      this.points = new ArrayList<LXPoint>();
    }
    
    points.add(lxPoint);
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
