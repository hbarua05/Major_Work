float startButtonWidth = 200, startButtonHeight = 50; //<>//

int currentLevel;
boolean startButtonClicked;
boolean gameWon;
boolean gameOver;

float playerWidth;
float playerHeight;
float pixelsToMove;
PVector playerCenter;

int[] numMoonsInLevel;
PVector[] moonsCenterLocations;
boolean[] moonsHitPreviously;
float moonSpeed;

int numStars;
PVector[] starsPosition;
float[] starsDistance;
float starsSpeed;

PVector missileLocation;
float missileSpeed;
boolean missileShot;

int points;

/*
  Driver code
 */
void setup() {
  size(500, 500);

  startButtonClicked = false;
  points = 0;

  currentLevel = 0;
  gameWon = false;
  gameOver = false;

  playerCenter = new PVector(50, 50);
  playerWidth = 40;
  playerHeight = 40;
  pixelsToMove = 5;

  numMoonsInLevel = new int[] {3, 4, 6};
  moonsCenterLocations = new PVector[6];
  moonsHitPreviously = new boolean[6];
  moonSpeed = 0.1;
  initializeMoons();

  numStars = 150;
  starsSpeed = 10;
  starsPosition = new PVector[numStars];
  starsDistance = new float[numStars];
  initializeStars();

  missileShot = false;
  missileSpeed = 2;
}

void draw() {
  background(#050608);

  if (startButtonClicked && !gameOver) {
    showPoints();
  }

  animateStars();
  
  if (!startButtonClicked) {
    drawStartButton();
  }

  if (startButtonClicked && !gameOver) {
    drawMissile();
    drawPlayer(playerCenter.x, playerCenter.y);
    drawMoons();

    if (allMoonsInCurrentLevelHit()) {
      levelUp();
    }

    if (anyMoonHitShipOrEdge()) {
      gameWon = false;
      gameOver = true;
    }
  } else if (gameOver) {
    if (gameWon) {
      displayEndScreen("You Won!!");
    } else {
      displayEndScreen("You Lost :(");
    }
  }
}

void keyPressed() {
  if (startButtonClicked) {
    movePlayer(key);

    if (key == ' ' && !missileShot) {
      initializeMissile();
    }
  }
}

void mouseReleased() {
  if (!startButtonClicked) {
    boolean mouseXInButton = dist(mouseX, 0, width/2, 0) < startButtonWidth/2;
    boolean mouseYInButton = dist(0, mouseY, 0, height/2) < startButtonHeight/2;

    startButtonClicked = mouseXInButton && mouseYInButton;
  }
}

/* 
  Utility functions for the start and end of game
*/
void startGame() {
  startButtonClicked = true;
}

void drawStartButton() {
  boolean mouseXInButton = dist(mouseX, 0, width/2, 0) < startButtonWidth/2;
  boolean mouseYInButton = dist(0, mouseY, 0, height/2) < startButtonHeight/2;

  // Setting the fill and stroke of button based on hover
  if (mouseXInButton && mouseYInButton) {
    strokeWeight(2);
    fill(255);
  } else {
    strokeWeight(2);
    stroke(255);
    fill(0, 0, 0, 200);
  }

  // The button rect
  rectMode(CENTER);
  rect(width/2, height/2, startButtonWidth, startButtonHeight, 5);


  // The text in button
  textSize(30);
  textAlign(CENTER, CENTER);

  // Setting the text color of button based on hover
  strokeWeight(5);
  if (mouseXInButton && mouseYInButton) {
    fill(0);
  } else {
    fill(255);
  }

  text("Start Game", width/2, height/2 - 3);
}

void displayEndScreen(String result) {
    textSize(120);
    textAlign(CENTER);
    fill(255);
    text(result, width/2, height/2);
}

/*
  Utility functions for the levels
*/

void levelUp() {
  if (currentLevel < 2) {
    currentLevel++;
    moonSpeed *= 2;
    initializeMoons();
  } else {
    gameWon = true;
    gameOver = true;
  }
}

/*
  Utility functions for points
*/

void showPoints() {
  textSize(300);
  textAlign(CENTER);
  fill(25);
  text(points, width/2, 320);
}

/*
  Utility functions for the player
*/

void drawPlayer(float x, float y) {
  noStroke();
  fill(255);

  PVector p1 = new PVector(x - playerWidth/2, y - playerHeight/2);
  PVector p2 = new PVector(x - playerWidth/2, y + playerHeight/2);
  PVector p3 = new PVector(x + playerWidth/2, y);
  // Moving up
  if (keyPressed && key == 'w') {
    p3.y = y - playerHeight/4;
  }
  // Moving down
  else if (keyPressed && key == 's') {
    p3.y = y + playerHeight/4;
   }
  triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
}

void movePlayer(char keyName) {
  float topY = playerCenter.y - playerHeight/2;
  float bottomY=  playerCenter.y + playerHeight/2;

  // Moving up
  if (keyName == 'w' && bottomY - pixelsToMove >= playerHeight/2) {
    playerCenter.y -= pixelsToMove;
  }
  // Moving down
  else if (keyName == 's' && topY + pixelsToMove <= height - playerHeight/2) {
    playerCenter.y += pixelsToMove;
  }
}

/*
  Utility functions for the moon
*/

void initializeMoons() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    moonsCenterLocations[i] = new PVector(random(width*4/6, width), random(0, height));
    moonsHitPreviously[i] = false;
  }
}

