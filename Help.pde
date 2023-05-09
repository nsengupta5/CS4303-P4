final class Help {

  PImage backIcon;
  color textColor;
  int textGap;

  public Help(color textColor, int textGap) {
    backIcon = loadImage("back_icon.png");
    this.textColor = textColor;
    this.textGap = textGap * 4;
  }

  void draw() {
    textAlign(CENTER);
    textSize(50);
    fill(textColor);
    text("INSTRUCTIONS", displayWidth / 2, displayHeight / 10);

    image(backIcon, displayWidth / 60, displayHeight / 25);

    textSize(30);
    text("Move (Left side) with a and d", displayWidth / 2, displayHeight / 5);
    text("Move (Right side) with the arrow keys", displayWidth / 2, displayHeight / 5 + textGap);

    text("Attack (Left side) with the space bar", displayWidth / 2, displayHeight / 5 + textGap * 2);
    text("Attack (Right side) with the Shift key", displayWidth / 2, displayHeight / 5 + textGap * 3);

    text("Block (Left side) with f", displayWidth / 2, displayHeight / 5 + textGap * 4);
    text("Block (Right side) with / | ?", displayWidth / 2, displayHeight / 5 + textGap * 5);

    
    text("Abilities (Left side) with e and r", displayWidth / 2, displayHeight / 5 + textGap * 6);
    text("Abilities (Right side) with ; | : and '/ | @ ", displayWidth / 2, displayHeight / 5 + textGap * 7);


    textSize(50);
    text("Good Luck!", displayWidth / 2, displayHeight / 5 + textGap * 8);
  }

  void updateTextColor(color newColor) {
    this.textColor = newColor;
  }
}
