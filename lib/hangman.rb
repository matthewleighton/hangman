require 'yaml'

class Hangman
	def initialize
		print "Welcome to Hangman!\n\n"
	end

	def main_menu
		input = " "
		until input == "1" || input == "2"
			puts "[1] - New Game\n[2] - View saves"
			input = gets.chomp
			if input == "1"
				new_game
			elsif input == "2"
				view_saves
			else
				puts "Invalid entry. Enter either 1 or 2.\n\n"
			end
		end
	end

	def new_game
		@name = enter_name
		@wrong_guesses_remaining = 10
		@word = generate_word
		@hidden_word = generate_hidden_word
		@played_letters = []
		@guess = ""
		puts "\nEnter 'SAVE' at any time to save and quit."
		guessing_loop
	end

	def enter_name
		puts "Enter your name."
		gets.chomp
	end

	def view_saves
		Dir.mkdir("save_games") unless Dir.exists?("save_games")
		save_files = Dir["./save_games/*"]

		if save_files == []
			puts "\nNo saved games found.\n\n"
			main_menu
		else
			puts "\nChoose a save."
			save_files.each_with_index do |file, index|
				puts "[#{index + 1}] - #{list_game_save(file)}"
				#puts "[#{index + 1}] - #{file}"
			end
			input = gets.to_i
			until input.between?(1, save_files.count)
				puts "There is no save with that number."
				input = gets.to_i
			end
			file = save_files[input-1]
			open_or_delete_file(file)			
		end
	end

	def list_game_save(file)
		file = file.match(/s\/(.+)/).to_s[2..-5].gsub("-", "/").gsub("_", " ")
		date = file.slice!(/\d+/).insert(2, ":").insert(5, ":")
		file.insert(-12, date)
	end

	def open_or_delete_file(file)
		puts file
		puts "[1] - Load save\n[2] - Delete save"
		input = gets.to_i
		until input.to_i.between?(1,2)
			puts "Invalid entry.\n[1] - Load save\n[2] - Delete save"
			input = gets.chomp
		end
		if input == 1
			load_game(file)
		elsif input == 2
			puts confirm_delete_file?(file) ? delete_file(file) : "File not deleted."
			view_saves
		end
	end

	def confirm_delete_file?(file)
		puts "Are you sure you want to delete the save #{file}?\nY/N"
		input = gets.chomp.upcase
		input == "Y" ? true : false
	end

	def delete_file(file)
		File.delete(file)
		puts "Save deleted"
	end

	def load_game(file)
		File.open(file, "r") do |f|
			game = YAML.load(f.read)
			assign_load_variables(game)
		end
		puts "Welcome back!"
		guessing_loop
	end

	def save_game
		Dir.mkdir("save_games") unless Dir.exists?("save_games")
		save_data = get_save_data
		
		time = Time.now.strftime("%H%M%S")
		date = Time.now.strftime("%d-%m-%Y")
		file_name = "#{@name}_#{time}_#{date}.yml"

		File.open("save_games/#{file_name}", "w") do |f|
			f.puts YAML.dump(save_data)
		end

		print "Saving"
		3.times do # NEED TO CONVERT TO ONE LINE
			sleep(0.5)
			print "."
		end
		sleep(0.5)
		abort("\nGoodbye!")
	end

	def get_save_data
		save_data = {}
		save_data["wrong_guesses_remaining"] = @wrong_guesses_remaining
		save_data["word"] = @word
		save_data["hidden_word"] = @hidden_word
		save_data["played_letters"] = @played_letters
		save_data["name"] = @name

		save_data
	end

	def assign_load_variables(game)
		@wrong_guesses_remaining = game["wrong_guesses_remaining"]
		@word = game["word"]
		@hidden_word = game["hidden_word"]
		@played_letters = game["played_letters"]
		@name = game["name"]
	end

	def generate_word
		file = File.readlines("words.txt")
		n = rand(0..file.length - 1)
		file[n].chomp.downcase.split("")
	end

	def generate_hidden_word
		@word.collect { |letter| "__"}
	end

	def guessing_loop
		until @hidden_word == @word || @wrong_guesses_remaining == 0
			puts "_____________________________________"
			puts "\n#{@wrong_guesses_remaining} incorrect guesses remaining."
			puts "Already entered: #{@played_letters.sort.join(" ").upcase}" if @played_letters.count > 0
			puts "\nEnter a letter.\n\n"
			puts "#{@hidden_word.join(" ")}\n\n"
			enter_guess
			while letter_already_played?
				puts "You've already played that letter. Enter another."
				enter_guess
			end
			letter_included? ? reveal_letter : incorrect_guess
			add_played_letter
			#sleep(1) unless @word.include?(@guess)
		end
		@hidden_word == @word ? player_wins : player_loses
	end

	def enter_guess
		@guess = ""
		until @guess =~ /^[a-z]$/
			@guess = gets.chomp.downcase
			save_game if @guess.downcase == "save"
			puts "That is not a letter! Please enter a letter." unless @guess =~ /^[a-z]$/
		end
	end

	def letter_already_played?
		@played_letters.include?(@guess) ? true : false
	end

	def letter_included?
		@word.include?(@guess) ? true : false
	end

	def reveal_letter
		@word.each_with_index do |letter, index|
			if letter == @guess
				@hidden_word[index] = letter
			end
		end
	end

	def add_played_letter
		@played_letters << @guess
	end

	def incorrect_guess
		puts "Nope! The word doesn't contain that letter."
		@wrong_guesses_remaining -= 1
	end

	def player_wins
		puts "\nCongratulations! You guessed the word!"
		puts @word.join(" ")
	end

	def player_loses
		puts "\nYou're out of remaining guesses!"
		puts "The correct word was #{@word.join("")}."
	end

end