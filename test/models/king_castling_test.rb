require 'test_helper'

# Tests specific to King logic
class KingCastlingTest < ActiveSupport::TestCase
  test 'Should be legal castle move' do
    setup_game_and_castling

    assert @king.legal_castle_move?(6, 0)
    assert @king.legal_castle_move?(2, 0)
  end

  test 'Should be illegal castle move' do
    setup_game_and_castling

    assert_not @king.legal_castle_move?(5, 0)
    assert_not @king.legal_castle_move?(6, 1)

    @king.update_attributes(state: 'moved')
    @king.reload

    assert_not @king.legal_castle_move?(6, 0)
  end

  test 'Should castle kingside' do
    setup_game_and_castling

    assert @king.legal_castle_move?(6, 0)

    @king.castle_move
    @king.reload
    @kings_rook.reload

    assert_equal 6, @king.x_position, 'King moves to castle position'
    assert_equal 'castled', @king.state, 'King is marked castled'
    assert_equal 5, @kings_rook.x_position, 'Rook moves to castle position'
    assert_equal 'moved', @kings_rook.state, 'Rook is marked moved'
  end

  test 'Should castle queenside' do
    setup_game_and_castling

    assert @king.legal_castle_move?(2, 0)

    @king.castle_move
    @king.reload
    @queens_rook.reload

    assert_equal 2, @king.x_position, 'King moves to castle position'
    assert_equal 3, @queens_rook.x_position, 'Rook moves to castle position'
  end

  test 'Should return kingside rook' do
    setup_game_and_castling

    assert_equal @kings_rook, @king.rook_for_castling('King')
  end

  test 'Should return queenside rook' do
    setup_game_and_castling

    assert_equal @queens_rook, @king.rook_for_castling('Queen')
  end

  test 'Should return nil for no rook' do
    setup_game_and_castling

    @kings_rook.destroy
    assert_equal nil, @king.rook_for_castling('King')
  end

  # setup new game and find white king
  def setup_game_and_castling
    @game = FactoryGirl.create(:game)
    @king = @game.pieces.find_by(type: 'King', x_position: 4, y_position: 0)
    @kings_rook = @game.pieces.find_by(type: 'Rook', x_position: 7, y_position: 0)
    @queens_rook = @game.pieces.find_by(type: 'Rook', x_position: 0, y_position: 0)
  end
end
