final class Menu {

  Button twoPlayer;
  Button onePlayer;
  Button startGame;

  PImage backIcon;
  PImage playerOneIcon;
  PImage playerTwoIcon;

  color buttonColor;
  color textColor;
  float buttonInitX, buttonInitY;
  int buttonWidth, buttonHeight;
  int buttonGap;
  float iconSize;

  int playerOneIndex;
  int playerTwoIndex;

  String[] characters = new String[]{
    "monk",
    "knight",
    "water",
    "leaf",
    "metal",
    "wind"
  };

  public Menu(float buttonInitX, float buttonInitY, int buttonWidth, int buttonHeight, int buttonRadius, color buttonColor, color buttonHoverColor, color buttonTextColor, int buttonGap, color textColor, float iconSize) {
    this.buttonInitX = buttonInitX;
    this.buttonInitY = buttonInitY;
    this.buttonWidth = buttonWidth; 
    this.buttonHeight = buttonHeight;
    this.buttonColor = buttonColor;
    this.buttonGap = buttonGap;
    this.textColor = textColor;
    this.iconSize = iconSize;
    this.playerOneIndex = 0;
    this.playerTwoIndex = 1;
    backIcon = loadImage("back_icon.png");

    twoPlayer = new Button(buttonInitX, buttonInitY, buttonWidth *3/2, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "MULTIPLAYER (Player vs Player)");
    onePlayer = new Button(buttonInitX, getNewRowY(1), buttonWidth *3/2, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "SINGLE PLAYER (Player vs AI)");
  }

  void draw() {
    textSize(80);
    textAlign(CENTER);
    text("CHOOSE YOUR FIGHTER", displayWidth / 2, displayHeight / 8);
    fill(147, 196, 125);
    textSize(40);
    displayPlayerOne();
    displayPlayerTwo();
    twoPlayer.draw();
    onePlayer.draw();
    image(backIcon, displayWidth / 60, displayHeight / 25);
  }

  void displayPlayerOne() {
    String characterName = characters[playerOneIndex];
    playerOneIcon = loadImage("./textures/" + characterName + "/" + characterName + ".png");
    float xVal = displayWidth / 5 + iconSize / 2 - 100;
    text("Player 1, choose with W and S", xVal, displayHeight / 2 - 150);
    image(playerOneIcon, displayWidth / 5, displayHeight / 2, iconSize, iconSize);
    text(characterName.substring(0, 1).toUpperCase() + characterName.substring(1), xVal, displayHeight / 2 + 150);
    text("(" + (playerOneIndex + 1) + "/6)",xVal, displayHeight / 2 + 200);
  }

  void displayPlayerTwo() {
    String characterName = characters[playerTwoIndex];
    playerTwoIcon = loadImage("./textures/" + characterName + "/" + characterName + ".png");
    float xVal = displayWidth / 5 * 4 + iconSize / 2 - 100;
    text("Player 2, choose with UP and DOWN arrows", xVal, displayHeight / 2 - 150);
    text(characterName.substring(0, 1).toUpperCase() + characterName.substring(1), xVal, displayHeight / 2 + 150);
    image(playerTwoIcon, displayWidth / 5 * 4, displayHeight / 2, iconSize, iconSize);
    text(characterName.substring(0, 1).toUpperCase() + characterName.substring(1), xVal, displayHeight / 2 + 150);
    text("(" + (playerTwoIndex + 1) + "/6)", xVal, displayHeight / 2 + 200);
  }

  void chooseNextPlayerOne() {
    playerOneIndex++;
    if (playerOneIndex >= characters.length) {
      playerOneIndex = 0;
    }
  }

  void choosePrevPlayerOne() {
    playerOneIndex--;
    if (playerOneIndex < 0) {
      playerOneIndex = characters.length - 1;
    }
  }

  void chooseNextPlayerTwo() {
    playerTwoIndex++;
    if (playerTwoIndex >= characters.length) {
      playerTwoIndex = 0;
    }
  }

  void choosePrevPlayerTwo() {
    playerTwoIndex--;
    if (playerTwoIndex < 0) {
      playerTwoIndex = characters.length - 1;
    }
  }

  /**
   * Returns a new y coordinate for a button in a new row
   * @param row the row number
   */
  float getNewRowY(int row) {
    return buttonInitY + (buttonHeight * row) + (buttonGap * row * 2);
  }

  /**
   * Returns a new x coordinate for a button in a new column
   * @param col the column number
   */
  float getNewColX(int col) {
    return buttonInitX + (buttonWidth * col) + (buttonGap * col);
  }
}
