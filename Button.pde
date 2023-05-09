final class Button {

  float buttonX, buttonY;
  int buttonWidth, buttonHeight;
  int buttonRadius;
  boolean buttonHover = false;
  boolean selected = false;
  boolean active = true;
  color buttonColor, buttonHoverColor, buttonTextColor;
  String content;

  /**
   * Constuctor class for a button
   * @param x The button's x coordinate
   * @param y The button's y coordinate
   * @param buttonWidth The width of a button
   * @param buttonHeight The height of a button
   * @param buttonRadius The radius of a button
   * @param buttonColor The color of a button
   * @param buttonHoverColor The color of a button when hovered over
   * @param buttonTextColor The color of a button's text
   * @param content The button's text
   */
  public Button (float x, float y, int buttonWidth, int buttonHeight, int buttonRadius, color buttonColor, color buttonHoverColor, color buttonTextColor, String content) {
    this.buttonX = x;
    this.buttonY = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.buttonRadius = buttonRadius;
    this.buttonColor = buttonColor;
    this.buttonHoverColor = buttonHoverColor;
    this.buttonTextColor = buttonTextColor;
    this.content = content;
  }

  /**
   * Sets the content of the button
   * @param newContent The new content of the button
   */
  void setContent(String newContent) {
    this.content = newContent;
  }

  void draw() {
    update();
    // If button hovered over or selected
    if (buttonHover || selected) {
      fill(buttonHoverColor);
      stroke(buttonHoverColor);
    }
    else {
      fill(buttonColor);
      stroke(buttonColor);
    }

    rect(buttonX, buttonY, buttonWidth, buttonHeight, buttonRadius);
    fill(buttonTextColor);
    textAlign(CENTER);
    textSize(25);
    text(content, buttonX + (buttonWidth / 2), buttonY + (buttonHeight / 1.8));
  }

  /**
   * Updates a button based on whether it is hovered over or not
   */
  void update() {
    buttonHover = mouseX >= buttonX && mouseX <= buttonX + buttonWidth && mouseY >= buttonY && mouseY <= buttonY + buttonHeight;
  }

  /**
   * Selects a button
   */
  void select() {
    selected = true;
  }

  /**
   * Unselects a button
   */
  void unselect() {
    selected = false;
  }

  /**
   * Sets a button as active (displayed)
   */
  void setActive() {
    active = true;
  }

  /**
   * Sets a button as inactive (not displayed)
   */
  void setInactive() {
    active = false;
  }
}
