# frozen_string_literal: true
require 'pry-byebug'

# This houses the components of the Mastermind game
module Mastermind
  COLORS = ["red", "orange", "yellow", "green", "blue", "violet"]
  ROLES = ["creator", "guesser"]
  CLUES = ["O", "X", "C"]
  class Game
    attr_accessor :guesses_remaining, :tries
    attr_reader :players 

    def initialize(player_1, player_2)
      @guesses_remaining = 12
      @tries = 0
      @players = [player_1.new(self), player_2.new(self)]
    end

    def play
      @players[0].choose_role
      if @players[0].role == ROLES[1]
        @players[1].randomize_secret_code 
        loop do
          @players[0].guess_colors(@players[0].guess)
          if human_correct_guess?
            puts "You guessed correctly (#{@players[1].secret_code}) in #{@tries} #{@tries > 1 ? 'tries' : 'try'}"
            return
          elsif @guesses_remaining == 0
            puts "Game over. You ran out of guesses(#{@tries})."
            puts "The code was #{@players[1].secret_code}"
            return
          else
            give_guess_result
            @players[1].give_clue(@players[1].secret_code, @players[0].guess)
            @players[0].guess = []
            @players[1].clue = []
          end
        end
      else
        @players[0].build_secrect_code(@players[0].secret_code)
        COLORS.each_index do |i|
          @players[1].guess_colors(@players[0].secret_code, @players[1].guess, @players[0].previous_clue, COLORS[i])
          if computer_correct_guess?
            puts "Computer guessed correctly (#{@players[0].secret_code}) in #{@tries} #{@tries > 1 ? 'tries' : 'try'}"
            return
          elsif @guesses_remaining == 0
            puts "Game over. You ran out of guesses(#{@tries})."
            puts "The code was #{@players[0].secret_code}"
            return
          else
            give_guess_result
            @players[0].give_clue(@players[0].secret_code, @players[1].guess)
            @players[0].previous_clue = @players[0].clue
            @players[0].clue = []
          end
        end
      end
    end

    private

    attr_accessor :guess, :clue

    def human_correct_guess?
      @players[0].guess == @players[1].secret_code
    end

    def computer_correct_guess?
      @players[1].guess == @players[0].secret_code
    end

    def give_guess_result
      puts "#{@players[0].role == ROLES[1] ? "Your guess: #{@players[0].guess}" : "Computer's guess: #{@players[1].guess}"} is incorrect. (#{@guesses_remaining} #{@guesses_remaining > 1 ? 'guesses' : 'guess'} remaining)"
    end
  end

  class Player
    attr_accessor :role, :secret_code, :guess, :clue

    def initialize(game)
      @game = game
      @role = ''
      @secret_code = []
      @guess = []
      @clue = []
    end

    def give_clue(secret_code, guess)
      incorrect = {guess: [], secret_code: []}

      # looks for matches first then include incorrect guesses in the 'incorrect' hash
      guess.each_index do |i| 
        if guess[i] == secret_code[i]
          @clue.push(CLUES[0])
        else
          @clue.push(CLUES[1])
          incorrect[:guess][i] = guess[i]
          incorrect[:secret_code][i] = secret_code[i]
        end
      end

      # looks for colors in the wrong positions
      incorrect[:guess].each_index do |i|
        if incorrect[:secret_code].include?(incorrect[:guess][i]) && incorrect[:guess][i] != nil
          @clue[i] = CLUES[2]
        end
      end

      puts "---------------------------------------"
      puts "Here's a clue: #{@clue}"
      puts "O - exact match"
      puts "X - wrong color"
      puts "C - correct color, wrong position"
      puts "---------------------------------------"
    end
  end

  class HumanPlayer < Player
    attr_accessor :previous_clue

    def initialize(game)
      super
      @previous_clue = []
    end

    def choose_role
      loop do
        puts "Choose a role: #{ROLES}"
        begin
          role = gets.chomp
          raise unless ROLES.include?(role)
        rescue StandardError
          puts 'Invalid input! Try again...'
        else 
          @game.players[0].role = role
          @game.players[1].role = role == ROLES[0] ? ROLES[1] : ROLES[0]
          break
        end
      end 
    end

    def guess_colors(arr)
      build_color_combo(arr)
      @game.tries += 1
      @game.guesses_remaining -= 1
    end

    def build_secrect_code(arr)
      build_color_combo(arr)
    end

    private

    def build_color_combo(arr)
      i = 1
      loop do
        puts "Possible colors: #{COLORS}\nChoose a color for position #{i}"
        begin
          choice = gets.chomp
          raise unless COLORS.include?(choice)
        rescue StandardError
          puts 'Invalid input! Try again...'
        else 
          arr.push(choice)
          i += 1
          break if i == 5
        end
      end
    end
  end

  class ComputerPlayer < Player
    def randomize_secret_code
      4.times do
        @secret_code.push(COLORS[rand(0..5)])
      end
    end

    def guess_colors(secrect_code, guess, clue, color)
      build_color_combo(secrect_code, guess, clue, color)
      @game.tries += 1
      @game.guesses_remaining -= 1
    end

    private

    def build_color_combo(secrect_code, guess, clue, color)
      if clue == []
        4.times do 
          guess.push(COLORS[0])
        end
      else  
        clue.each_index do |i|
          if clue[i] == "O"
            guess[i] = secrect_code[i]
          else
            guess[i] = color
          end
        end
      end 
    end

  end
end

include Mastermind

Game.new(HumanPlayer, ComputerPlayer).play
