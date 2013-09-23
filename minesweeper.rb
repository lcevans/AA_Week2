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
        neighbors << @board.tiles[x+dx][y+dy] if (x+dx).between?(0,@board.size-1) && (y+dy).between?(0,@board.size-1)
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
      end

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
    puts "You win" if @board.win?
    puts "You lose" if @board.lose?
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