require 'csv'

module Chess
	class Game
		attr_reader :chessboard, :current_player, :other_player
		
		def initialize
			@chessboard = Chessboard.new
			@white_player = Player.new(color: :white, name: "White")
			@black_player = Player.new(color: :black, name: "Black")
			@current_player = @white_player
			@other_player = @black_player
		end
		
		def play
			loop do
				if current_player.king(chessboard).in_checkmate?(chessboard)
					chessboard.display
					puts "Checkmate!"
					puts "#{other_player.name} wins the game!"
					break
				end
				
				puts ""
				puts "Turn #{chessboard.moves / 2}"
				chessboard.display
				print "#{current_player.name}, would you like to save, load, or quit? If so enter 'save', 'load', or 'quit'. Otherwise, enter your move: "
				command = gets.chomp
				case command
				when "quit"
					puts "Goodbye."
					break
				when "save"
					save_game
				when "load"
					load_game					
				else
					loop do
						moved = make_move(command)
						break if moved
						puts "Invalid move. Try again"
						print "#{current_player.name}, enter your move: "
						command = gets.chomp
					end
					switch_players
				end
			end
		end		
						
		def switch_players
			@current_player, @other_player = @other_player, @current_player
		end
		
		def make_move(input)
			move = input.match(/([a-hA-H][1-8]).*([a-hA-H][1-8])/)			
			return false if move.nil?
			from = move[1].upcase
			to = move[2].upcase
			square = chessboard.get_square(from)
			return false if square == " " || square.color != current_player.color
			
			#make sure king is not in check
			destination = chessboard.get_square(to)
			chessboard.set_square(to,square)
			chessboard.clear_square(from)
			square.move_to(chessboard,to)
			square.moves +=1
			check	= @current_player.king(chessboard).in_check?(chessboard)
			chessboard.set_square(from,square)
			chessboard.set_square(to,destination)		
			square.move_to(chessboard,from)
			square.moves -=1
			
			return false if check
			chessboard.move(from,to)
		end			
						
		def save_game
			Dir.mkdir('saves') unless Dir.exist? "saves"
			puts "Write the name of your save."
			name = gets.chomp
			csv = File.open('saves/saved_games.csv', "ab")
			csv.write("#{name},#{@chessboard},#{@white_player},#{@black_player},#{@current_player},#{@other_player}")
			csv.close
			puts "Game saved."
		end
		
		def load_game
			if !(File.exist?("saves/saved_games.csv"))
				puts "There are no saved games"
				play
			end
			
			puts "\nSaved Games:\n"
			saves = CSV.read('saves/saved_games.csv')
			saves.each_with_index do |save,index|
				puts "#{index +1 }. #{save[0]}"
			end
			
			load_save(saves)
			play
		end
		
		def load_save(saves)
			number = which_save(saves.size)
			@chessboard = saves[number][1]
			@white_player = saves[number][2]
			@black_player = saves[number][3]
			@current_player = saves[number][4]
			@other_player = saves[number][5]			
			puts "#{saves[number][0]} loaded."
		end
			
		def which_save(number_of_saves)
			puts "\nEnter the number that you want to load."
			answer = gets.chomp.to_i
			if answer < 1 || answer > number_of_saves
				puts "There is no save with that number."
				which_save(number_of_saves)
			else
				return answer-1
			end
		end
	end
end					