void drawMoon(float x, float y) {
  // The moon itself
  strokeWeight(2);
  stroke(#31190A);
  fill(#5f4e43);
  circle(x, y, width/4);

  // The craters on the moon
  fill(#342A24);
  strokeWeight(0);
  circle(x + 10, y + 10, 30);
  circle(x - 45, y + 20, 20);
  circle(x + 50, y - 20, 10);
  circle(x - 20, y - 30, 15);
  circle(x + 10, y + 50, 5);
}

void drawMoons() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    PVector currentMoonLocation = moonsCenterLocations[i];
    
    // check if the missile has hit the moon
    if (missileHitMoon(missileLocation, i)) {
      moonsHitPreviously[i] = true;
      points++;
      resetMissile();
    }

    // check if the moon hasnt been hit moon previusly
    // only then draw the moon
    if (!missileHitMoon(missileLocation, i) && !moonsHitPreviously[i]) {
      drawMoon(currentMoonLocation.x, currentMoonLocation.y);
    }

  }

  moveMoons();
}


void moveMoons() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    if (!moonsHitPreviously[i]) {
      moonsCenterLocations[i].x -= moonSpeed;
    }
  }
}


boolean allMoonsInCurrentLevelHit() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    if (!moonsHitPreviously[i]) {
      return false;
    }
  }
  return true;
}

boolean anyMoonHitShipOrEdge() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    PVector currentMoonCenter = moonsCenterLocations[i];
    boolean hitPlayer = dist(playerCenter.x + playerWidth/2, playerCenter.y, currentMoonCenter.x, currentMoonCenter.y) < width/8;
    boolean hitEdge = currentMoonCenter.x - width/8 < 0;
    if (hitPlayer || hitEdge) {
      return true;
    }
  }
  return false;
}

/*
 Utility Functions for the missile
*/

void initializeMissile() {
  missileShot = true;
  missileLocation = new PVector(playerCenter.x, playerCenter.y);
}

void drawMissile() {
  if (missileShot) {
    fill(255, 0, 0);
    strokeWeight(1);
    stroke(255, 0, 0);
    circle(missileLocation.x, missileLocation.y, 5);
    moveMissile();
  }
};

void moveMissile() {
  missileLocation.x += missileSpeed;

  if (missileLocation.x > width) {
    resetMissile();
  }
}

void resetMissile() {
  missileShot = false;
}

boolean missileHitMoon(PVector missileLocation, int moonIndex) {
  boolean moonHitPreviously = moonsHitPreviously[moonIndex];
  if (missileLocation != null && !moonHitPreviously) {
    PVector moonCenter = moonsCenterLocations[moonIndex];
    return dist(missileLocation.x, missileLocation.y, moonCenter.x, moonCenter.y) < width/8;
  }
  return false;
}

/*
  Utility functions for the stars
*/

void initializeStars() {
  for (int i = 0; i < numStars; i++) {
    starsPosition[i] = new PVector(random(0, width), random(0, height));
    starsDistance[i] = (random(10, 20));
  }
}

float pixelsForParallaxEffect(float z) {
  // Returning the pixels to move based on the z-distance of star
  return (5/ (pow(0.5 * z, 2)) - 0.05);
}

void animateStars() {
  for (int i = 0; i < numStars; i++) {
    PVector starPosition = starsPosition[i];
    float starDistance = starsDistance[i];

    strokeWeight(0.5);
    stroke(255);
    fill(255, 255, 255, 150);

    circle(starPosition.x, starPosition.y, 750 / (starDistance * starDistance));

    // Moving the x of star based on z-distance for parallaxEffect
    starsPosition[i].x = (starsPosition[i].x - pixelsForParallaxEffect(starDistance));

    // Done to reset the start back to right side of screen
    if (starsPosition[i].x < 0) {
      starsPosition[i].x += width;
      starsPosition[i].y = random(0, height);
    }
  }
}
