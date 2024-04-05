# frozen_string_literal: true

# This houses the components of the Mastermind game
module Mastermind
  COLORS = ["red", "orange", "yellow", "green", "blue", "violet"]
  class Game
    @@guesses_remaining = 12
    @@tries = 0
    def initialize
      @code = []
      @guess = []
      @clue = []
    end

    def play
      randomize_code
      loop do
        make_guess
        if correct_guess?
          puts "You guessed correctly (#{@code}) in #{@@tries} #{@@tries > 1 ? 'tries' : 'try'}"
          return
        elsif @@guesses_remaining == 0
          puts "Game over. You ran out of guesses(#{@@tries})."
          puts "The code was #{@code}"
          return
        else
          give_guess_result
          give_clue(@code, @guess)
          @guess = []
          @clue = []
        end
      end
    end

    private

    attr_accessor :guess, :clue
    attr_reader :code

    def randomize_code
      4.times do
        @code.push(COLORS[rand(0..5)])
      end
    end

    def make_guess
      i = 1
      loop do
        puts "Guess one of #{COLORS} for position #{i}"
        begin
          guess = gets.chomp
          raise unless COLORS.include?(guess)
        rescue StandardError
          puts 'Invalid input! Try again...'
        else 
          @guess.push(guess)
          i += 1
          break if i == 5
        end
      end
      @@tries += 1
      @@guesses_remaining -= 1
    end
    
    def correct_guess?
      @code == @guess
    end

    def give_guess_result
      puts "Your guess: #{@guess} is incorrect. (#{@@guesses_remaining} #{@@guesses_remaining > 1 ? 'guesses' : 'guess'} remaining)"
    end

    def give_clue(code, guess)
      incorrect = {guess: [], code: []}

      # looks for matches first then include incorrect guesses in the 'incorrect' hash
      guess.each_index do |i| 
        if guess[i] == code[i]
          @clue.push("correct")
        else
          @clue.push("incorrect")
          incorrect[:guess][i] = guess[i]
          incorrect[:code][i] = code[i]
        end
      end

      # looks for colors in the wrong positions
      incorrect[:guess].each_index do |i|
        if incorrect[:code].include?(incorrect[:guess][i]) && incorrect[:guess][i] != nil
          @clue[i] = "wrong spot"
        end
      end

      puts "Here's your clue: #{@clue}"
    end
  end
end

include Mastermind

Game.new.play
