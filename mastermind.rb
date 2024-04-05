module Mastermind
  COLORS = ["red", "orange", "yellow", "green", "blue", "violet"]
  class Game
    def initialize
      @code = []
      @guess = []
    end
    def play
      randomize_code
      make_guess
      p @guess
    end
    private
    attr_accessor :guess
    attr_reader :code
    def randomize_code
      4.times do
        @code.push(COLORS[rand(0..5)])
      end
    end
    def make_guess
      i = 1
      loop do
        puts "Make guess #{COLORS} for position #{i}"
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
    end  
  end
end

include Mastermind

Game.new.play

