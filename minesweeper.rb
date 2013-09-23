require 'yaml'

class Tile

  attr_reader :bomb, :revealed, :flagged

  def initialize(board, location)
    @bomb = false
    @revealed = false
    @flagged = false
    @board = board
    @location = location
  end

  def set_bomb
    @bomb = true
  end

  def set_flag
    @flagged = true
  end

  def neighbors
    #return array of Tiles
    neighbors = []
    [-1,0,1].each do |dx|
      [-1,0,1].each do |dy|
        next if [dx,dy] == [0,0]
        x,y = @location
        if (x+dx).between?(0,@board.size-1) && (y+dy).between?(0,@board.size-1)
          neighbors << @board.tiles[x+dx][y+dy]
        end
      end
    end
    neighbors
  end

  def value
    neighbors.select{|tile| tile.bomb?}.count
  end

  def bomb?
    @bomb
  end

  def flagged?
    @flagged
  end

  def revealed?
    @revealed
  end

  def reveal
    @revealed = true

    if value == 0 and !bomb?
      neighbors.each do |neighbor|
        neighbor.reveal unless neighbor.revealed?
      end
    end
  end

end



class Board

  attr_accessor :tiles, :size

  def initialize(size, num_bombs)

    @size = size
    @tiles = []
    @num_bombs = num_bombs

    generate_empty_board
    place_bombs
  end

  def generate_empty_board
    @size.times do |x|
      row = []
      @size.times do |y|
        row << Tile.new(self, [x,y])
      end
      @tiles << row
    end
  end

  def place_bombs
    bombs_placed = 0
    until bombs_placed == @num_bombs
      x, y = rand(@size - 1), rand(@size - 1)
      next if @tiles[x][y].bomb?
      @tiles[x][y].set_bomb
      bombs_placed += 1
    end
  end

  def display
    puts "#{@num_bombs} bombs. #{flags_placed} flags placed."
    legend = (0..@size - 1).to_a.join
    puts "x\\y #{legend}"
    @size.times do |x|
      print "  #{x} "
      @size.times do |y|
        if @tiles[x][y].flagged?
          print 'F'
        elsif !@tiles[x][y].revealed?
          print '*'
        elsif @tiles[x][y].bomb?
          print 'B'
        else
          print @tiles[x][y].value
        end
      end
      puts ""
    end
  end

  def explore(pos)
    x,y = pos
    @tiles[x][y].reveal

  end

  def flag(pos)
    x,y = pos
    @tiles[x][y].set_flag
  end

  def flags_placed
    @tiles.flatten.select { |tile| tile.flagged? }.count
  end

  def win?
    @tiles.flatten.all? { |tile| tile.revealed? || tile.bomb? } && !lose?
    #check all non-bomb tiles are visible && bombs not visible
  end

  def lose?
    @tiles.flatten.any? { |tile| tile.revealed? && tile.bomb? }
    #check if any bomb is visible
  end

end




class Game

  def initialize(size = 9, num_bombs = 10)
    @board = Board.new(size, num_bombs)
    @player = Player.new
    @moves = 0
  end

  def run
    @board.display
    welcome
    until finished?

      action, position = @player.get_position
      if action == 'e'
        @board.explore(position)
      elsif action == 'f'
        @board.flag(position)
      else
        next
      end
      @moves += 1
      @board.display
    end
    game_results
  end

  def welcome
    puts "Welcome to Minesweeper. Explore tiles at your own risk."
  end

  def finished?
    @board.win? || @board.lose?
  end

  def game_results
    if @board.win?
      puts "You won in #{@moves} moves."
      high_scores
    end
    puts "You lose" if @board.lose?
  end

  def high_scores
    # Load the highscoresi n YAML format.
    if File.exist?("high_scores.yaml")
      serialized_high_scores = File.read("high_scores.yaml")
      @high_scores = YAML.load(serialized_high_scores)
    else
      @high_scores = HighScores.new
    end

    @high_scores.input_score(@moves)
    @high_scores.display

    # Save the highscores in YAML format.
    File.open("high_scores.yaml", 'w') do |file|
      file.write(@high_scores.to_yaml)
    end
  end

end

class Player
  def get_position  # "r 1,2" or "f 4,5". Returns [action,position]
    puts "Flag or explore a location. (e.g. type 'e 1,2' to explore (1,2) or 'f 1,2' to flag it)"
    input = gets.chomp
    action, position = input.split(" ")
    position = position.split(",").map(&:to_i)
    [action,position]
  end
end

class HighScores
  def initialize
    @scores = [['AAA', 40]] * 10
  end

  def display
    puts "High scores:"
    @scores.each { |initials, score| puts "#{initials} : #{score}" }
  end

  def input_score(score)
    _,worst_top_score = @scores.last
    return if worst_top_score < score
    @scores.pop
    puts "You have a new high score! Enter your initials below: "
    initials = gets.chomp.upcase
    @scores << [initials, score]
    @scores.sort_by! { |initials, score| score }
  end
end

if __FILE__ == $0
  game = Game.new(5,1)
  game.run
end