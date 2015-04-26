import wblut.processing.*;
import wblut.geom.*;
import wblut.math.*;
import processing.opengl.*;
import java.util.List;

List<WB_Point> points;
List<WB_VoronoiCell3D> vorcells;
List<WB_FaceListMesh> cells;
WB_Render3D render;
float dx, dy, dz;
WB_AABB aabb;

void setup() {
  size(1920, 1080, OPENGL);
  smooth(8);
  points=new ArrayList<WB_Point>();
  // add points to collection
  dx=600;
  dy=220;
  dz=250;
  int I=5;
  int J=2;
  int K=2;
  float rx=50;
  float ry=50;
  float rz=50;
  for (int i=0; i<I+1; i++) {
    for (int j=0; j<J+1; j++) {
      for (int k=0; k<K+1; k++) {
        points.add(new WB_Point(-dx+i*2.0/I*dx+random(-rx, rx), -dy+j*2.0/J*dy+random(-ry, ry), -dz+k*2.0/K*dz+random(-rz, rz)));
      }
    }
  }
  aabb=new WB_AABB(-dx-dx/I, -dy-dy/J, -dz-dz/K, dx+dx/I, dy+dy/J, dz+dz/K);
  vorcells=WB_Voronoi.getVoronoi3D(points, aabb);
  cells=new ArrayList<WB_FaceListMesh>();
  for (WB_VoronoiCell3D vorcell : vorcells) {
    cells.add(vorcell.getMesh());
  }
  println(cells.size());
  divide();
  divide();
  divide();
  divide();
  stroke(0);
  noFill();
  render= new WB_Render3D(this);
}

void draw() {
  background(50);
  translate(width/2, height/2, 0);
  lights();
  scale(0.7);
  rotateY(mouseX*1.0f/width*TWO_PI);
  int c=0;
  for (WB_FaceListMesh mesh : cells) {
    if (c%10==0) {
      fill(255);
    } else {
      noFill();
    }
    render.drawMesh(mesh);
    c++;
  }
}

void divide() {
  List<WB_FaceListMesh> subcells=new ArrayList<WB_FaceListMesh>();
  for (WB_FaceListMesh mesh : cells) {
    if (random(100)<25) {
      subcells.add(mesh);
    } else {
      List<WB_FaceListMesh> tmp=getSub(mesh, 5);
      int id=0;
      for (WB_FaceListMesh subcell : tmp) {
        subcells.add(tmp.get(id));
        id++;
      }
    }
  }
  cells=subcells; 
  
}



List<WB_FaceListMesh> getSub(WB_FaceListMesh mesh, int n) {
  aabb=mesh.getAABB();
  List<WB_Point> points =new ArrayList<WB_Point>(n);
  for (int i=0; i<n; i++) {
    points.add(new WB_Point(random((float)aabb.getMinX(), (float)aabb.getMaxX()), random((float)aabb.getMinY(), (float)aabb.getMaxY()), random((float)aabb.getMinZ(), (float)aabb.getMaxZ())));
  }
  aabb.expandBy(5);
  List<WB_VoronoiCell3D> vorcells=WB_Voronoi.getVoronoi3D(points, aabb); 
  List<WB_FaceListMesh> meshes=new ArrayList<WB_FaceListMesh>();
  for (WB_VoronoiCell3D vorcell : vorcells) {
    vorcell.constrain( mesh);
    if (vorcell.getMesh()!=null) meshes.add(vorcell.getMesh());
  }
  return meshes;
}

void mousePressed() {
  points=new ArrayList<WB_Point>();
  // add points to collection
  dx=600;
  dy=220;
  dz=250;
  int I=5;
  int J=2;
  int K=2;
  float rx=50;
  float ry=50;
  float rz=50;
  for (int i=0; i<I+1; i++) {
    for (int j=0; j<J+1; j++) {
      for (int k=0; k<K+1; k++) {
        points.add(new WB_Point(-dx+i*2.0/I*dx+random(-rx, rx), -dy+j*2.0/J*dy+random(-ry, ry), -dz+k*2.0/K*dz+random(-rz, rz)));
      }
    }
  }
  aabb=new WB_AABB(-dx-dx/I, -dy-dy/J, -dz-dz/K, dx+dx/I, dy+dy/J, dz+dz/K);

  vorcells=WB_Voronoi.getVoronoi3D(points, aabb);


  cells=new ArrayList<WB_FaceListMesh>();
  for (WB_VoronoiCell3D vorcell : vorcells) {
    cells.add(vorcell.getMesh());
  }
  println(cells.size());
  divide();
  divide();
  divide();
  divide();
}

