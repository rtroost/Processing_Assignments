import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Opdracht_2_3 extends PApplet {

PShape s;
Table d;


public void setup() { 
  size(1150, 720);
  background(255);
  noLoop();

  s = loadShape("kaartUSA.svg");
  d = loadTable("wapenbezit.tsv");
  println(d.getRowCount() + " total rows in table");
} 

public void draw() {
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


    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "Opdracht_2_3" });
    }
}
