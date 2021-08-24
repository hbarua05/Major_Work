float playerWidth;
float playerHeight;
float pixelsToMove;
PVector playerCenter;

PVector moonCenter;

int numStars;
PVector[] starsPosition;
float[] starsDistance;
float starsSpeed;


/*
  Driver code
*/
void setup() {
   size(500, 500);
   
   playerCenter = new PVector(50, 50);
   playerWidth = 40;
   playerHeight = 40; 
   pixelsToMove = 5;
   
   moonCenter = new PVector(width*3/4, height/2);
   
   numStars = 150;
   starsSpeed = 10;
   starsPosition = new PVector[numStars];
   starsDistance = new float[numStars];
   initializeStars();
}

void draw() {
  background(0); //<>//
  animateStars();
  drawMoon(moonCenter.x, moonCenter.y);
  drawPlayer(playerCenter.x, playerCenter.y);

}

void keyPressed() {
  movePlayer(key);
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

void drawMoon(float x, float y) {
  strokeWeight(5);
  stroke(255, 0, 0);
  fill(200, 0, 0);
  circle(x, y, width/4);
  moveMoon();
}

void moveMoon() {
  moonCenter.x -= 0.5;
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
