//****************************************************************************//
//                       COMP1000 MAJOR WORK SUBMISSTION                      //
//****************************************************************************//
//                                Hrithik Barua                               //
//****************************************************************************//

float startButtonWidth = 200, startButtonHeight = 50;

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
float[] frameNumberForMoonsHit;
float moonSpeed;
float moonDiameter;

int numStars;
PVector[] starsPosition;
float[] starsDistance;
float starsSpeed;

PVector missileLocation;
float missileSpeed;
boolean missileShot;

int points;

//****************************************************************************//
//                                 Driver Code                                //
//****************************************************************************//

void setup() {
  size(500, 500);

  startButtonClicked = false;
  points = 0;

  // currentLevel is 0, 1 or 2
  currentLevel = 0;
  gameWon = false;
  gameOver = false;

  playerCenter = new PVector(50, 50);
  playerWidth = 40;
  playerHeight = 40;
  pixelsToMove = 5;

  moonDiameter = width/4;
  numMoonsInLevel = new int[] {3, 4, 6};
  moonsCenterLocations = new PVector[6];
  moonsHitPreviously = new boolean[6];
  frameNumberForMoonsHit = new float[6];
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
  
  // Although this condition is the same as the one later on
  // I have add it here so that the points text is behind the stars.
  if (startButtonClicked && !gameOver) {
    showPoints();
  }

  animateStars();
  
  if (!startButtonClicked) {
    drawStartButton();
  }

  if (startButtonClicked && !gameOver) {
    drawMissile();
    /* drawMoons draws multiple moons and thus it uses the drawMoon func
       to draw each moon
    */
    // drawMoons Function internally uses drawMoon
    drawMoons();
    drawPlayer(playerCenter.x, playerCenter.y);

    if (allMoonsInCurrentLevelHit()) {
      levelUp();
    }

    if (anyMoonHitShipOrEdge()) {
      gameWon = false;
      gameOver = true;
    }
  } else if (gameOver) {
    if (gameWon) {
      drawMoonExplosion(random(0, width), random(0, height));
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

//****************************************************************************//
//                             End of Driver Code                             //
//****************************************************************************//


//****************************************************************************//
//               Utility functions for the Start and End of Game              //
//****************************************************************************//

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

//****************************************************************************//
//                       Utility Function for the Levels                      //
//****************************************************************************//

void levelUp() {
  // increase level if there are any left, otherwise the game is won
  if (currentLevel < 2) {
    currentLevel++;
    moonSpeed *= 2;
    initializeMoons();
  } else {
    gameWon = true;
    gameOver = true;
  }
}

//****************************************************************************//
//                      Utility Function for the Points                      //
//****************************************************************************//

void showPoints() {
  textSize(300);
  textAlign(CENTER);
  fill(25);
  text(points, width/2, 320);
}

//****************************************************************************//
//                      Utility Functions for the Player                      //
//****************************************************************************//

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
  drawTorchLight(p3.copy().sub(new PVector(x, y)), p3);
}

void drawTorchLight(PVector directionVector, PVector playerFrontPoint) {
  PVector end = playerFrontPoint.copy().add(directionVector.copy().normalize().mult(width));
  strokeWeight(0);
  color torchLightColor = #FFFF00;
  stroke(torchLightColor, 10);
  fill(torchLightColor, 15);
  triangle(playerFrontPoint.x, playerFrontPoint.y, end.x, end.y + width/2, end.x, end.y - width/2);
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

//****************************************************************************//
//                       Utility Functions for the Moons                      //
//****************************************************************************//

void initializeMoons() {
  for (int i = 0; i < numMoonsInLevel[currentLevel]; i++) {
    moonsCenterLocations[i] = new PVector(random(width*4/6, width), random(0, height));
    moonsHitPreviously[i] = false;
    frameNumberForMoonsHit[i] = 0;
  }
}

void drawMoon(float x, float y) {
  // The moon itself
  strokeWeight(2);
  stroke(#31190A);
  fill(#5f4e43);
  circle(x, y, moonDiameter);

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
      frameNumberForMoonsHit[i] = frameCount;
      points++;
      resetMissile();
    }

    // check if the moon hasnt been hit moon previusly
    // only then draw the moon
    if (!missileHitMoon(missileLocation, i) && !moonsHitPreviously[i]) {
      drawMoon(currentMoonLocation.x, currentMoonLocation.y);
    } else if (frameCount - frameNumberForMoonsHit[i] < frameRate/5){
      // here it is guranteed that moon is hit 1/5 seconds ago
      // so explosion is only show for 1/5 seconds after a certain moon is hit
      drawMoonExplosion(currentMoonLocation.x, currentMoonLocation.y);
    }

  }

  moveMoons();
}

void drawMoonExplosion(float x, float y) {
  color c1 = color(255, 0, 0);
  color c2 = color(255, 255, 0);
  for (float theta = 0; theta <= 2 * PI; theta += 0.1) {
    float len = random(50, 85);
    strokeWeight(1);
    gradient_line(c2, c1, x, y, x + len * cos(theta), y + len * sin(theta));
  }
}

void gradient_line( color s, color e, float x, float y, float x2, float y2 ) {
  for ( int i = 0; i < 100; i ++ ) {
    stroke( lerpColor( s, e, i/100.0) );
    line( ((100-i)*x + i*x2)/100.0, ((100-i)*y + i*y2)/100.0, 
      ((100-i-1)*x + (i+1)*x2)/100.0, ((100-i-1)*y + (i+1)*y2)/100.0 );
  }
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
    boolean hitPlayer = dist(playerCenter.x + playerWidth/2, playerCenter.y, currentMoonCenter.x, currentMoonCenter.y) < moonDiameter/2;
    boolean hitEdge = currentMoonCenter.x - moonDiameter/2 < 0;
    if (hitPlayer || hitEdge) {
      return true;
    }

  }
  return false;
}

//****************************************************************************//
//                     Utility Functions for the Missiles                     //
//****************************************************************************//

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
  if (missileLocation != null && !moonHitPreviously && missileShot) {
    PVector moonCenter = moonsCenterLocations[moonIndex];
    return dist(missileLocation.x, missileLocation.y, moonCenter.x, moonCenter.y) < moonDiameter/2;
  }
  return false;
}

//****************************************************************************//
//                       Utility Functions for the Stars                      //
//****************************************************************************//

void initializeStars() {
  for (int i = 0; i < numStars; i++) {
    starsPosition[i] = new PVector(random(0, width), random(0, height));
    starsDistance[i] = (random(10, 50));
  }
}

float pixelsForParallaxEffect(float z) {
  // Returning the pixels to move based on the z-distance of star
  float starSpeed = 5;
  return 2 * atan(starSpeed/z);
}

void animateStars() {
  for (int i = 0; i < numStars; i++) {
    PVector starPosition = starsPosition[i];
    float starDistance = starsDistance[i];

    strokeWeight(0.5);
    stroke(255);
    fill(255, 255, 255, 150);

    float apparentStarDiameter = 750 / (starDistance * starDistance);
    circle(starPosition.x, starPosition.y, apparentStarDiameter);

    // Moving the x of star based on z-distance for parallaxEffect
    starsPosition[i].x -= pixelsForParallaxEffect(starDistance);

    // Done to reset the star back to right side of screen
    if (starsPosition[i].x < 0) {
      starsPosition[i].x += width;
      starsPosition[i].y = random(0, height);
    }
  }
}
