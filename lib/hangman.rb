class Hangman
	def initialize
		print "Welcome to Hangman!\n\n"
		main_menu
	end

	def main_menu
		input = " "
		until input == "1" || input == "2"
			puts "[1] - New Game\n[2] - Load Game"
			input = gets.chomp
			if input == "1"
				new_game
			elsif input == "2"
				load_game
			else
				puts "Invalid entry. Enter either 1 or 2.\n\n"
			end
		end
	end

	def new_game
		@wrong_guesses_remaining = 10
		@word = generate_word
		@hidden_word = generate_hidden_word
		@played_letters = []
		@guess = ""
		puts "\nEnter 'SAVE' at any time to save and quit."
		guessing_loop
	end

	def load_game
		puts "Not yet implimented."
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
			sleep(1) unless @word.include?(@guess)
		end
		@hidden_word == @word ? player_wins : player_loses
	end

	def enter_guess
		@guess = ""
		until @guess =~ /^[a-z]$/
			@guess = gets.chomp.downcase
			save if @guess.downcase == "save"
			puts "That is not a letter! Please enter a letter." unless @guess =~ /^[a-z]$/
		end
	end

	def save
		# add code to save game
		print "Saving"
		3.times do
			sleep(0.5)
			print "."
		end
		sleep(0.5)
		abort("\nGoodbye!")
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