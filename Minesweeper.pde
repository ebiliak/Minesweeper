import de.bezier.guido.*;

public final static int NUM_ROWS = 5;
public final static int NUM_COLS = 5;
private MSButton[][] buttons;
private ArrayList<MSButton> mines;
private boolean gameWon = false;

public void setup()
{
    size(400, 400);
    textAlign(CENTER, CENTER);
    
    Interactive.make(this);
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList<MSButton>();
    
    for(int i = 0; i < NUM_ROWS; i++) {
        for(int j = 0; j < NUM_COLS; j++) {
            buttons[i][j] = new MSButton(i, j);
        }
    }
    setMines();
}

private void setMines()
{
    int totalMines = 5;
    while(mines.size() < totalMines) {
        int r = (int)(Math.random() * NUM_ROWS);
        int c = (int)(Math.random() * NUM_COLS);
        if(!mines.contains(buttons[r][c])) {
            mines.add(buttons[r][c]);
        }
    }
}

public void draw()
{
    background(0);
    if(gameWon) {
        displayWinningScreen();
    }
    else if(isWon()) {
        gameWon = true;
    }
}

private boolean isWon()
{
    int flaggedMines = 0;
    for(MSButton mine : mines) {
        if(mine.isFlagged()) {
            flaggedMines++;
        }
    }
    
    for(int r = 0; r < NUM_ROWS; r++) {
        for(int c = 0; c < NUM_COLS; c++) {
            MSButton btn = buttons[r][c];
            if(!mines.contains(btn) && btn.isFlagged()) {
                return false;
            }
        }
    }
    
    return flaggedMines == mines.size();
}

private void displayLosingMessage()
{
    for(int r = 0; r < NUM_ROWS; r++) {
        for(int c = 0; c < NUM_COLS; c++) {
            if(mines.contains(buttons[r][c])) {
                buttons[r][c].setClicked(true);
            }
            buttons[r][c].setLabel("LOSE");
        }
    }
}

private void displayWinningScreen()
{
    background(0, 255, 0);
    fill(255);
    textSize(32);
    text("YOU WIN!", width/2, height/2 - 50);
    
    textSize(20);
    text("All bombs found!", width/2, height/2);
    text("Great job detective!", width/2, height/2 + 30);
    
    fill(0);
    textSize(16);
    text("Click anywhere to play again", width/2, height/2 + 60);
}

private boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

private int countMines(int row, int col)
{
    int numMines = 0;
    int[][] directions = {
        {-1,-1}, {-1,0}, {-1,1},
        {0,-1},         {0,1},
        {1,-1},  {1,0},  {1,1}
    };
    
    for(int[] dir : directions) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];
        if(isValid(newRow, newCol) && mines.contains(buttons[newRow][newCol])) {
            numMines++;
        }
    }
    return numMines;
}

public void mousePressed()
{
    if(gameWon) {
        gameWon = false;
        mines.clear();
        for(int i = 0; i < NUM_ROWS; i++) {
            for(int j = 0; j < NUM_COLS; j++) {
                buttons[i][j] = new MSButton(i, j);
            }
        }
        setMines();
    }
}

public class MSButton
{
    private int myRow, myCol;
    private float x, y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton(int row, int col)
    {
        width = 400.0/NUM_COLS;
        height = 400.0/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol * width;
        y = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this);
    }

    public void mousePressed() 
    {
        if(gameWon) return;
        
        clicked = true;
        if(mouseButton == RIGHT) {
            flagged = !flagged;
            if(!flagged) {
                clicked = false;
            }
        }
        else if(!flagged) {
            if(mines.contains(this)) {
                displayLosingMessage();
            }
            else {
                int mineCount = countMines(myRow, myCol);
                if(mineCount > 0) {
                    setLabel(mineCount);
                }
                else {
                    int[][] directions = {
                        {-1,-1}, {-1,0}, {-1,1},
                        {0,-1},         {0,1},
                        {1,-1},  {1,0},  {1,1}
                    };
                    for(int[] dir : directions) {
                        int newRow = myRow + dir[0];
                        int newCol = myCol + dir[1];
                        if(isValid(newRow, newCol)) {
                            MSButton neighbor = buttons[newRow][newCol];
                            if(!neighbor.isClicked() && !neighbor.isFlagged()) {
                                neighbor.mousePressed();
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void draw() 
    {    
        if(gameWon) return;
        
        if(flagged) {
            fill(0, 255, 0);
        }
        else if(clicked && mines.contains(this)) {
            fill(255, 0, 0);
        }
        else if(clicked) {
            fill(200);
        }
        else {
            fill(100);
        }
        
        rect(x, y, width, height);
        fill(0);
        text(myLabel, x + width/2, y + height/2);
    }
    
    private void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    
    private void setLabel(int newLabel)
    {
        myLabel = "" + newLabel;
    }
    
    public boolean isFlagged()
    {
        return flagged;
    }
    
    public boolean isClicked()
    {
        return clicked;
    }
    
    private void setClicked(boolean state)
    {
        clicked = state;
    }
}
