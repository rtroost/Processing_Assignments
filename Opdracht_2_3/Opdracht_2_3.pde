PShape s;
Table d;


void setup() { 
  size(1150, 720);
  background(255);
  noLoop();

  s = loadShape("kaartUSA.svg");
  d = loadTable("wapenbezit.tsv");
  println(d.getRowCount() + " total rows in table");
} 

void draw() {
  // Draw the full map first
  shape(s, 0, 0, width, height);
  
  colorMode(HSB, 100);

  for (TableRow row : d.rows()) {
    
    String state = row.getString(0);
    float weapons = Float.valueOf(row.getString(1));

    PShape currentShape = s.getChild(state);
    currentShape.disableStyle();
    fill(0, 30 + weapons, 100);
    noStroke();
    // Draw a single state
    shape(currentShape, 0, 0, width, height);
  }
}

