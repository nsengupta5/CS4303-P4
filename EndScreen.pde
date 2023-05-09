final class EndScreen {

  Button newGameButton;
  Button endButton;
  Button mainMenu;
  color buttonColor, textColor;
  String winner;

  /**
   * Constructor for the EndScreen
   * @param buttonInitX The x coordinate for the first button
   * @param buttonInitY The y coordinate for the first button
   * @param buttonWidth The width of a button
   * @param buttonHeight The height of a button
   * @param buttonRadius The radius of a button
   * @param buttonGap The gap between two buttons
   * @param buttonColor The color of a button
   * @param buttonHoverColor The color of a button when it is hovered over
   * @param buttonTextColor The text color of a button's content
   * @param textColor The color of the text
   */
  public EndScreen(float buttonInitX, float buttonInitY, int buttonWidth, int buttonHeight, int buttonRadius, int buttonGap, color buttonColor, color buttonHoverColor, color buttonTextColor, color textColor) {
    this.buttonColor = buttonColor;
    this.textColor = textColor;
    newGameButton = new Button(buttonInitX, buttonInitY, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "NEW GAME");
    mainMenu = new Button(buttonInitX, buttonInitY + buttonHeight + buttonGap, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "MAIN MENU");
    endButton = new Button(buttonInitX, buttonInitY + (2 * buttonHeight) + (buttonGap * 2), buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "QUIT");
    winner = "";
  }

  void draw(){
    textAlign(CENTER);
    textSize(50);
    fill(textColor);
    text(winner + " won!", displayWidth / 2, displayHeight / 4);
    newGameButton.draw();
    mainMenu.draw();
    endButton.draw();
  }

  /**
   * Updates the winner to be displayed
   * @param winner The winner of the game
   */
  void updateWinner(String winner) {
    this.winner = winner;
  }

  /**
   * Updates the text color
   * @param newColor The new color of the text
   */
  void updateTextColor(color newColor) {
    this.textColor = newColor;
  }
}
