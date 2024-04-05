module Mastermind
  COLORS = ["red", "orange", "yellow", "green", "blue", "violet"]
  class Game
    attr_accessor :guess
    def initialize
      @code = []
      @guess = []
    end
    def play
      randomize_code
      p @code
    end
    private
    attr_reader :code
    def randomize_code
      4.times do
        @code.push(COLORS[rand(0..5)])
      end
    end
  end
end

include Mastermind

Game.new.play

