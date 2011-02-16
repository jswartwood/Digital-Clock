/*
 * Digital Clock
 *
 * Copyright (c) 2011 Jacob Swartwood
 */

boolean DEBUG_MODE = true;

int ELEMENT[7] = { 2, 3, 4, 5, 6, 7, 8 };

int DIGIT[4] = { A5, A4, A3, A2 };

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
	{ LOW, LOW, LOW, HIGH, HIGH, LOW, LOW }
};

int PM = A1;
int ALARM_R = 9;
int ALARM_G = 10;
int ALARM_B = 11;

unsigned long HRS_24 = 86400;
unsigned int ALARM_TIMER = 3600;

long offset = 0;
long alarm = -1;

unsigned long start_time = millis();
unsigned long time = millis();

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

	pinMode(ALARM_R, OUTPUT);
	pinMode(ALARM_G, OUTPUT);
	pinMode(ALARM_B, OUTPUT);
	
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
		char set_what = Serial.read();
		long d1 = long(Serial.read() - 48);
		long d2 = long(Serial.read() - 48);
		long d3 = long(Serial.read() - 48);
		long d4 = long(Serial.read() - 48);
		Serial.flush();
		
		if ((d1 >= 0) && (d2 >= 0) && (d3 >= 0) && (d4 >= 0)) {
			unsigned long set_time = (d1 * 10 + d2) * 3600;
			set_time += (d3 * 10 + d4) * 60;
			
			switch (set_what) {
				case 'a':
				case 'A':
					alarm = set_time;
				
					if (DEBUG_MODE) {
						Serial.print("Setting alarm: ");
						Serial.print(d1);
						Serial.print(d2);
						Serial.print(":");
						Serial.print(d3);
						Serial.println(d4);
					}
					break;
				case 't':
				case 'T':
					offset = set_time - time;
				
					if (DEBUG_MODE) {
						Serial.print("Setting time: ");
						Serial.print(d1);
						Serial.print(d2);
						Serial.print(":");
						Serial.print(d3);
						Serial.println(d4);
					}
					break;
			}
		}
	}
	
	time += offset;
	time %= HRS_24;
	
	seconds = time % 60;
	hours = time / 3600;
	minutes = (time / 60) % 60;
	
	pm = (hours / 12) == 1;
	hours %= 12;
	if (hours == 0) {
		hours = 12;
	}
	
	writeDigit(0, hours / 10);
	writeDigit(1, hours % 10);
	writeDigit(2, minutes / 10);
	writeDigit(3, minutes % 10);
	digitalWrite(PM, pm ? HIGH : LOW);
	
	if ((alarm > 0) && (time >= alarm) && (time < (alarm + ALARM_TIMER))) {
		int alarm_bright = (time - alarm) * 256 / ALARM_TIMER;
		analogWrite(ALARM_R, alarm_bright);
		analogWrite(ALARM_G, alarm_bright / 3);
		analogWrite(ALARM_B, alarm_bright / 8);
		
		if (DEBUG_MODE && (seconds != last_seconds)) {
			Serial.print("Brightness: ");
			Serial.println(alarm_bright);
		}
	} else {
		analogWrite(ALARM_R, 0);
		analogWrite(ALARM_G, 0);
		analogWrite(ALARM_B, 0);
	}
	
	if (seconds != last_seconds) {
		last_seconds = seconds;
		
		if (DEBUG_MODE) {
			Serial.print(hours);
			Serial.print(":");
			Serial.print(minutes);
			Serial.print(":");
			Serial.print(seconds);
			Serial.println(pm ? " pm" : " am");
		}
	}
}
