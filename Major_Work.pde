float playerWidth; //<>//
float playerHeight;
float pixelsToMove;
PVector playerCenter;

PVector[] moonsCenterLocations;
boolean[] moonsHitPreviously;

int numStars;
PVector[] starsPosition;
float[] starsDistance;
float starsSpeed;

PVector missileLocation;
float missileSpeed;
boolean missileShot;


/*
  Driver code
 */
void setup() {
  size(500, 500);

  playerCenter = new PVector(50, 50);
  playerWidth = 40;
  playerHeight = 40; 
  pixelsToMove = 5;

  moonsCenterLocations = new PVector[3];
  moonsHitPreviously = new boolean[3];
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
  background(0);
  animateStars();

  drawMoons();
  drawMissile();
  drawPlayer(playerCenter.x, playerCenter.y);
}

void keyPressed() {
  movePlayer(key);
  
  if (key == ' ' && !missileShot) {
    initializeMissile();
    
  }
}

/*
  Utility functions for the player
 */

void drawPlayer(float x, float y) {
  noStroke();
  fill(255);
  triangle(x - playerWidth/2, y - playerHeight/2, x - playerWidth/2, y + playerHeight/2, x + playerWidth/2, y);
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
  for (int i = 0; i < moonsCenterLocations.length; i++) {
    moonsCenterLocations[i] = new PVector(random(width*5/6, width), random(0, height));
    moonsHitPreviously[i] = false;
  }
}

void drawMoon(float x, float y) {
    strokeWeight(5);
    stroke(255, 0, 0);
    fill(200, 0, 0);
    circle(x, y, width/4);
}

void drawMoons() {
  for (int i = 0; i < moonsCenterLocations.length; i++) {
    if (!missileHitMoon(i) && !moonsHitPreviously[i]) {
      PVector currentMoonLocation = moonsCenterLocations[i];
      drawMoon(currentMoonLocation.x, currentMoonLocation.y);
    }
    
    if (missileHitMoon(i)) {
      moonsHitPreviously[i] = true;
      resetMissile();
    }
  }
  
  moveMoons();
}


void moveMoons() {
  for (int i = 0; i < moonsCenterLocations.length; i++) {
    moonsCenterLocations[i].x -= 0.1;
  }
}

/* 
  Missile Utility Functions
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

boolean missileHitMoon(int index) {
  boolean moonHitPreviously = moonsHitPreviously[index];
  if (missileLocation != null && ! moonHitPreviously) { 
    PVector moonCenter = moonsCenterLocations[index];
    return dist(missileLocation.x, missileLocation.y, moonCenter.x, moonCenter.y) < 5/2 + width/8;
  } else {
    return false;
  }
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

float pixelsForParallaxEffect(float x) {
  return (5/ (pow(0.5 * x, 2)) - 0.05);
}

void animateStars() {
  for (int i = 0; i < numStars; i++) {
    PVector starPosition = starsPosition[i];
    float starDistance = starsDistance[i];
    fill(255, 255, 255, 150);
    circle(starPosition.x, starPosition.y, 750 / (starDistance * starDistance));
    starsPosition[i].x = (starsPosition[i].x - pixelsForParallaxEffect(starDistance));
    if (starsPosition[i].x < 0) {
      starsPosition[i].x += width;
      starsPosition[i].y = random(0, height);
    }
  }
}
