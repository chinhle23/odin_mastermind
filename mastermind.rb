# frozen_string_literal: true

require 'pry-byebug'

# This houses the components of the Mastermind game
module Mastermind
  COLORS = %w[red orange yellow green blue violet].freeze
  ROLES = %w[creator guesser].freeze
  CLUES = %w[O X C].freeze

  # This houses the logics of the game
  class Game
    attr_accessor :guesses_remaining, :tries
    attr_reader :players 

    def initialize(player1, player2)
      @guesses_remaining = 12
      @tries = 0
      @players = [player1.new(self), player2.new(self)]
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
          elsif @guesses_remaining < 1
            puts "Game over. You ran out of guesses(#{@tries})."
            puts "The code was #{@players[1].secret_code}"
            return
          else
            give_guess_result
            @players[1].display_clue(@players[1].secret_code, @players[0].guess)
            @players[0].guess = []
            @players[1].clue = []
          end
        end
      else
        @players[0].build_secrect_code(@players[0].secret_code)

        loop do
          @players[1].guess_colors(@players[1].guess, @players[0].previous_clue)
          if computer_correct_guess?
            puts "Computer guessed correctly (#{@players[0].secret_code}) in #{@tries} #{@tries > 1 ? 'tries' : 'try'}"
            return
          elsif @guesses_remaining < 1
            puts "Game over. You ran out of guesses(#{@tries})."
            puts "The code was #{@players[0].secret_code}"
            return
          else
            give_guess_result
            @players[0].display_clue(@players[0].secret_code, @players[1].guess)
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
      human_player_guess = "Your guess: #{@players[0].guess}"
      computer_player_guess = "Computer's guess: #{@players[1].guess}"
      puts "#{@players[0].role == ROLES[1] ? human_player_guess : computer_player_guess} is incorrect."
      puts "(#{@guesses_remaining} #{@guesses_remaining > 1 ? 'guesses' : 'guess'} remaining)"
    end
  end

  # This houses the basic components of any player
  class Player
    attr_accessor :role, :secret_code, :guess, :clue

    def initialize(game)
      @game = game
      @role = ''
      @secret_code = []
      @guess = []
      @clue = []
      @incorrect = { guess: [], secret_code: [] }
    end

    def display_clue(secret_code, guess)
      build_clue(secret_code, guess)

      puts '---------------------------------------'
      puts "Here's a clue: #{@clue}"
      puts 'O - exact match'
      puts 'X - wrong color'
      puts 'C - correct color, wrong position'
      puts '---------------------------------------'
    end
  end

  private

  attr_accessor :incorrect

  def build_clue(secret_code, guess)
    @incorrect = { guess: [], secret_code: [] }

    # looks for matches first then include incorrect guesses in the 'incorrect' hash
    exact_match_clue(secret_code, guess)

    # looks for colors in the wrong positions
    wrong_position_clue
  end

  def exact_match_clue(secret_code, guess)
    guess.each_index do |i|
      if guess[i] == secret_code[i]
        @clue.push(CLUES[0])
      else
        @clue.push(CLUES[1])
        @incorrect[:guess][i] = guess[i]
        @incorrect[:secret_code][i] = secret_code[i]
      end
    end
  end

  def wrong_position_clue
    incorrect[:guess].each_index do |i|
      @clue[i] = CLUES[2] if @incorrect[:secret_code].include?(@incorrect[:guess][i]) && !@incorrect[:guess][i].nil?
    end
  end

  # This houses the components specific to a human player
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

  # This houses the components specific to a computer player
  class ComputerPlayer < Player
    attr_accessor :possible_guesses

    def initialize(game)
      super
      @possible_guesses = []
    end

    def randomize_secret_code
      4.times do
        @secret_code.push(COLORS[rand(0..5)])
      end
    end

    def guess_colors(guess, clue)
      build_color_combo(guess, clue)
      @game.tries += 1
      @game.guesses_remaining -= 1
    end

    private

    def build_color_combo(guess, clue)
      build_possible_guesses
      if clue == []
        guess.replace(%w[red orange yellow green])
      else
        clue.each_index do |i|
          if clue[i] == 'O'
            @possible_guesses.select! { |item| item[i] == guess[i] }
          elsif clue[i] == 'X'
            @possible_guesses.reject! { |item| item[i] == guess[i] }
          else
            @possible_guesses.select! { |item| item[i] != guess[i] && item.include?(guess[i]) }
          end
        end
        guess.replace(@possible_guesses[0])
      end
    end

    def build_possible_guesses
      possible_guess = []
      COLORS.each_index do |i|
        COLORS.each_index do |j|
          COLORS.each_index do |k|
            COLORS.each_index do |l|
              possible_guess.push(COLORS[l], COLORS[k], COLORS[j], COLORS[i])
              @possible_guesses.push(possible_guess)
              possible_guess = []
            end
          end
        end
      end
    end
  end
end

include Mastermind

Game.new(HumanPlayer, ComputerPlayer).play
