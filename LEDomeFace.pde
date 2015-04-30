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
  public boolean has_lights;  
  public HE_Face he_face;
  public List<LXPoint> points;
  public List<Integer> neighbors;
  public List<Integer> next_door_neighbors;

  public LEDomeFace(HE_Face face) {
    he_face = face;
    has_lights = false;
  }

  public LEDomeFace(HE_Face face, List<LXPoint> lxPoints) {
    he_face = face;
    points = lxPoints;
    has_lights = (lxPoints != null && lxPoints.size() > 0);
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
    points = lxPoints;
    has_lights = (lxPoints != null && lxPoints.size() > 0);
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
}
