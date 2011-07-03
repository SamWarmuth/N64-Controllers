import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.InputEvent;

Serial N64Connection;
String buttons;
Robot VKey;
PImage bg;
String[] pressed;

int[][] keyMaps;
boolean[][] keyStates;

void setup() 
{
  // bits: A,   B,     Z,     Start,
  //       Dup, Ddown, Dleft, Dright
  //       0,   0,     L,     R,
  //       Cup, Cdown, Cleft, Cright
  
  keyMaps = new int[4][18];
  int[] player1keys = {KeyEvent.VK_A, KeyEvent.VK_B, KeyEvent.VK_C, KeyEvent.VK_D,
                       KeyEvent.VK_E, KeyEvent.VK_F, KeyEvent.VK_G, KeyEvent.VK_H,
                       KeyEvent.VK_I, KeyEvent.VK_J, KeyEvent.VK_K, KeyEvent.VK_L,
                       KeyEvent.VK_M, KeyEvent.VK_N, KeyEvent.VK_O, KeyEvent.VK_P};
  keyMaps[0] = player1keys;
  int[] player2keys = {1,2,3};
  keyMaps[1] = player2keys;
  int[] player3keys = {1,2,3};
  keyMaps[2] = player3keys;
  int[] player4keys = {1,2,3};
  keyMaps[3] = player4keys;
  
  
  keyStates = new boolean[4][18];
  // Initialize 2D array values
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 18; j++) {
      keyStates[i][j] = false;
    }
  }
  
  
  pressed = split("a", ' ');;
  size(540,300);
  frameRate(1);
  String portName = Serial.list()[1];
  N64Connection = new Serial(this, portName, 115200);
  try {
    VKey = new Robot();
  }
  catch(AWTException a){}
  N64Connection.bufferUntil('\n');
  buttons = "";
  bg = loadImage("N64 Controller.jpg");
}

void draw()
{
  background(bg);
  fill(0, 0, 0);
  text(" "+KeyEvent.VK_UP, 20, 10);
}

void serialEvent(Serial N64Connection)
{
  //need the try block, because sometimes you only
  //catch half a string and everything crashes.
  try{
  
  buttons = N64Connection.readString();
  pressed = split(buttons, ' ');
  
  int player = Integer.parseInt(pressed[0]);
  int i;
  boolean value;

  //iterate through buttons
  for (i=0; i<16; i++){
    value = (pressed[1].charAt(i) == '1' ? true : false);
    if (value != keyStates[player][i]){
      if (value == true) VKey.keyPress(keyMaps[player][i]);
      else VKey.keyRelease(keyMaps[player][i]);
      keyStates[player][i] = value;
    }
  }
  }catch(Exception e){
    println("error.");
  }
}
