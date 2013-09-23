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
  end

  def value
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
  end

end



class Board

  attr_accessor :tiles

  def initialize(size = 9, num_bombs = 9)
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
    # find neighbords
    # - check if they're bombs or revealed

  end

  def flag(pos)
    x,y = pos
    @tiles[x][y].set_flag
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

  def initialize
    @board = Board.new
  end

  def run
    # @board.display
    # until game.finished?
    #   prompt for input (will be location)- will either flag or explore
    #   board.update
    # end
    #
    #  game results
  end

  def finished?
    @board.win? || @board.lose?
  end

end

class Player
  def give_location  # "r 1,2" or "f 4,5". Returns [action,position]
    puts "Flag or explore a location. (e.g. type 'e 1,2' to explore (1,2) or 'f 1,2' to flag it)"
    input = gets.chomp
    action, position = input.split(" ")
    position = position.split(",").map(&:to_i)
    [action,position]
  end
end