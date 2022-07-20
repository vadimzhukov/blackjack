class Deck
  attr_reader :deck

  NOMINALS = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10, 'K' => 10,
               'A' => 11 }
  SUITES = ["\u2660".encode('UTF-8'), "\u2663".encode('UTF-8'), "\u2665".encode('UTF-8'), "\u2666".encode('UTF-8')]

  # Create array of deck of cards
  @cards = {}
  NOMINALS.each do |key, value|
    SUITES.each do |suite|
      @cards[key + suite] = value
    end
  end

  def initialize
    @deck = self.class.cards.to_a.shuffle
  end

  class << self
    attr_reader :cards
  end

  def pop_card
    @deck.pop
  end
end
