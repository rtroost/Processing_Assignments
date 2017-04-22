import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.io.BufferedReader; 
import java.io.FileNotFoundException; 
import java.io.FileReader; 
import java.io.IOException; 
import java.util.Calendar; 
import java.util.Arrays; 
import java.util.ArrayList; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Opdracht_EO_1 extends PApplet {










private final boolean DEBUG = true;

/* Everything controls */
ControlP5 cp5;
DropdownList set_year, set_quarter;
Chart myChart;

PFont f;

HashMap<Integer, JaarGegevens> jaarData;

float range_min, range_max;
int current_kwartaal;

public void setup() {
	size(1100,600);
	background(255);
	frameRate(30);

	f = createFont("Arial",16,true);

	cp5 = new ControlP5(this);
	jaarData = new HashMap<Integer, JaarGegevens>();

	loadData(dataPath("etmgeg_344.txt"));

	makeControls();

	myChart = cp5.addChart("graph")
		.setPosition(50, 50)
		.setSize(800, 500)
		.setView(Chart.LINE);

	myChart.getColor().setBackground(color(255));
	myChart.setStrokeWeight(1.5f);

	// set_year.setIndex(0);
	// set_quarter.setIndex(0);

  changeDataset(2001, 3);
}

public void draw() {
	background(255);

	switch(this.current_kwartaal) {
		case 1:
			drawAxisX(50, 550, 800, new String[] {"Januari", "Februari", "Maart"}); break;
		case 2:
			drawAxisX(50, 550, 800, new String[] {"April", "Mei", "Juni"}); break;
		case 3:
			drawAxisX(50, 550, 800, new String[] {"Juli", "Augustus", "September"}); break;
		case 4:
			drawAxisX(50, 550, 800, new String[] {"Oktober", "November", "December"}); break;
	}

	drawAxisY(49, 50, 500, (int)Math.floor(range_min), (int)Math.ceil(range_max), 20);
}

public void loadData(String file) {
	BufferedReader br = null;
	String line = "";
	String cvsSplitBy = ",";

	try {

		br = new BufferedReader(new FileReader(file));
		br.readLine(); // Skip header
		br.readLine(); // Skip empty line

		while ((line = br.readLine()) != null) {

			// use comma as separator
			String[] split = line.split(cvsSplitBy);

			String date = split[1].trim();
			int jaar = Integer.parseInt(date.substring(0, 4));

			String avg = split[11].trim();
			String min = split[12].trim();
			String max = split[14].trim();

			if( ! jaarData.containsKey(jaar))
				jaarData.put(jaar, new JaarGegevens(jaar));

			JaarGegevens obj_jaar = jaarData.get(jaar);

			obj_jaar.addData(date, avg, min, max);
		}

	} catch (FileNotFoundException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		if (br != null) {
			try {
				br.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}

public void makeControls() {
	set_year = cp5.addDropdownList("set_year")
		.setPosition(width - 230, 15)
		.setSize(120,80)
		.setCaptionLabel("Jaar");

	for (int i=1960; i<2013 ;i++) {
		set_year.addItem(Integer.toString(i), i);
	}

	set_quarter = cp5.addDropdownList("set_quarter")
		.setPosition(width - 105, 15)
		.setSize(100,80)
		.setCaptionLabel("Kwartaal");

	set_quarter.addItem("Kwartaal 1", 1);
	set_quarter.addItem("Kwartaal 2", 2);
	set_quarter.addItem("Kwartaal 3", 3);
	set_quarter.addItem("Kwartaal 4", 4);
}

public void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

	if (theEvent.isGroup()) {
		if (theEvent.isFrom(set_year) || theEvent.isFrom(set_quarter)) {
			if( ! (set_year.getValue() == 0.0f || set_quarter.getValue() == 0.0f))
				this.changeDataset((int)set_year.getValue(), (int)set_quarter.getValue());
		}
  }
}

public void changeDataset(int year, int kwartaal) {
	if( ! jaarData.containsKey(year))
		return;

	JaarGegevens theYear = jaarData.get(year);

	this.current_kwartaal = kwartaal;

	TemperatuurData[] kwartaalData = theYear.getKwartaalData(kwartaal);

	float[] temp_avgs = new float[0];
	float[] temp_mins = new float[0];
	float[] temp_maxs = new float[0];

	range_min = 0.0f;
	range_max = 0.0f;

	for(TemperatuurData d : kwartaalData) {
		temp_avgs = Arrays.copyOf(temp_avgs, temp_avgs.length + 1);
		temp_avgs[temp_avgs.length - 1] = d.getAvg();

		temp_mins = Arrays.copyOf(temp_mins, temp_mins.length + 1);
		temp_mins[temp_mins.length - 1] = d.getMin();

		temp_maxs = Arrays.copyOf(temp_maxs, temp_maxs.length + 1);
		temp_maxs[temp_maxs.length - 1] = d.getMax();

		if(range_min == 0.0f || d.getMin() < range_min)
			range_min = d.getMin();

		if(range_max == 0.0f || d.getMax() > range_max)
			range_max = d.getMax();
	}

	myChart.setRange(range_min, range_max);

	myChart.addDataSet("gemiddelde");
	myChart.setColors("gemiddelde", color(0,255,0));
	myChart.setData("gemiddelde", temp_avgs);

	myChart.addDataSet("minimaal");
	myChart.setColors("minimaal", color(255,0,0));
	myChart.setData("minimaal", temp_mins);

	myChart.addDataSet("maximaal");
	myChart.setColors("maximaal", color(0,0,255));
	myChart.setData("maximaal", temp_maxs);

	if (kwartaal == 1)
		drawAxisX(50, 550, 800, new String[] {"Januari", "Februari", "Maart"});
	else if (kwartaal == 2)
		drawAxisX(50, 550, 800, new String[] {"April", "Mei", "Juni"});
	else if (kwartaal == 3)
		drawAxisX(50, 550, 800, new String[] {"Juli", "Augustus", "September"});
	else if (kwartaal == 4)
		drawAxisX(50, 550, 800, new String[] {"Oktober", "November", "December"});

	drawAxisY(50, 50, 500, (int)Math.floor(range_min), (int)Math.ceil(range_max), 20);
}

public void drawAxisX(int cX, int cY, int size, String[] values)
{
	String prefix = "";
	String suffix = "";

	textAlign(CENTER);

	// Draw the line
	line(cX, cY, cX + size, cY);

	// Calculate the width between each value
	float step = (float) size / (float) values.length;

	textFont(f, 12);
	fill(0);

	for(int i = 0; i < values.length; i++){
		line(cX + (step * (i + 1)), cY, cX + (step * (i + 1)), cY + 6);
		text(prefix + values[i] + suffix, cX + (step * (i + 1)) - (step / 2), cY + 16);
	}

	textAlign(LEFT);
}

public void drawAxisY(int cX, int cY, int size, int valueStart, int valueEnd, int valueStep)
{
	String prefix = "";
	String suffix = "";

	textAlign(RIGHT);

	strokeWeight(1);
	fill(0);
	// Draw the line
	line(cX, cY, cX, cY + size);

	// Calculate the width between each value
	int step = (valueEnd - valueStart) / valueStep;
	float padding = (float) size / (float) valueStep;

	for(int i = 0; i <= valueStep; i++){
		String str = Integer.toString(valueStart + (step * i));
		line(cX, cY + size - (padding * i), cX - 6, cY + size - (padding * i));
		text(prefix + str + suffix, cX - 15, cY + size - (padding * i));
	}

	textAlign(LEFT);
}

class JaarGegevens {
	int year;
	TemperatuurData[] kwartaal1, kwartaal2, kwartaal3, kwartaal4;

	public JaarGegevens(int year) {
		this.year = year;
		kwartaal1 = new TemperatuurData[0];
		kwartaal2 = new TemperatuurData[0];
		kwartaal3 = new TemperatuurData[0];
		kwartaal4 = new TemperatuurData[0];
	}

	public void addData(String date, String avg, String min, String max) {

		Calendar c = stringToCalendar(date);

		int month = c.get(Calendar.MONTH);

		TemperatuurData d = new TemperatuurData(c, avg, min, max);

		TemperatuurData[] kwartaal = null;

		if(month <= 3) {
			kwartaal1 = Arrays.copyOf(kwartaal1, kwartaal1.length + 1);
			kwartaal1[kwartaal1.length - 1] = d;
		} else if(month >= 4 && month <= 6) {
			kwartaal2 = Arrays.copyOf(kwartaal2, kwartaal2.length + 1);
			kwartaal2[kwartaal2.length - 1] = d;
		} else if(month >= 7 && month <= 9) {
			kwartaal3 = Arrays.copyOf(kwartaal3, kwartaal3.length + 1);
			kwartaal3[kwartaal3.length - 1] = d;
		} else if(month >= 10 && month <= 12) {
			kwartaal4 = Arrays.copyOf(kwartaal4, kwartaal4.length + 1);
			kwartaal4[kwartaal4.length - 1] = d;
		}
	}

	public TemperatuurData[] getKwartaalData(int kwartaal) {
		switch(kwartaal) {
			case 1: return kwartaal1;
			case 2: return kwartaal2;
			case 3: return kwartaal3;
			case 4: return kwartaal4;
			default: return null;
		}
	}

	private Calendar stringToCalendar(String date) {
		Calendar c = Calendar.getInstance();
		c.set(Integer.parseInt(date.substring(0,4)), Integer.parseInt(date.substring(4,6)) - 1, Integer.parseInt(date.substring(6,8)));

		return c;
	}
}

class TemperatuurData {
	Calendar date;
	float avg, min, max;

	public TemperatuurData(Calendar date, String avg, String min, String max) {
		this.date = date;

		if( ! min.isEmpty())
			this.min = Float.parseFloat(min) * 0.1f;

		if( ! max.isEmpty())
			this.max = Float.parseFloat(max) * 0.1f;

		if( ! avg.isEmpty())
			this.avg = Float.parseFloat(avg) * 0.1f;
		else {
			this.avg = (this.min + this.max) / 2f;
		}
	}

	public float getAvg() {
		return this.avg;
	}

	public float getMin() {
		return this.min;
	}

	public float getMax() {
		return this.max;
	}

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Opdracht_EO_1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
