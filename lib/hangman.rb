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

		puts "Your word is #{@word.join("")}"
		puts @hidden_word.join(" ")

		guessing_loop
	end

	def load_game
		puts "Not yet implimented."
	end

	def generate_word
		file = File.readlines("words.txt")
		n = rand(0..file.length - 1)
		[*file][n].chomp.split("")
	end

	def generate_hidden_word
		word = @word.collect { |letter| "__"}
		word
	end

	def guessing_loop
		until @hidden_word == @word || @wrong_guesses_remaining == 0
			puts "Please enter a letter."
			enter_guess
			while letter_already_played?
				puts "You've already played that letter. Enter another."
				enter_guess
			end
			letter_included? ? reveal_letter(@guess) : @wrong_guesses_remaining -= 1
			add_played_letter
		end
		@guess == @word ? player_wins : player_loses
	end

	def enter_guess
		@guess = ""
		until @guess.downcase =~ /[a-z]/
			@guess = gets.chomp
			puts "That is not a letter! Please enter a letter." unless @guess.downcase =~ /[a-z]/
		end
	end

	def letter_already_played?
	end

	def letter_included?
	end

	def reveal_letter(guess)
	end

	def add_played_letter
		@played_letters << @guess.downcase
	end

	def player_wins
	end

	def player_loses
	end

end