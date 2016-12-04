// ArrayOfLedArrays - see https://github.com/FastLED/FastLED/wiki/Multiple-Controller-Examples for more info on
// using multiple controllers.  In this example, we're going to set up four NEOPIXEL strips on three
// different pins, each strip getting its own CRGB array to be played with, only this time they're going
// to be all parts of an array of arrays.

//Kezia Jenissa
//U1420126E
//PIANO MODE CODE
//This code is modified to control the LED based on the input from processing piano interface (Denny)
//using serial to detect the input and if condition to turn on LED part

#include "FastLED.h"

#define NUM_STRIPS 2
#define NUM_LEDS_PER_STRIP 120
CRGB leds[NUM_STRIPS][NUM_LEDS_PER_STRIP];
char val;

// For mirroring strips, all the "special" stuff happens just in setup.  We
// just addLeds multiple times, once for each strip
void setup() {

  // tell FastLED there's 120 NEOPIXEL leds on pin 5
  FastLED.addLeds<NEOPIXEL, 5>(leds[0], NUM_LEDS_PER_STRIP);

  // tell FastLED there's 120 NEOPIXEL leds on pin 6
  FastLED.addLeds<NEOPIXEL, 6>(leds[1], NUM_LEDS_PER_STRIP);
  Serial.begin(9600);
  while (!Serial) {
      ; // wait for serial port to connect. Needed for native USB port only
    }
    Serial.write(1);
}

void loop() { 

  if (Serial.available()) {//if data is available to read
    val=Serial.read(); //read and store in val
  }
//Code for the single node
  if(val=='s'){
  for(int i=0;i<15;i++){
        leds[0][i] = CRGB::Red;
        leds[1][i]= CRGB::Red;
        }
  }
    FastLED.show();
  if(val=='d'){
  for(int i=0;i<30;i++){
        leds[0][i] = CRGB::Orange;
        leds[1][i]= CRGB::Orange;
        }
  }
    FastLED.show();
  if(val=='f'){
  for(int i=0;i<45;i++){
        leds[0][i] = CRGB::Yellow;
        leds[1][i]= CRGB::Yellow;
        }
  }
    FastLED.show();
  if(val=='g'){
  for(int i=0;i<60;i++){
        leds[0][i] = CRGB::Green;
        leds[1][i]= CRGB::Green;
        }
  }
    FastLED.show();
  if(val=='h'){
  for(int i=0;i<75;i++){
        leds[0][i] = CRGB::Blue;
        leds[1][i]= CRGB::Blue;
        }
  }

  if(val=='j'){
  for(int i=0;i<90;i++){
        leds[0][i] = CRGB::Magenta;
        leds[1][i]= CRGB::Magenta;
        }
  }

   if(val=='k'){
  for(int i=0;i<105;i++){
        leds[0][i] = CRGB::Purple;
        leds[1][i]= CRGB::Purple;
        }
  }

  if(val=='l'){
  for(int i=0;i<30;i++){
        leds[0][i] = CRGB::Red;
        leds[1][i]= CRGB::Red;
        }
  }
     FastLED.show();
}
