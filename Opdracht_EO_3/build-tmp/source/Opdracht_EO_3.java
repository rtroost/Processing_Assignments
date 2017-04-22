import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.util.Map.Entry; 
import java.util.Collections; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Opdracht_EO_3 extends PApplet {

/*************************************************
 * LAT = X
 * LON = Y

 * Steden en hun coordianaten
 * Valkenburg  =
 * Schiphol =
 * De Bilt =
 * Hoek van Holland  =
 * Rotterdam =
 * Cabauw =
 * Herwijnen =

 * HOEKEN
 * Hoek van Holland - Rotterdam - Valkenburg
 * Cabauw - Rotterdam - Valkenburg
 * De Bilt - Herwijnen - Cabauw
 * De Bilt - schiphol - Valkenburg
 * Valkenburg - De Bilt - Cabauw
 * Cabauw - Rotterdam - Herwijnen
 *
 * eventueel ook nog gebruiken
 * Deelen
 * Volkel
 */





private final boolean DEBUG = true;

PFont f;

/* Everything controls */
ControlP5 cp5;
DropdownList ddl_day, ddl_month, ddl_year;
CheckBox gfx_options;

PShape map;

/* Holds the weather stations */
HashMap<String, WeatherStation> weatherStations = new HashMap<String, WeatherStation>();

/* Holds the triangle combinations for Barycentric coordinates */
ArrayList<GeomTriangle> cityTriangles = new ArrayList<GeomTriangle>();

/* Data subsets */
HashMap<String, Float> subsetTemperatures = new HashMap<String, Float>();
HashMap<String, Integer> subsetWindDirections = new HashMap<String, Integer>();
HashMap<String, Integer> subsetWindSpeeds = new HashMap<String, Integer>();

/* Map limits */
Float rangeX_links = 3.8949308638000346f;
Float rangeX_rechts = 5.816164994659482f;
Float rangeY_top = 52.456971340027025f;
Float rangeY_bottom = 51.499467276808595f;

float t_min = 0, t_max = 0;

public void setup() {

	size(1000, 700);
	// noLoop();
	frameRate(30);
	smooth(); // Anti-aliasing

	f = createFont("Arial",16,true);

	cp5 = new ControlP5(this);
	makeControls();

	map = loadShape("mapnl2.svg");

	/* Add weather stations */
	WeatherStation s;

	s = new WeatherStation();
	s.setId("valkenburg");
	s.setCoordinates(new float[] { 52.17929960836679f, 4.428261304321164f });
	s.loadFile("etmgeg_210.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("schiphol");
	s.setCoordinates(new float[] { 52.30751851387325f, 4.748323941650282f });
	s.loadFile("etmgeg_240.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("debilt");
	s.setCoordinates(new float[] { 52.10930658771594f, 5.179022336425739f });
	s.loadFile("etmgeg_260.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("hoekvanholland");
	s.setCoordinates(new float[] { 51.97716935731944f, 4.131201291503972f });
	s.loadFile("etmgeg_330.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("rotterdam");
	s.setCoordinates(new float[] { 51.91346086265449f, 4.4680009130859135f });
	s.loadFile("etmgeg_344.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("cabauw");
	s.setCoordinates(new float[] { 51.96480938497381f, 4.897626424255222f });
	s.loadFile("etmgeg_348.txt");
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("herwijnen");
	s.setCoordinates(new float[] { 51.827245407946165f, 5.129927182617317f });
	s.loadFile("etmgeg_356.txt");
	weatherStations.put(s.getId(), s);

	fillData("20131101");

	println("DEBUG: Weerstations ingeladen.");

	cityTriangles.add(
		new GeomTriangle(weatherStations.get("hoekvanholland"), weatherStations.get("rotterdam"), weatherStations.get("valkenburg")));
	cityTriangles.add(
		new GeomTriangle(weatherStations.get("valkenburg"), weatherStations.get("schiphol"), weatherStations.get("debilt")));
	cityTriangles.add(
		new GeomTriangle(weatherStations.get("valkenburg"), weatherStations.get("debilt"), weatherStations.get("cabauw")));
	cityTriangles.add(
		new GeomTriangle(weatherStations.get("valkenburg"), weatherStations.get("cabauw"), weatherStations.get("rotterdam")));
	cityTriangles.add(
		new GeomTriangle(weatherStations.get("herwijnen"), weatherStations.get("rotterdam"), weatherStations.get("cabauw")));
	cityTriangles.add(
		new GeomTriangle(weatherStations.get("herwijnen"), weatherStations.get("debilt"), weatherStations.get("cabauw")));
}

public void draw() {

	background(255);

	/* Draw the full map first */
	shape(map, -300, -800, 2050, 2050);

	/* Draw the heatmap */
	if(gfx_options.getArrayValue()[0] != 0.0f)
		drawHeatmap(105, 100, 680, 475);

	/* Draw the wind directions map */
	strokeWeight(1);
	if(gfx_options.getArrayValue()[1] != 0.0f)
		drawWindDirections(105, 100, 680, 475);

	/* Draw a small rectangle for each weather station */
	for (WeatherStation ws : weatherStations.values())
		ws.drawSelf();

	if(DEBUG) drawDebuggingTools();
}

public void makeControls() {
	ddl_day = cp5.addDropdownList("ddl_day")
		.setPosition(width - 275, 20)
		.setSize(40,120)
		.setCaptionLabel("Dag");

	for (int i=1; i<31 ;i++) {
    ddl_day.addItem(Integer.toString(i), i);
  }

	ddl_month = cp5.addDropdownList("ddl_month")
		.setPosition(width - 230, 20)
		.setSize(100,120)
		.setCaptionLabel("Maand");

	ddl_month.addItem("January", 1);
	ddl_month.addItem("February", 2);
	ddl_month.addItem("March", 3);
	ddl_month.addItem("April", 4);
	ddl_month.addItem("May", 5);
	ddl_month.addItem("June", 6);
	ddl_month.addItem("July", 7);
	ddl_month.addItem("August", 8);
	ddl_month.addItem("September", 9);
	ddl_month.addItem("October", 10);
	ddl_month.addItem("November", 11);
	ddl_month.addItem("December", 12);

	ddl_year = cp5.addDropdownList("ddl_year")
		.setPosition(width - 125, 20)
		.setSize(80,120)
		.setCaptionLabel("Jaar");

	for(int i = 1950; i <= 2013; i++) {
		ddl_year.addItem(Integer.toString(i), i);
	}

	customize(ddl_day);
	customize(ddl_month);
	customize(ddl_year);

	cp5.addButton("btn_go")
		.setValue(0)
		.setPosition(width - 40, 4)
		.setSize(35,15)
		.setCaptionLabel("Go");

	gfx_options = cp5.addCheckBox("gfx_options")
		.setPosition(width - 170, height - 25)
		.setColorForeground(color(44, 62, 80))
		.setColorActive(color(46, 204, 113))
		.setColorLabel(color(0))
		.setSize(20, 20)
		.setItemsPerRow(2)
		.setSpacingColumn(60)
		.setSpacingRow(5)
		.addItem("Heatmap", 0)
		.addItem("Wind direction", 1);
}

public void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

public void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
		if (theEvent.isFrom(cp5.getGroup("ddl_day"))) {
			println("DAY PRESSED");
		} else if (theEvent.isFrom(cp5.getGroup("ddl_month"))) {
			println("MONTH PRESSED");
		} else if (theEvent.isFrom(cp5.getGroup("ddl_year"))) {
			println("YEAR PRESSED");
		}
  } else if (theEvent.isController()) {
		if(theEvent.isFrom(cp5.getController("btn_go"))) {
			if(cp5.getGroup("ddl_day").getValue() != 0.0f &&
				cp5.getGroup("ddl_month").getValue() != 0.0f &&
				cp5.getGroup("ddl_year").getValue() != 0.0f) {

				String date_d = String.valueOf((int)(cp5.getGroup("ddl_day").getValue()));
				if(date_d.length() < 2) date_d = "0" + date_d;

				String date_m = String.valueOf((int)(cp5.getGroup("ddl_month").getValue()));
				if(date_m.length() < 2) date_m = "0" + date_m;

				String date_y = String.valueOf((int)(cp5.getGroup("ddl_year").getValue()));

				String date = date_y + date_m + date_d;

				if(DEBUG) println("DEBUG: All values entered. Requesting data update for date: " + date);

				fillData(date);
			}
		}
  }
}

public void fillData(String date) {

	noLoop();

	subsetTemperatures.clear();
	subsetWindDirections.clear();

	if(DEBUG) println("DEBUG: Getting data for date " + date);

	for (WeatherStation ws : weatherStations.values()) {
		subsetTemperatures.put(ws.getId(), ws.getTemperature(date));
		subsetWindDirections.put(ws.getId(), ws.getWindDirection(date));
		subsetWindSpeeds.put(ws.getId(), ws.getWindSpeed(date));
	}

	this.t_min = Collections.min(subsetTemperatures.values());
	this.t_max = Collections.max(subsetTemperatures.values());

	loop();
}

public void drawHeatmap(int startX, int startY, int endX, int endY){

	for(int y = startY; y <= endY; y++)
	{
		for(int x = startX; x <= endX; x++)
		{
			PVector point = new PVector(x, y);

			Float[] multipliers = null;
			GeomTriangle geomTri = null;

			for(GeomTriangle gt : cityTriangles) {
				multipliers = gt.calcBarycentric(point);

				if(multipliers != null) {
					geomTri = gt;
					break;
				}
			}

			if(geomTri == null) continue;

			Float temperature = 0.0f;

			temperature += subsetTemperatures.get(geomTri.getFirstPoint().getId()) * multipliers[0];
			temperature += subsetTemperatures.get(geomTri.getSecondPoint().getId()) * multipliers[1];
			temperature += subsetTemperatures.get(geomTri.getThirdPoint().getId()) * multipliers[2];

			colorPixel(point, temperature);
		}
	}
}

public void drawWindDirections(int startX, int startY, int endX, int endY){

	for(int y = startY; y <= endY; y+=20)
	{
		for(int x = startX; x <= endX; x+=20)
		{
			PVector point = new PVector(x, y);

			Float[] multipliers = null;
			GeomTriangle geomTri = null;

			for(GeomTriangle gt : cityTriangles) {
				multipliers = gt.calcBarycentric(point);

				if(multipliers != null) {
					geomTri = gt;
					break;
				}
			}

			if(geomTri == null) continue;

			Float angle = 0.0f;

			angle += subsetWindDirections.get(geomTri.getFirstPoint().getId()) * multipliers[0];
			angle += subsetWindDirections.get(geomTri.getSecondPoint().getId()) * multipliers[1];
			angle += subsetWindDirections.get(geomTri.getThirdPoint().getId()) * multipliers[2];

			float speed = 0.0f;

			speed += subsetWindSpeeds.get(geomTri.getFirstPoint().getId()) * multipliers[0];
			speed += subsetWindSpeeds.get(geomTri.getSecondPoint().getId()) * multipliers[1];
			speed += subsetWindSpeeds.get(geomTri.getThirdPoint().getId()) * multipliers[2];

			float thickness = speed * 0.1f;
			strokeWeight(thickness);
			drawArrow(point, (int)(thickness * 2), angle - 90f); // Arrow is normally painted to the right
		}
	}
}

public void drawDebuggingTools() {
	strokeWeight(1);
	fill(0);

	line(0, mouseY, width, mouseY);
	line(mouseX, 0, mouseX, height);

	PVector point = new PVector(mouseX, mouseY);

	Float[] multipliers = null;
	GeomTriangle geomTri = null;

	for(GeomTriangle gt : cityTriangles) {
		multipliers = gt.calcBarycentric(point);

		if(multipliers != null) {
			geomTri = gt;
			break;
		}
	}

	if(geomTri == null) return;

	Float temperature = 0.0f;

	temperature += subsetTemperatures.get(geomTri.getFirstPoint().getId()) * multipliers[0];
	temperature += subsetTemperatures.get(geomTri.getSecondPoint().getId()) * multipliers[1];
	temperature += subsetTemperatures.get(geomTri.getThirdPoint().getId()) * multipliers[2];

	fill(0);
	textFont(f, 14);

	text("T1: " + subsetTemperatures.get(geomTri.getFirstPoint().getId()) + " naam: " + geomTri.getFirstPoint().getId(), 5, 14);
	text("T2: " + subsetTemperatures.get(geomTri.getSecondPoint().getId()) + " naam: " + geomTri.getSecondPoint().getId(), 5, 30);
	text("T3: " + subsetTemperatures.get(geomTri.getThirdPoint().getId()) + " naam: " + geomTri.getThirdPoint().getId(), 5, 46);
	text("Multiplier[0] " + multipliers[0], 5, 70);
	text("Multiplier[1] " + multipliers[1], 5, 86);
	text("Multiplier[2] " + multipliers[2], 5, 102);
	text("Temperature: " + temperature, 5, 126);

	float c = map(temperature, t_min, t_max, 64, 0);

	strokeWeight(0);
	colorMode(HSB, 360, 100, 100);
	fill(c, 100, 100);

	rect(mouseX - 10, mouseY - 10, 20, 20);

	colorMode(RGB,255); // Reset
}

public void colorPixel(PVector p, Float temperature){

	colorMode(HSB, 360, 100, 100);
	strokeWeight(0);

	// println(t_min);
	// println(t_max);
	float c = map(temperature, t_min, t_max, 64, 0);

	fill(c, 100, 100);

	rect(p.x, p.y, 1, 1);

	colorMode(RGB,255); // Reset
}

public void drawArrow(PVector p, int len, float angle){
  pushMatrix();
  translate(p.x, p.y);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len / 2, -(len / 2));
  line(len, 0, len / 2, len / 2);
  popMatrix();
}

class WeatherStation {

	private String id;
	private float lat, lng;
	private PVector canvasPosition;

	private Table data;

	public WeatherStation() {}

	public WeatherStation(String id, float[] coordinates) {
		this.id = id;
		this.setCoordinates(coordinates);
	}

	public void loadFile(String file) {
		this.data = loadTable(file, "csv,header");
		this.data.trim();
	}

	public void drawSelf() {
		strokeWeight(0);
		colorMode(RGB);
		fill(177);

		rect(canvasPosition.x - 5, canvasPosition.y - 5, 10, 10);
	}

	public PVector getCanvasLocation(float[] latlng){

		float x = map(latlng[1], rangeX_links, rangeX_rechts, 0, width);
		float y = map(latlng[0], rangeY_top, rangeY_bottom, 0, height);

		return new PVector(x, y);
	}

	public float getTemperature(String date) {
		TableRow row = this.data.findRow(date, "YYYYMMDD");
		return row.getFloat("   TX") * 0.1f;
	}

	public int getWindDirection(String date) {
		TableRow row = this.data.findRow(date, "YYYYMMDD");
		return row.getInt("DDVEC");
	}

	public int getWindSpeed(String date) {
		TableRow row = this.data.findRow(date, "YYYYMMDD");
		return row.getInt("   FG");
	}

	public String getId() { return this.id; }

	public double getLat() { return this.lat; }

	public double getLng() { return this.lng; }

	public PVector getCanvasPosition() { return this.canvasPosition; }

	public Table getData() { return this.data; }

	public void setId(String id) { this.id = id; }

	public void setCoordinates(float[] c) {
		this.lat = c[0];
		this.lng = c[1];

		this.canvasPosition = getCanvasLocation(c);
	}
}

class GeomTriangle {
	private WeatherStation ws1, ws2, ws3;

	public GeomTriangle(WeatherStation ws1, WeatherStation ws2, WeatherStation ws3) {
		this.ws1 = ws1;
		this.ws2 = ws2;
		this.ws3 = ws3;
	}

	public Float[] calcBarycentric(PVector p)
	{
		PVector a = this.ws1.getCanvasPosition();
		PVector b = this.ws2.getCanvasPosition();
		PVector c = this.ws3.getCanvasPosition();

		PVector v0 = b.get(); v0.sub(a); //b-a
		PVector v1 = c.get(); v1.sub(a); //c-a
		PVector v2 = p.get(); v2.sub(a); //p-a

		float d00 = v0.dot(v0); //v0.v0
		float d01 = v0.dot(v1); //v0.v1
		float d11 = v1.dot(v1); //v1.v1
		float d20 = v2.dot(v0); //v2.v0
		float d21 = v2.dot(v1); //v2.v1
		float denom = d00 * d11 - d01 * d01;

		float v = (d11 * d20 - d01 * d21) / denom;
		float w = (d00 * d21 - d01 * d20) / denom;
		float u = 1.0f - v - w;

		if(v >= 0 && w >= 0 && u >= 0)
			return new Float[] {u,v,w};

		return null;
	}

	public WeatherStation[] getWeatherStations() {
		return new WeatherStation[] {this.ws1, this.ws2, this.ws3};
	}

	public WeatherStation getFirstPoint() { return this.ws1; }
	public WeatherStation getSecondPoint() { return this.ws2; }
	public WeatherStation getThirdPoint() { return this.ws3; }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Opdracht_EO_3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
