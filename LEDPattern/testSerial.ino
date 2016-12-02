
#include "FastLED.h"
#define NUM_STRIPS 1
#define NUM_LEDS_PER_STRIP 60
CRGB leds[NUM_STRIPS][NUM_LEDS_PER_STRIP];

int val = 0;
int cutoffIndex = 0;
int prevCutoffIndex = 0;

void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
  FastLED.addLeds<NEOPIXEL, 10>(leds[0], NUM_LEDS_PER_STRIP);  
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  Serial.write(1);
}

void loop() { 
  if (Serial.available()) {
    val = Serial.read();
    prevCutoffIndex = cutoffIndex;
    cutoffIndex = 60 - 600.0/val; //obtained from the formula (60-i)/60 * val < 10
    if (cutoffIndex > 59) cutoffIndex = 59; //prevent index out of range
    if (cutoffIndex < 0) cutoffIndex = 0;
  }

  if (cutoffIndex > prevCutoffIndex) { //grow right
      for(int i = prevCutoffIndex+1; i <= cutoffIndex; i++) {
        leds[0][i] = CRGB(255,0,0);
    }
    
  } else { //shrink left
     for(int i = prevCutoffIndex; i > cutoffIndex; i--) {
        leds[0][i] = CRGB::Black;
     }
  }
  FastLED.show();

  /************************************* EXPLOSIVE BEAT DETECTION 
    if (Serial.available()) {
    val = Serial.read();
  }

    for(int i = 0; i < NUM_LEDS_PER_STRIP; i++) {
      color = (60-i)/60.0 * val * 2;
      leds[0][i] = CRGB(color,0,0);
    }
    FastLED.show();


    for(int i = NUM_LEDS_PER_STRIP; i >= 0 ; i--) {
      leds[0][i] = CRGB::Black;
    }
              FastLED.show();
   *********************************************************/
}

