float playerWidth;
float playerHeight;
float pixelsToMove;
PVector playerCenter;

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
   
   numStars = 75;
   starsSpeed = 10;
   starsPosition = new PVector[numStars];
   starsDistance = new float[numStars];
   initializeStars();
}

void draw() {
  background(0); //<>//
  animateStars();
  drawPlayer(playerCenter.x, playerCenter.y);

}

void keyPressed() {
  movePlayer(key);
}

/*
  Utility functions for the star
*/

void initializeStars() {
  for (int i = 0; i < numStars; i++) {
    starsPosition[i] = new PVector(random(0, width), random(0, height));
    starsDistance[i] = (random(10, 20));
  }
}

void animateStars() {
  for (int i = 0; i < numStars; i++) {
    PVector starPosition = starsPosition[i];
    float starDistance = starsDistance[i];
    fill(255, 255, 255, 150);
    circle(starPosition.x, starPosition.y, 750 / (starDistance * starDistance));
    starsPosition[i].x = (starsPosition[i].x - 5000 / pow(starDistance, 4));
    if (starsPosition[i].x < 0) {
      starsPosition[i].x += width;
      starsPosition[i].y = random(0, height);
    }
  }
}


/*
  Utility functions for the player
*/

void drawPlayer(float x, float y) {
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
