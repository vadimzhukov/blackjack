require 'pry'
class Main
end

class Game
  CLI_MESSAGES = {
    hello: "=== Добро пожаловать в игру Black Jack ===",
    ask_name: "Введите ваше имя: ",
    instructions: "вы будете играть против компьтера. Суть игры - набрать как можно больше очков, но не более 21. Удачи!",
    serving: "--- Раздача карт ---",
    ask_action: "Введите номер действия:\n",
    new_round: "------------------------------- Новый раунд -----------------------"
  }

  ACTIONS = [
    {number: 1, message: "Взять карту", action: :take_card},
    {number: 2, message: "Пропустить", action: :computer_action},
    {number: 3, message: "Открыть карты", action: :open_cards},
    {number: 4, message: "Завершить игру", action: :end}
  ]

  INITIAL_BUDGET = 100
  BET = 10
  COMPUTER_SCORES_THRESHOLD = 17

  attr_reader :round_num, :player, :bank, :deck

  def initialize
    puts CLI_MESSAGES[:hello]
    print CLI_MESSAGES[:ask_name]
    @name = gets.chomp
    @player = Player.new(@name, :human, INITIAL_BUDGET)
    @computer = Player.new("Comp", :computer, INITIAL_BUDGET)
    @bank = 0
    @winner = nil
    @finish_game = false
    puts "#{@name}, #{CLI_MESSAGES[:instructions]}"
  end

  def initial_destribution
    puts CLI_MESSAGES[:new_round]
    puts "Ваш бюджет: #{@player.budget}$   ставка: #{BET}$"
    @deck = Deck.new
    @bank = 0
    take_bets
    puts CLI_MESSAGES[:serving]
    @player.hand = []
    @computer.hand = []
    
    2.times do
      ObjectSpace.each_object(Player).each do |pl|
        pl.hand << @deck.pop_card
      end
    end
    puts "Ваши карты: |#{@player.hand[0][0]}| |#{@player.hand[1][0]}| (#{@player.hand[0][1]+@player.hand[1][1]} очков)     Карты компьютера: |*|  |*|"
  end

  def take_bets
    @player.bet(BET)
    @computer.bet(BET)
    ObjectSpace.each_object(Player).each do |pl|
      @bank += BET
    end
    puts "Ставки сделаны, в банке #{@bank}$"
  end

  def player_action
    puts CLI_MESSAGES[:ask_action]
    ACTIONS.each do |a|
      puts "#{a[:number]}: #{a[:message]}"
    end
    @player_action = gets.chomp
    case @player_action
      when "1"
        @player.take_card(deck)
        computer_action
      when "2"
        computer_action
      when "3"
        open_cards
      when "4"
        @finish_game = true
    end
  end

  def computer_action
    if @computer.hand_score >= COMPUTER_SCORES_THRESHOLD
      puts "Компютер не стал брать карту"
    else
      @computer.take_card(deck, :computer)
    end
    open_cards
  end

  def open_cards
    puts "==== Вскрываем карты ===="
    puts "Ваши карты: #{@player.show_cards} (#{@player.hand_score} очков)"
    puts "Карты компьютера: #{@computer.show_cards} (#{@computer.hand_score} очков)"
    game_over
  end

  def define_winner
    score1 = @player.hand_score
    score2 = @computer.hand_score

    if score1 <= 21
      if score1 > score2 || score2 > 21
        @winner = @player
      elsif score1 < score2 && score2 <= 21
        @winner = @computer
      elsif (score1 == score2)
        @winner = "none"
      end
    elsif score1 > 21 && score2 <= 21
      @winner = @computer
    elsif score1 > 21 && score2 > 21
      @winner = "none"
    end
  end

  def give_reward
    if @winner == @player
      @player.get_winnings(@bank)
      puts "Вы выиграли, ваш выигрыш составил #{@bank}$, ваш бюджет #{@player.budget}$"
    elsif @winner == @computer
      @computer.get_winnings(@bank)
      puts "Вы проиграли, ваш бюджет #{@player.budget}$"
    else
      @player.get_winnings(@bank / 2)
      @computer.get_winnings(@bank / 2)
      puts "Ничья, ваш бюджет #{@player.budget}$"
    end

  end

  def game_over
    define_winner
    give_reward
    print "Желаете продолжить игру? [any/n]:"
    action = gets
    if action.strip == "n"
      @finish_game = true
    end
  end

  def finish_game
    @finish_game
  end

end

class Player

  attr_reader :budget
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
      @hand.map{|card| "|#{card[0]}|"}.join(' ')
    else
      @hand.map{|card| "|*|"}.join(' ')
    end
  end

  def hand_score
    if @hand.sum{|card| card[1]} > 21 && @hand.any?{|card| card[0][0] == "A"}
      @hand.sum{|card| card[1]} - 10
    else
      @hand.sum{|card| card[1]}
    end
  end

  def take_card(deck, player = :user)
    card = deck.pop_card
    if player == :user
      @hand << card
      puts "Вы взяли карту |#{card[0]}|, ваши карты: #{show_cards} (#{hand_score} очков)"
    else
      @hand << card
      puts "Компьютер берет карту, карты компьютера: #{show_cards(:hidden)}"
    end
  end

  private

  def budget=(sum)
    @budget = sum
  end

end

class Deck
  attr_reader :deck
  
  NOMINALS = {"2"=>2, "3"=>3, "4"=>4, "5"=>5, "6"=>6, "7"=>7, "8"=>8, "9"=>9, "10"=>10,"J"=>10, "Q" => 10, "K" => 10, "A" => 11}
  SUITES = ["\u2660".encode("UTF-8"), "\u2663".encode("UTF-8"), "\u2665".encode("UTF-8"), "\u2666".encode("UTF-8")]
 
  @cards = {}
  NOMINALS.each do |key, value|
    SUITES.each do |suite|
      @cards[key+suite] = value
    end
  end

  def self.cards
    @cards
  end

  def initialize
    @deck = self.class.cards.to_a.shuffle
  end
  
  def pop_card
    @deck.pop
  end
end

game = Game.new

loop do
  game.initial_destribution
  game.player_action
  break if game.finish_game
end

