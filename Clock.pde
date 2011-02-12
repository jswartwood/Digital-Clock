/*
 * Digital Clock
 *
 * Copyright (c) 2011 Jacob Swartwood
 */

int ELEMENT[7] = { 2, 3, 4, 5, 6, 7, 8 };

int DIGIT[4] = { 10, 11, 12, 13 };

int NUM[10][7] = {
	{ LOW, LOW, LOW, LOW, LOW, LOW, HIGH },
	{ HIGH, LOW, LOW, HIGH, HIGH, HIGH, HIGH },
	{ LOW, LOW, HIGH, LOW, LOW, HIGH, LOW },
	{ LOW, LOW, LOW, LOW, HIGH, HIGH, LOW },
	{ HIGH, LOW, LOW, HIGH, HIGH, LOW, LOW },
	{ LOW, HIGH, LOW, LOW, HIGH, LOW, LOW },
	{ LOW, HIGH, LOW, LOW, LOW, LOW, LOW },
	{ LOW, LOW, LOW, HIGH, HIGH, HIGH, HIGH },
	{ LOW, LOW, LOW, LOW, LOW, LOW, LOW },
	{ LOW, LOW, LOW, HIGH, HIGH, LOW, LOW },
};

int PM = 9;

unsigned long set_time = 0;
long offset = 0;

unsigned long start_time = millis();
unsigned long time = millis();
unsigned long HRS_24 = 86400;

int hours;
int minutes;
long seconds;
boolean pm;
long last_seconds = -1;

void setup() {
	for (int i = 0; i < 7; i++) {
		pinMode(ELEMENT[i], OUTPUT);
	}
	
	for (int i = 0; i < 4; i++) {
		pinMode(DIGIT[i], OUTPUT);
	}
	
	pinMode(PM, OUTPUT);
	
	Serial.begin(9600);
}

void writeDigit( int d, int n ) {
	d = d % 4;
	n = n % 10;
	
	for (int i = 0; i < 7; i++) {
		digitalWrite(ELEMENT[i], (n < 0 ? HIGH : NUM[n][i]));
	}

	for (int i = 0; i < 4; i++) {
		digitalWrite(DIGIT[i], (i == d ? HIGH : LOW));
	}
	
	delay(5);
}

void loop() {
	time = (millis() - start_time) / 1000;
	time %= HRS_24;
	
	if (Serial.available() > 0) {
		long d1 = long(Serial.read() - 48);
		long d2 = long(Serial.read() - 48);
		long d3 = long(Serial.read() - 48);
		long d4 = long(Serial.read() - 48);
		
		set_time = (d1 * 10 + d2) * 3600;
		set_time += (d3 * 10 + d4) * 60;
		Serial.flush();
		
		offset = set_time - time;
	}
	
	time += offset;
	seconds = time % 60;
	hours = time / 3600;
	minutes = (time / 60) % 60;
	
	pm = (hours / 12) == 1;
	hours %= 12;
	if (hours == 0) {
		hours = 12;
	}
	
	if (seconds != last_seconds) {
		last_seconds = seconds;
		Serial.print(hours);
		Serial.print(":");
		Serial.print(minutes);
		Serial.print(":");
		Serial.print(seconds);
		Serial.println(pm ? " pm" : " am");
	}
	
	writeDigit(0, hours / 10);
	writeDigit(1, hours % 10);
	writeDigit(2, minutes / 10);
	writeDigit(3, minutes % 10);
	digitalWrite(PM, pm ? HIGH : LOW);
}
