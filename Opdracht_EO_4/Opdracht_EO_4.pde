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

import controlP5.*;
import java.util.Map.Entry;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.Calendar;
import java.text.SimpleDateFormat;

private final boolean DEBUG = true;

/* Everything controls */
ControlP5 cp5;
CheckBox startstop;

PShape map;

PFont f;

/* Holds the weather stations */
HashMap<String, WeatherStation> weatherStations = new HashMap<String, WeatherStation>();

/* Holds the triangle combinations for Barycentric coordinates */
ArrayList<GeomTriangle> cityTriangles = new ArrayList<GeomTriangle>();

/* Data subsets */
// HashMap<String, HashMap<Integer, Integer>> subsetTemperatures = new HashMap<String, HashMap<Integer, Integer>>();
HashMap<String, LinkedHashMap<String, Integer>> subsetWindDirections = new HashMap<String, LinkedHashMap<String, Integer>>();
HashMap<String, LinkedHashMap<String, Integer>> subsetWindSpeeds = new HashMap<String, LinkedHashMap<String, Integer>>();

/* Map limits */
Float rangeX_links = 3.8949308638000346;
Float rangeX_rechts = 5.816164994659482;
Float rangeY_top = 52.456971340027025;
Float rangeY_bottom = 51.499467276808595;

Calendar currentTimestamp;
String timestamp_human = "";

int savedTime;
int totalTime = 200;

