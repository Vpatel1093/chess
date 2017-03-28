require_relative 'chess_helper.rb'

module Chess
	class Chessboard	
		include ChessHelper
		
		attr_accessor :moves
		attr_reader :board
		
		def initialize(input={})
			@board = input.fetch(:board, default_board)
			@moves = 1
		end
		
		def move(from,to)
			valid_san = /^[a-hA-H][1-8]$/
			return false unless from.match(valid_san) && to.match(valid_san) && from != to
			
			piece = get_square(from)
			destination = get_square(to)
			
			#castling
			if piece.instance_of?(King) && destination.instance_of?(Rook) && piece.color == destination.color
				if piece.can_castle?(self,to)
					if to[0] == "H"
						king_position = "G" + to[1]
						rook_position = "F" + to[1]
					else
						king_position = "C" + to[1]
						rook_position = "D" + to[1]
					end
					set_square(king_position, piece)
					get_square(king_position).moves += 1
					set_square(rook_position, destination)
					get_square(rook_position).moves += 1
					clear_square(from)
					clear_square(to)
					@moves += 1
					return true
				else
					return false
				end
			end
			
			return false unless piece.valid_move?(self,to)
			@moves += 1
			
			#en passant		
			x_from, y_from = get_xy(from)
			x_to, y_to = get_xy(to)
			side = piece.color == :white ? 1 : -1
			if piece.instance_of?(Pawn) && (x_to-x_from).abs == 1 && (y_to-y_from).abs == 1 && get_square(to) == " "
				board[y_to-side][x_to] = " "
			end
			
			set_square(to,piece)
			piece.move_to(self,to)
			clear_square(from)
				
			if piece.to_be_promoted?
				while true
					print "Choose a piece. Enter Queen, Rook, Bishop, or Knight:"
					new_piece = gets.chomp.downcase
					break if new_piece == "queen" || new_piece == "rook" || new_piece == "bishop" || new_piece == "knight"
					puts "Not a valid piece, please try again."
				end
				
				case new_piece
				when "queen"
					set_square(to, Queen.new(color: piece.color, locaton: to))
				when "rook"
					set_square(to, Rook.new(color: piece.color, location: to))
				when "bishop"
					set_square(to, Bishop.new(color: piece.color, location: to))
				when "knight"
					set_square(to, Knight.new(color: piece.color, location: to))
				end
			end
			true
		end
		
		def get_square(san)
			x,y = get_xy(san)
			board[y][x]
		end
		
		def set_square(san, value)
			x,y = get_xy(san)
			board[y][x] = value
		end
		
		def get_squares(from, to)
			squares = []
			x_from, y_from = get_xy(from)
			x_to, y_to = get_xy(to)
			
			x_dir = direction(x_from,x_to)
			y_dir = direction(y_from,y_to)
			
			dx = (x_to - x_from).abs
			dy = (y_to - y_from).abs
				
			if same_square?(dx,dy)
				squares << board[y_from][x_from]
			elsif vertical_move?(dx,dy)
				(dy+1).times {|i| squares << board[y_from + y_dir*i][x_from]}
			elsif horizontal_move?(dx,dy)
				(dx+1).times {|i| squares << board[y_from][x_from + x_dir*i]}
			elsif diagonal_move?(dx,dy)
				(dx+1).times {|i| squares << board[y_from + y_dir*i][x_from + x_dir*i]}
			end
			squares
		end
		
		def get_pieces(color)
			pieces = []
			board.each {|row| row.each {|square| pieces << square if square.is_a?(Piece) && square.color == color } }
			pieces
		end
		
		def path_blocked?(from,to)
			squares = get_squares(from,to)
			return false if squares.empty?
			squares[1..-2].any? {|square| square.is_a?(Piece) }
		end
				
		def vertical_move?(dx,dy)
			dx == 0 && dy > 0
		end
		
		def horizontal_move?(dx,dy)
			dx > 0 && dy == 0
		end
		
		def diagonal_move?(dx,dy)
			dx > 0 && dx == dy
		end
		
		def clear_square(san)
			set_square(san, " ")
		end		
				
		def display
			("A".."H").each {|e| print " #{e}"}
			puts ""
			8.times do |row|
				print "#{8-row}" + board[-1-row].join(" ") + " #{8-row}"
				puts ""
			end
			("A".."H").each {|e| print " #{e}"}
			puts ""
		end
				
		private
		
		def same_square?(dx,dy)
			dx == 0 && dy == 0
		end		
				
		def direction(from,to)
			from > to ? -1 : 1
		end
		
		def default_board
			board = Array.new(8) { Array.new(8) { " " } }
			
			board[0][0] = Rook.new(color: :white, location: "A1")		
			board[0][1] = Knight.new(color: :white, location: "B1")
			board[0][2] = Bishop.new(color: :white, location: "C1")
			board[0][3] = Queen.new(color: :white, location: "D1")
			board[0][4] = King.new(color: :white, location: "E1")
			board[0][5] = Bishop.new(color: :white, location: "F1")
			board[0][6] = Knight.new(color: :white, location: "G1")
			board[0][7] = Rook.new(color: :white, location: "H1")
		
			board[1][0] = Pawn.new(color: :white, location: "A2")	
			board[1][1] = Pawn.new(color: :white, location: "B2")	
			board[1][2] = Pawn.new(color: :white, location: "C2")	
			board[1][3] = Pawn.new(color: :white, location: "D2")	
			board[1][4] = Pawn.new(color: :white, location: "E2")	
			board[1][5] = Pawn.new(color: :white, location: "F2")	
			board[1][6] = Pawn.new(color: :white, location: "G2")	
			board[1][7] = Pawn.new(color: :white, location: "H2")	
			
			board[6][0] = Pawn.new(color: :black, location: "A7")	
			board[6][1] = Pawn.new(color: :black, location: "B7")	
			board[6][2] = Pawn.new(color: :black, location: "C7")	
			board[6][3] = Pawn.new(color: :black, location: "D7")	
			board[6][4] = Pawn.new(color: :black, location: "E7")	
			board[6][5] = Pawn.new(color: :black, location: "F7")	
			board[6][6] = Pawn.new(color: :black, location: "G7")	
			board[6][7] = Pawn.new(color: :black, location: "H7")	
		
			board[7][0] = Rook.new(color: :black, location: "A8")		
			board[7][1] = Knight.new(color: :black, location: "B8")
			board[7][2] = Bishop.new(color: :black, location: "C8")
			board[7][3] = Queen.new(color: :black, location: "D8")
			board[7][4] = King.new(color: :black, location: "E8")
			board[7][5] = Bishop.new(color: :black, location: "F8")
			board[7][6] = Knight.new(color: :black, location: "G8")
			board[7][7] = Rook.new(color: :black, location: "H8")
		
			board
		end
	end
end
