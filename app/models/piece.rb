require 'byebug'

class Piece < ActiveRecord::Base
  MIN_BOARD_SIZE = 0
  MAX_BOARD_SIZE = 7

  after_initialize :set_default_images
  after_initialize :set_default_state

  belongs_to :player
  belongs_to :game

  include Obstructions

  # use transactions to attempt a move, fail and rollback if move
  # puts player into check
  def attempt_move(piece, params)
    Piece.transaction do
      move_to(piece, params) if moving_own_piece?
      if game.check?(color)
        fail ActiveRecord::Rollback
      end
      # update current state of check, checkmate, etc.
      game.update_state(color)
    end
  end

  def can_be_blocked?(king)
    pos_x = x_position
    pos_y = y_position

    if type == 'Knight'
      return false
    elsif type == 'Pawn'
      return false
    elsif type == 'Rook'
      if king.y_position == pos_y # move is in x direction
        # determine increment value
        horizontal_increment = king.x_position > pos_x ? 1 : -1
        vertical_increment = 0
      else
        # determine increment value
        vertical_increment = king.y_position > pos_y ? 1 : -1
        horizontal_increment = 0
      end
    elsif type == 'Bishop'
      horizontal_increment = king.x_position > pos_x ? 1 : -1
      vertical_increment = king.y_position > pos_y ? 1 : -1
    elsif type == 'Queen'
      if king.y_position == pos_y # move is in x direction
        # determine increment value
        horizontal_increment = king.x_position > pos_x ? 1 : -1
        vertical_increment = 0
      elsif king.x_position == pos_x # move is in y direction
        # determine increment value
        vertical_increment = king.y_position > pos_y ? 1 : -1
        horizontal_increment = 0
      else
        horizontal_increment = king.x_position > pos_x ? 1 : -1
        vertical_increment = king.y_position > pos_y ? 1 : -1
      end
    end

    # increment once to move off of starting square
    pos_x += horizontal_increment
    pos_y += vertical_increment
    blockers = game.pieces_remaining(!color)
    while (king.x_position - pos_x).abs > 0 || (king.y_position - pos_y).abs > 0
      # loop through all values stopping before x, y
      blockers.each do |blocker|
        # return true if we find an obstruction
        return true if blocker.valid_move?(pos_x, pos_y)
      end
      pos_x += horizontal_increment
      pos_y += vertical_increment
    end
    false
  end

  def can_be_captured?
    opponents = game.pieces.where("color = ? and state != 'captured'", !color).to_a
    opponents.each do |opposing_piece|
      if opposing_piece.valid_move?(x_position, y_position)
        return true
      end
    end
    false
  end

  def capture_move?(x, y)
    captured_piece = game.obstruction(x, y)
    captured_piece && captured_piece.color != color
  end

  def color_name
    color ? 'white' : 'black'
  end

  def legal_move?(_x, _y)
    fail NotImplementedError 'Pieces must implement #legal_move?'
  end

  def moving_own_piece?
    player_id == game.turn
  end

  def move_on_board?(x, y)
    (x <= MAX_BOARD_SIZE && x >= MIN_BOARD_SIZE) &&
      (y <= MAX_BOARD_SIZE && y >= MIN_BOARD_SIZE)
  end

  def move_to(piece, params)
    x = params[:x_position].to_i
    y = params[:y_position].to_i

    if piece.valid_move?(x, y)
      if capture_move?(x, y)
        captured = game.obstruction(x, y)
        captured.update_piece(nil, nil, 'captured')
      end

      update_piece(x, y, 'moved')
      return true
    end

    false
  end

  def nil_move?(x, y)
    x_position == x && y_position == y
  end

  def obstructed_move?(_x, _y)
    fail NotImplementedError 'Pieces must implement #obstructed_move?'
  end

  def update_piece(x, y, state)
    update_attributes(x_position: x, y_position: y, state: state)
  end

  def valid_move?(x, y)
    return false if nil_move?(x, y)
    return false unless move_on_board?(x, y)
    return false unless legal_move?(x, y)
    return false if obstructed_move?(x, y)
    return false if destination_obstructed?(x, y)
    true
  end

  private

  def set_default_images
    self.symbol ||= "#{color_name}-#{type.downcase}.svg"
  end

  def set_default_state
    self.state ||= 'unmoved'
  end
end
