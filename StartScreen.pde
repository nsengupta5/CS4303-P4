final class StartScreen {

  Button startButton;
  Button resumeGameButton;
  Button settingsButton;
  Button mainMenuButton;
  Button endButton;
  Button helpButton;

  float logoInitX, logoInitY;
  boolean startedGame = false;
  PImage logo;

  /**
   * Constructor for the StartScreen
   * @param buttonInitX The first button's initial x coordinate
   * @param buttonInitY The first button's initial y coordinate
   * @param buttonWidth The width of a button
   * @param buttonHeight The height of a button
   * @param buttonRadius The radius of a button
   * @param buttonColor The color of a button
   * @param buttonHoverColor The color of a button when it is hovered over
   * @param buttonTextColor The color of a button's text
   * @param buttonGap The gap between two buttons
   * @param logoInitX The logo's x coordinate
   * @param logoInitY The logo's y coordinate
   */
  public StartScreen (float buttonInitX, float buttonInitY, int buttonWidth, int buttonHeight, int buttonRadius, color buttonColor, color buttonHoverColor, color buttonTextColor, int buttonGap, float logoInitX, float logoInitY) {
    logo = loadImage("logo.png");
    this.logoInitX = logoInitX;
    this.logoInitY = logoInitY;
    startButton = new Button(buttonInitX, buttonInitY, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "START GAME");
    resumeGameButton = new Button(buttonInitX, buttonInitY, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "RESUME GAME");
    /* settingsButton = new Button(buttonInitX, buttonInitY + buttonHeight + buttonGap, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "SETTINGS"); */
    mainMenuButton = new Button(buttonInitX, buttonInitY + buttonHeight + buttonGap, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "MAIN MENU");
    helpButton = new Button(buttonInitX, buttonInitY + buttonHeight + buttonGap , buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "HELP");
    endButton = new Button(buttonInitX, buttonInitY + buttonHeight * 2 + buttonGap * 2, buttonWidth, buttonHeight, buttonRadius, buttonColor, buttonHoverColor, buttonTextColor, "QUIT");
  }

  void draw(){
    image(logo, logoInitX, logoInitY);
    if (startedGame) {
      // If a game is currently running, show the resume and main screen button
      startButton.setInactive();
      /* settingsButton.setInactive(); */
      resumeGameButton.setActive();
      resumeGameButton.draw();
      mainMenuButton.setActive();
      mainMenuButton.draw();
    }
    else {
      // Otherwise, show a new game and settings button
      resumeGameButton.setInactive();
      mainMenuButton.setInactive();
      startButton.setActive();
      startButton.draw();
      /* settingsButton.setActive(); */
      /* settingsButton.draw(); */
    }
    helpButton.draw();
    endButton.draw();
  }
}
