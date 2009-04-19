ROWS = 3
COLUMNS = 3

CORNERS = [
  [0,0],      [0,COLUMNS-1], 
  [ROWS-1,0], [ROWS-1,COLUMNS-1]
]

class Game
  attr_reader :turn, :grid, :scores
  
  def initialize(board, computer=false, starting_turn='X')
    @board = board
    @grid = Array.new(ROWS) { Array.new(COLUMNS) }
    @scores = Array.new(ROWS) { Array.new(COLUMNS) }
    @turn = starting_turn
    if computer
      computer_turn
      switch_turn
    end
  end
  
  def switch_turn
    @turn = other_turn
  end
  
  def other_turn
    if @turn == 'X'
      'O'
    else
      'X'
    end
  end
  
  def adjacent_enemies(row, column)
    count = 0
    [
      [row-1, column-1], [row-1, column], [row-1, column+1],
      [row,   column-1],                  [row,   column+1],
      [row+1, column-1], [row+1, column], [row+1, column+1]
    ].each do |row, column|
      count += 1 if row >= 0 && row < ROWS && 
                    column >= 0 && column < COLUMNS &&
                    @grid[row][column] == other_turn
    end
    count
  end
  
  def enemy_corners
    (CORNERS.select do |coordinates|
      row, column = coordinates
      @grid[row][column] == other_turn
    end).size
  end
  
  def computer_turn
    # try to win
    return if play_where do |row, column|
      can_win_with?(row, column)
    end
    
    # try to block
    return if play_where do |row, column|
      switch_turn # pretend to be the other player
      win = can_win_with?(row, column) # see if we could win
      switch_turn # switch back to the computer player
      win # return whether or not we succeeded
    end
    
    @scores = Array.new(ROWS) { Array.new(COLUMNS) { 0 } }
    
    for row in 0...ROWS
      for column in 0...COLUMNS
        # skip squares that are taken
        next unless @grid[row][column].nil?
        score = 0
        
        # center space is good
        score += 5 if row == ROWS/2 && column == COLUMNS/2
        
        # corners are good...
        if CORNERS.include?([row, column])
          # unless the enemy is trying a corner trap
          if enemy_corners == 2 && @grid[ROWS/2][COLUMNS/2] == @turn
            score -= 1
          else
            score += 1
          end
          
          # the more adjacent enemies, the better
          score += adjacent_enemies(row, column)
        end
        
        @scores[row][column] = score
      end
    end
    
    # play the first square with the maximum score
    play_where do |row, column|
      @scores[row][column] == scores.flatten.max
    end
  end
  
  # plays in the first empty space where the block returns true
  def play_where(&block)
    for row in 0...ROWS
      for column in 0...COLUMNS
        if @grid[row][column].nil?
          if yield(row, column)
            @grid[row][column] = @turn
            return true
          else
            @grid[row][column] = nil
          end
        end
      end
    end
    false
  end
  
  def game_over?
    @game_over = if win?
      alert "Player #{@turn} wins!"
      true
    elsif tie?
      alert "Game over!"
      true
    else
      false
    end
  end
  
  def play(row, column)
    if @grid[row][column].nil? && !@game_over
      @grid[row][column] = @turn
      @board.update
    
      unless game_over?
        switch_turn
        computer_turn
        @board.update
        unless game_over?
          switch_turn
          @board.update
        end
      end
    end
  end
  
  # would the player win with another space?
  def can_win_with?(row, column)
    @grid[row][column] = @turn
    win = win?
    @grid[row][column] = nil
    return win
  end
  
  def win?
    # three in a row
    return true if @grid.any? do |row|
      row.all? { |cell| cell == @turn }
    end
    
    # three in a column
    return true if @grid.transpose.any? do |row|
      row.all? { |cell| cell == @turn }
    end
    
    # three diagonal
    return true if @grid[ROWS/2][COLUMNS/2] == @turn && (
      (@grid[0][0] == @turn && @grid[ROWS-1][COLUMNS-1] == @turn) ||
      (@grid[0][COLUMNS-1] == @turn && @grid[ROWS-1][0] == @turn)
    )
    
    # if none of the above conditions return, no one won
    return false
  end
  
  def tie?
    # check if all cells are filled
    @grid.all? do |row|
      row.all?
    end
  end
end

Shoes.app :width => 310, :height => 350, :title => 'Tic Tac Toe' do
  @window = self
  @grid = Array.new(ROWS) { Array.new(COLUMNS) }
  @scores = Array.new(ROWS) { Array.new(COLUMNS) }
  
  # update every box with the data from the game
  def update
    for row in 0...ROWS
      for column in 0...COLUMNS
        @grid[row][column].text = @game.grid[row][column]
        #@scores[row][column].text = @game.scores[row][column]
      end
    end
    @status.text = "Player #{@game.turn}"
  end
  
  def new_game
    @game = Game.new(@window, @computer.checked?)
    @window.update
  end
  
  stack do
    flow do
      @computer = check { new_game }
      para "Computer Starts"
      button("New Game") { new_game }
      @status = para
    end
    
    ROWS.times do |row|
      # in each row, boxes go left to right
      flow do
        COLUMNS.times do |column|
          # make each grid box
          stack :width => 100, :height => 100 do
            border black, :strokewidth => 2
            @grid[row][column] = para :size => 36
            #@scores[row][column] = para
            click do
              @game.play(row, column)
            end
          end
        end
      end
    end
  end
  
  new_game
end
