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
  // bits: A,     B,      Z,     Start,
  //       Dup,   Ddown,  Dleft, Dright
  //       0,     0,      L,     R,
  //       Cup,   Cdown,  Cleft, Cright
  //       sLeft, sRight, sUp,   sDown

  keyMaps = new int[4][18];
  int[] player1keys = {
    KeyEvent.VK_A, KeyEvent.VK_B, KeyEvent.VK_C, KeyEvent.VK_D,
    KeyEvent.VK_E, KeyEvent.VK_F, KeyEvent.VK_G, KeyEvent.VK_H,
    0,             0,             KeyEvent.VK_I, KeyEvent.VK_J,
    KeyEvent.VK_K, KeyEvent.VK_L, KeyEvent.VK_M, KeyEvent.VK_N, 
    KeyEvent.VK_O, KeyEvent.VK_P, KeyEvent.VK_Q, KeyEvent.VK_R
  };
  keyMaps[0] = player1keys;
  int[] player2keys = {
    KeyEvent.VK_S, KeyEvent.VK_T, KeyEvent.VK_U, KeyEvent.VK_V,
    KeyEvent.VK_W, KeyEvent.VK_X, KeyEvent.VK_Y, KeyEvent.VK_Z,
    0,             0,             KeyEvent.VK_1, KeyEvent.VK_2,
    KeyEvent.VK_SEMICOLON, KeyEvent.VK_SHIFT, KeyEvent.VK_SUBTRACT, KeyEvent.VK_TAB,
    KeyEvent.VK_PAGE_UP, KeyEvent.VK_PERIOD, KeyEvent.VK_QUOTE, KeyEvent.VK_SCROLL_LOCK
  };
  keyMaps[1] = player2keys;
  int[] player3keys = {
    KeyEvent.VK_BACK_QUOTE, KeyEvent.VK_OPEN_BRACKET, KeyEvent.VK_CLOSE_BRACKET, KeyEvent.VK_BACK_SLASH,
    KeyEvent.VK_COMMA, KeyEvent.VK_CONTROL, KeyEvent.VK_CAPS_LOCK, KeyEvent.VK_DELETE,
    0,             0,             KeyEvent.VK_ENTER, KeyEvent.VK_EQUALS,
    KeyEvent.VK_DECIMAL, KeyEvent.VK_HOME, KeyEvent.VK_HELP, KeyEvent.VK_PAGE_DOWN,
    KeyEvent.VK_LEFT, KeyEvent.VK_RIGHT, KeyEvent.VK_UP, KeyEvent.VK_DOWN
  };
  keyMaps[2] = player3keys;
  int[] player4keys = {
    KeyEvent.VK_F1, KeyEvent.VK_F2, KeyEvent.VK_F3, KeyEvent.VK_F4,
    KeyEvent.VK_F5, KeyEvent.VK_F6, KeyEvent.VK_F7, KeyEvent.VK_F8,
    0,             0,             KeyEvent.VK_NUMPAD1, KeyEvent.VK_NUMPAD2,
    KeyEvent.VK_NUMPAD3, KeyEvent.VK_NUMPAD4, KeyEvent.VK_NUMPAD5, KeyEvent.VK_NUMPAD6,
    KeyEvent.VK_NUMPAD7, KeyEvent.VK_NUMPAD8, KeyEvent.VK_NUMPAD9, KeyEvent.VK_NUMPAD0
  };
  keyMaps[3] = player4keys;


  keyStates = new boolean[4][20];
  // Initialize 2D array values, you need 2
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 18; j++) {
      keyStates[i][j] = false;
    }
  }


  pressed = split("a", ' ');
  ;
  size(540,300);
  frameRate(1);
  String portName = Serial.list()[1];
  N64Connection = new Serial(this, portName, 115200);
  try {
    VKey = new Robot();
  }
  catch(AWTException a) {
  }
  N64Connection.bufferUntil('\n');
  buttons = "Hell0 m0t0";
  bg = loadImage("N64 Controller.jpg");
}

void draw()
{
  background(bg);
  fill(0, 0, 0);
  text(" "+KeyEvent.VK_UP, 20, 10);
}


int player;
int i, stickX, stickY;
boolean value;

int left = 16;
int right = 17;
int up = 18;
int down = 19;

void serialEvent(Serial N64Connection)
{
  //need the try block, because sometimes you only
  //catch half a string and everything crashes.
  try {
    buttons = N64Connection.readString();
    pressed = split(buttons, ' ');

    player = Integer.parseInt(pressed[0]);

    //bail if player number is too high.
    if (player > 3) return;
    //iterate through buttons
    for (i=0; i<16; i++) {
      value = (pressed[1].charAt(i) == '1' ? true : false);
      if (value != keyStates[player][i]) {
        if (value == true) VKey.keyPress(keyMaps[player][i]);
        else VKey.keyRelease(keyMaps[player][i]);
        keyStates[player][i] = value;
      }
    }

    //stick
    stickX = Integer.parseInt(pressed[2]);
    stickY = Integer.parseInt(pressed[3]);
    if ((stickX > 40) != keyStates[player][right]) {
      if (keyStates[player][right]) VKey.keyRelease(keyMaps[player][right]);
      else VKey.keyPress(keyMaps[player][right]);
      keyStates[player][right] = !keyStates[player][right];
    }
    if ((stickX < -40) != keyStates[player][left]) {
      if (keyStates[player][left]) VKey.keyRelease(keyMaps[player][left]);
      else VKey.keyPress(keyMaps[player][left]);
      keyStates[player][left] = !keyStates[player][left];
    }
    if ((stickY > 40) != keyStates[player][up]) {
      if (keyStates[player][up]) VKey.keyRelease(keyMaps[player][up]);
      else VKey.keyPress(keyMaps[player][up]);
      keyStates[player][up] = !keyStates[player][up];
    }
    if ((stickY < -40) != keyStates[player][down]) {
      if (keyStates[player][down]) VKey.keyRelease(keyMaps[player][down]);
      else VKey.keyPress(keyMaps[player][down]);
      keyStates[player][down] = !keyStates[player][down];
    }
  }
  catch(Exception e) {
    //haha. strange. Can't print an error, or it breaks everything.
  }
}

