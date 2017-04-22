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

public class Opdracht_2_1 extends PApplet {

public void setup()
{
	size(1280, 720);
	background(255);
	noLoop();
}

public void draw()
{
	textFont(createFont("Arial",16,true));
	fill(0);
	
	String[] xValues = new String[] {"JAN","FEB","MRT","APR","MEI","JUN","JUL","AUG","SEP","OKT","NOV","DEC"};
	int[] dataValues = new int[] {1000,2000,3000,3000,3000,2500,2500,2000,1000,500,500,500};
	
	/* Draw graph */
	drawBarChart(
		new int[] {100, 100}, // StartXY
		new int[] {800,400}, // Width and Height
		xValues, // X-Axis
		new int[] {0,3000,6}, // start, stop, step for Y-Axis
		dataValues
	);
}

public void drawBarChart(int[] coords, int[] size, String[] xValues, int[] yValues, int[] dataValues)
{
	float scaleX = drawAxisX(
		new int[] {coords[0], coords[1] + size[1]}, // X and Y coords
		size[0], // Width of the line
		xValues
	);

	float scaleY = drawAxisY(
		new int[] {coords[0], coords[1]}, // X and Y coords
		size[1], // Height of the line
		yValues[0],
		yValues[1],
		yValues[2]
	);
	
	int heightestValue = 0;
	
	for(int i = 0; i < dataValues.length; i++) {
		if(dataValues[i] > heightestValue) heightestValue = dataValues[i];
	}
	
	noStroke();
	
	for(int i = 0; i < dataValues.length; i++) {
		
		// Make red
		boolean isHighestValue = (dataValues[i] == heightestValue);
		if(isHighestValue) fill(255,0,0);
		
		float trueX = coords[0] + (i * scaleX);
		float trueY = coords[1] + size[1] - (dataValues[i] * scaleY);
		rectMode(CORNER);
  		rect(trueX, trueY, 30, (dataValues[i] * scaleY));
  		
  		if(isHighestValue) fill(0,0,0);
	}
}

public float drawAxisY(int[] coords, int size, int valueStart, int valueEnd, int valueStep)
{
	String prefix = "";
	String suffix = "";

	textAlign(RIGHT);

	// Draw the line
	line(coords[0], coords[1], coords[0], coords[1] + size);

	// Calculate the width between each value
	int step = (valueEnd - valueStart) / valueStep;
	float padding = (float) size / (float) valueStep;

	for(int i = 0; i <= valueStep; i++){
		String str = Integer.toString(valueStart + (step * i));
		line(coords[0], coords[1] + size - (padding * i), coords[0] - 6, coords[1] + size - (padding * i));
		text(prefix + str + suffix, coords[0] - 15, coords[1] + size - (padding * i));
	}

	textAlign(LEFT);

	return (float) size / ((float)valueEnd - (float)valueStart);
}

public float drawAxisX(int[] coords, int size, String[] labels)
{
	String prefix = "", suffix = "";
	// Draw the line
	line(coords[0], coords[1], coords[0] + size, coords[1]);

	// Calculate the width between each value
	float padding = (float) size / (float) labels.length;

	textAlign(CENTER);

	for(int i = 0; i < labels.length; i++){
		line(coords[0] + (padding * i), coords[1], coords[0] + (padding * i), coords[1] + 6);
		text(prefix + labels[i] + suffix, coords[0] + (padding * i), coords[1] + 30);
	}

	textAlign(LEFT);

	return (float) size / (float)labels.length;
}

public void plotBar(int topx, int topy, int bottomx, int bottomy){
  fill(0,0,255);
  rectMode(CORNER);
  
  rect(topx, topy, bottomx, bottomy);
}


    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "Opdracht_2_1" });
    }
}
