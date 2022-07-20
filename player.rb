class Player
  attr_reader :budget, :name
  attr_accessor :hand

  def initialize(name, type, budget)
    @name = name
    @type = type
    @budget = budget
    @hand = []
  end

  def get_winnings(sum)
    self.budget += sum
  end

  def bet(bet_sum)
    self.budget -= bet_sum
  end

  def show_cards(show = :opened)
    if show == :opened
      @hand.map { |card| "|#{card[0]}|" }.join(' ')
    else
      @hand.map { |_card| '|*|' }.join(' ')
    end
  end

  def hand_score
    if @hand.sum { |card| card[1] } > 21 && @hand.any? { |card| card[0][0] == 'A' }
      @hand.sum { |card| card[1] } - 10
    else
      @hand.sum { |card| card[1] }
    end
  end

  def take_card(deck, player = :user)
    card = deck.pop_card
    if player == :user
      hand << card
      puts "Вы взяли карту |#{card[0]}|"
      print_status
    else
      hand << card
      puts 'Компьютер берет карту'
      print_status(:hidden)
    end
  end

  def print_status(type = :visible)
    if type == :visible
      puts "Карты игрока #{name}: #{show_cards}  очков: #{hand_score}"
    else
      puts "Карты игрока #{name}: #{show_cards(:hidden)}"
    end
  end

  private

  attr_writer :budget
end
