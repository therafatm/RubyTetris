class MyPiece < Piece

  All_My_Pieces = All_Pieces.dup
  All_My_Pieces.push(
                    [[[0, 0], [-1, 0], [1, 0], [2, 0], [3, 0]], # super long (only needs two)
                    [[0, 0], [0, -1], [0, 1], [0, 2], [0,3]]])
  All_My_Pieces.push( rotations([[0, 0], [1, 0], [1, 1]]) ) #  x
                                                            #  x x
  All_My_Pieces.push( rotations([[0, 0], [1, 0], [0, 1], [1, 1], [1,2]]) ) # x x
                                                                           # x x x
  #  enhancements
  def initialize (point_array, board)

    if !board.next_turn_cheat_turn?
      @all_rotations = point_array
    else
      @all_rotations = [ [[0,0]] , [[0,0]] ]
      board.reset_cheat_flag
    end

    @rotation_index = (0..(@all_rotations.size-1)).to_a.sample
    @color = All_Colors.sample
    @base_position = [5, 0] # [column, row]
    @board = board
    @moved = true
  end

  def self.next_piece (board)
      MyPiece.new(All_My_Pieces.sample, board)
  end
end

class MyBoard < Board
  # enhancements
  def initialize (game)
    super(game)
    @nextTurnCheatTurn = false
  end

  def next_turn_cheat_turn?
    @nextTurnCheatTurn
  end

  def next_piece
    @current_block = MyPiece.next_piece(self)
    @current_pos = nil
  end

  def cheat
    if @score >= 100 and !next_turn_cheat_turn?
      @nextTurnCheatTurn = true
      @score -= 100
    end
  end

  def reset_cheat_flag
    @nextTurnCheatTurn = false
  end

  def rotate180
    if !game_over? and @game.is_running?
      @current_block.move(0, 0, 2)
    end
    draw
  end

  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..locations.length-1).each{|index|
      current = locations[index];
      @grid[ current[1] + displacement[1] ][ current[0] + displacement[0] ] = @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
end

class MyTetris < Tetris
  # enhancements
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def key_bindings
    super
    @root.bind('u', proc {@board.rotate180})
    @root.bind('c', proc {@board.cheat})
  end
end