void setup() {

	size(1000, 700);
	background(255);
	// noLoop();
	frameRate(30);
	smooth(); // Anti-aliasing

	cp5 = new ControlP5(this);
	makeControls();

	f = createFont("Arial",16,true);

	map = loadShape("mapnl2.svg");

	/* Add weather stations */
	WeatherStation s;

	s = new WeatherStation();
	s.setId("valkenburg");
	s.setCoordinates(new float[] { 52.17929960836679, 4.428261304321164 });
	s.loadFile(dataPath("uurgeg_210_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("schiphol");
	s.setCoordinates(new float[] { 52.30751851387325, 4.748323941650282 });
	s.loadFile(dataPath("uurgeg_240_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("debilt");
	s.setCoordinates(new float[] { 52.10930658771594, 5.179022336425739 });
	s.loadFile(dataPath("uurgeg_260_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("hoekvanholland");
	s.setCoordinates(new float[] { 51.97716935731944, 4.131201291503972 });
	s.loadFile(dataPath("uurgeg_330_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("rotterdam");
	s.setCoordinates(new float[] { 51.91346086265449, 4.4680009130859135 });
	s.loadFile(dataPath("uurgeg_344_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("cabauw");
	s.setCoordinates(new float[] { 51.96480938497381, 4.897626424255222 });
	s.loadFile(dataPath("uurgeg_348_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

	s = new WeatherStation();
	s.setId("herwijnen");
	s.setCoordinates(new float[] { 51.827245407946165, 5.129927182617317 });
	s.loadFile(dataPath("uurgeg_356_2001-2010.txt"));
	weatherStations.put(s.getId(), s);

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

	fillData();

	currentTimestamp = Calendar.getInstance();
	currentTimestamp.set(2001, 0, 1, 1, 0);
}

void draw() {

	/* Draw the full map first */
	shape(map, -300, -800, 2050, 2050);

	int passedTime = millis() - savedTime;
  // Has five seconds passed?
  if (passedTime > totalTime) {
  	if(startstop.getArrayValue()[0] != 0.0f) {
  		currentTimestamp.add(Calendar.HOUR, 1);

  		SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy - kk:mm");
			this.timestamp_human = format.format(currentTimestamp.getTime());
  	}
		savedTime = millis();
  }

	drawWind(105, 100, 680, 475);

	drawTimestamp();

	/* Draw the heatmap */
	// if(gfx_options.getArrayValue()[0] != 0.0f)
		// drawHeatmap(105, 100, 680, 475);


	/* Draw a small rectangle for each weather station */
	for (WeatherStation ws : weatherStations.values())
		ws.drawSelf();
}

void fillData() {

	// subsetTemperatures.clear();
	subsetWindDirections.clear();
	subsetWindSpeeds.clear();

	for (WeatherStation ws : weatherStations.values()) {
		// subsetTemperatures.put(ws.getId(), ws.getTemperature());
		subsetWindDirections.put(ws.getId(), ws.getWindDirections());
		subsetWindSpeeds.put(ws.getId(), ws.getWindSpeeds());
	}
}

void makeControls() {
	startstop = cp5.addCheckBox("startstop")
		.setPosition(width - 100, 10)
		.setSize(20, 20)
		.setColorForeground(color(44, 62, 80))
		.setColorActive(color(46, 204, 113))
		.setColorLabel(color(0))
		.setItemsPerRow(1)
		.setSpacingColumn(30)
		.setSpacingRow(5)
		.addItem("Play/Pauze", 0);
}

// void drawHeatmap(int startX, int startY, int endX, int endY){

// 	for(int i = startY; i <= endY; i++)
// 	{
// 		for(int j = startX; j <= endX; j++)
// 		{
// 			PVector point = new PVector(j, i);

// 			Float[] multipliers = null;
// 			GeomTriangle geomTri = null;

// 			for(GeomTriangle gt : cityTriangles) {
// 				multipliers = gt.calcBarycentric(point);

// 				if(multipliers != null) {
// 					geomTri = gt;
// 					break;
// 				}
// 			}

// 			if(geomTri == null) continue;

// 			Float temperature = 0.0f;

// 			temperature += subsetTemperatures.get(geomTri.getFirstPoint().getId()) * multipliers[0];
// 			temperature += subsetTemperatures.get(geomTri.getSecondPoint().getId()) * multipliers[1];
// 			temperature += subsetTemperatures.get(geomTri.getThirdPoint().getId()) * multipliers[2];

// 			colorPixel(point, temperature);
// 		}
// 	}
// }

void drawWind(int startX, int startY, int endX, int endY){

	SimpleDateFormat format = new SimpleDateFormat("yyyyMMddk");

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

			String usableTimestamp = format.format(currentTimestamp.getTime());

			if( ! (subsetWindDirections.get(geomTri.getFirstPoint().getId()).containsKey(usableTimestamp) &&
						 subsetWindDirections.get(geomTri.getSecondPoint().getId()).containsKey(usableTimestamp) &&
						 subsetWindDirections.get(geomTri.getThirdPoint().getId()).containsKey(usableTimestamp)))
			{ continue; }

			if( ! (subsetWindSpeeds.get(geomTri.getFirstPoint().getId()).containsKey(usableTimestamp) &&
						 subsetWindSpeeds.get(geomTri.getSecondPoint().getId()).containsKey(usableTimestamp) &&
						 subsetWindSpeeds.get(geomTri.getThirdPoint().getId()).containsKey(usableTimestamp)))
			{ continue; }

			Float angle = 0.0f;

			angle += subsetWindDirections.get(geomTri.getFirstPoint().getId()).get(usableTimestamp) * multipliers[0];
			angle += subsetWindDirections.get(geomTri.getSecondPoint().getId()).get(usableTimestamp) * multipliers[1];
			angle += subsetWindDirections.get(geomTri.getThirdPoint().getId()).get(usableTimestamp) * multipliers[2];

			float speed = 0.0f;

			speed += subsetWindSpeeds.get(geomTri.getFirstPoint().getId()).get(usableTimestamp) * multipliers[0];
			speed += subsetWindSpeeds.get(geomTri.getSecondPoint().getId()).get(usableTimestamp) * multipliers[1];
			speed += subsetWindSpeeds.get(geomTri.getThirdPoint().getId()).get(usableTimestamp) * multipliers[2];

			float thickness = speed * 0.1f;
			strokeWeight(thickness);
			drawArrow(point, (int)(thickness * 2), angle - 90f); // Arrow is normally painted to the right
		}
	}
}

void colorPixel(PVector p, Float temperature){

	colorMode(HSB, 100);
	strokeWeight(0);

	fill(temperature, 100, 100);

	rect(p.x, p.y, 1, 1);

	colorMode(RGB,255); // Reset
}

void drawArrow(PVector p, int len, float angle){
  pushMatrix();
  translate(p.x, p.y);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len / 2, -(len / 2));
  line(len, 0, len / 2, len / 2);
  popMatrix();
}

void drawTimestamp() {
	textFont(f,32);
	textAlign(RIGHT);
  fill(0);
  text(timestamp_human, width - 10, height - 10);
}

class WeatherStation {

	private String id;
	private float lat, lng;
	private PVector canvasPosition;

	private Table data;

	LinkedHashMap<String, Integer> subsetWindDirections;
	LinkedHashMap<String, Integer> subsetWindSpeeds;

	public WeatherStation() {
		subsetWindDirections = new LinkedHashMap<String, Integer>();
		subsetWindSpeeds = new LinkedHashMap<String, Integer>();
	}

	public WeatherStation(String id, float[] coordinates) {
		this.id = id;
		this.setCoordinates(coordinates);
	}

	void loadFile(String file) {
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

				String id = split[1].trim() + split[2].trim();

				subsetWindDirections.put(id, Integer.valueOf(split[3].trim()));
				subsetWindSpeeds.put(id, Integer.valueOf(split[4].trim()));
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

	void drawSelf() {
		strokeWeight(0);
		colorMode(RGB);
		fill(177);

		rect(canvasPosition.x - 5, canvasPosition.y - 5, 10, 10);
	}

	PVector getCanvasLocation(float[] latlng){

		float x = map(latlng[1], rangeX_links, rangeX_rechts, 0, width);
		float y = map(latlng[0], rangeY_top, rangeY_bottom, 0, height);

		return new PVector(x, y);
	}

	// HashMap<Integer, Float> getTemperature() {
	// 	HashMap<Integer, Float> subsetD = new HashMap<Integer, Integer>();

	// 	for (TableRow row : this.data.rows()) {
	// 		subsetD.put(row.getInt("YYYYMMDD"), row.getFloat("   DD"));
	// 	}

	// 	return subsetD;
	// }

	public LinkedHashMap<String, Integer> getWindDirections() {
		return this.subsetWindDirections;
	}

	public LinkedHashMap<String, Integer> getWindSpeeds() {
		return this.subsetWindSpeeds;
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
