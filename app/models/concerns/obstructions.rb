module Obstructions
  # determines if a particular x, y coordinate is already occupied by a piece of the same color
  def destination_obstructed?(x, y)
    destination_obstruction = game.obstruction(x, y) # is there something at the destination
    # if it's the same color as piece it's a destination_obstruction
    destination_obstruction && destination_obstruction.color == color
  end

  # create an array of location tuples [x,y] to be checked later for obstruction
  # this method checks diagonally for queen and bishop
  def diagonal_obstruction_array(x, y)
    # store piece x & y positions in local variables
    pos_x = x_position
    pos_y = y_position

    # create return array of [ [x1,y1], [x2, y2], ... ]
    obstruction_array = []

    # check for moves that aren't diagonal
    return [] if x == pos_x
    return [] if y == pos_y

    # determine horizontal and vertical increment values
    horizontal_increment = x > pos_x ? 1 : -1
    vertical_increment = y > pos_y ? 1 : -1

    # increment once to move off of starting square
    pos_x += horizontal_increment
    pos_y += vertical_increment

    # loop through all values stopping before x, y
    while (x - pos_x).abs > 0 && (y - pos_y).abs > 0
      # push each coordinate pair to the array
      obstruction_array << [pos_x, pos_y]
      pos_x += horizontal_increment
      pos_y += vertical_increment
    end
    # return array
    obstruction_array
  end

  # create an array of location tuples [x,y] to be checked later for obstruction
  # this method checks rectilinearly for queen, rook and king on castling moves
  def rectilinear_obstruction_array(x, y)
    # store piece x & y positions in local variables
    pos_x = x_position
    pos_y = y_position

    # create return array of [ [x1,y1], [x2, y2], ... ]
    obstruction_array = []

    if y == pos_y # move is in x direction
      # determine horizontal increment value
      horizontal_increment = x > pos_x ? 1 : -1

      # increment once to mvoe off of starting square
      pos_x += horizontal_increment

      # loop through all values stopping before x
      while (x - pos_x).abs > 0
        obstruction_array << [pos_x, pos_y]
        pos_x += horizontal_increment
      end
    elsif x == pos_x # move is in y direction
      # determine vertical increment value
      vertical_increment = y > pos_y ? 1 : -1

      # increment once to mvoe off of starting square
      pos_y += vertical_increment

      # loop through all values stopping before x
      while (y - pos_y).abs > 0
        obstruction_array << [pos_x, pos_y]
        pos_y += vertical_increment
      end
    end
    # return array
    obstruction_array
  end
end
