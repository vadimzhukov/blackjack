# frozen_string_literal: true

require 'pry'
class Main
end

require_relative 'deck'
require_relative 'player'
require_relative 'game'

game = Game.new

loop do
  game.initial_destribution
  game.player_action
  break if game.finish_game
end
