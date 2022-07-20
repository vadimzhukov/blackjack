# frozen_string_literal: true

require_relative 'deck'
require_relative 'player'

class Game
  CLI_MESSAGES = {
    hello: '=== Добро пожаловать в игру Black Jack ===',
    ask_name: 'Введите ваше имя: ',
    instructions: 'вы будете играть против компьтера. Суть игры - набрать как можно больше очков, но не более 21. Удачи!',
    serving: '--- Раздача карт ---',
    ask_action: "Введите номер действия:\n",
    new_round: '--------------------------- Новый раунд ---------------------------'
  }.freeze

  ACTIONS = [
    { number: 1, message: 'Взять карту', action: :take_card },
    { number: 2, message: 'Пропустить', action: :computer_action },
    { number: 3, message: 'Открыть карты', action: :open_cards },
    { number: 4, message: 'Завершить игру', action: :end }
  ].freeze

  INITIAL_BUDGET = 100
  BET = 10
  COMPUTER_SCORES_THRESHOLD = 17

  attr_reader :round_num, :player, :bank, :deck, :finish_game

  def initialize
    puts CLI_MESSAGES[:hello]
    print CLI_MESSAGES[:ask_name]
    @name = gets.chomp
    @player = Player.new(@name, :human, INITIAL_BUDGET)
    @computer = Player.new('компьютер', :computer, INITIAL_BUDGET)
    @bank = 0
    @winner = nil
    @finish_game = false
    puts "#{@name}, #{CLI_MESSAGES[:instructions]}"
  end

  def initial_destribution
    puts CLI_MESSAGES[:new_round]
    puts "Ваш бюджет: #{@player.budget}$  |  бюджет компьютера: #{@computer.budget}$   ставка: #{BET}$"
    @deck = Deck.new
    @bank = 0
    take_bets
    puts CLI_MESSAGES[:serving]
    @player.hand = []
    @computer.hand = []
    serve_cards
    @player.print_status
    @computer.print_status(:hidden)
  end

  def serve_cards
    2.times do
      ObjectSpace.each_object(Player).each do |pl|
        pl.hand << @deck.pop_card
      end
    end
  end

  def take_bets
    @player.bet(BET)
    @computer.bet(BET)
    ObjectSpace.each_object(Player).each do |_pl|
      @bank += BET
    end
    puts "Ставки сделаны, в банке #{@bank}$"
  end

  def action_request
    puts CLI_MESSAGES[:ask_action]
    ACTIONS.each do |a|
      puts "#{a[:number]}: #{a[:message]}"
    end
  end

  def player_action
    action_request
    @player_action = gets.chomp

    case @player_action
    when '1'
      @player.take_card(deck)
      computer_action
    when '2'
      computer_action
    when '3'
      open_cards
    when '4'
      @finish_game = true
    end
  end

  def computer_action
    if @computer.hand_score >= COMPUTER_SCORES_THRESHOLD
      puts 'Компютер не стал брать карту'
    else
      @computer.take_card(deck, :computer)
    end
    open_cards
  end

  def open_cards
    puts '------- Вскрываем карты -------'
    @player.print_status
    @computer.print_status
    define_winner
    give_reward
    game_over
  end

  def define_winner
    score1 = @player.hand_score
    score2 = @computer.hand_score
    @winner = if score1 <= 21 && score2 <= 21
                if score1 > score2
                  @player
                else
                  score1 < score2 ? @computer : 'none'
                end
              elsif score1 <= 21 && score2 > 21
                @player
              elsif score1 > 21 && score2 <= 21
                @computer
              else
                'none'
              end
  end

  def give_reward
    if @winner == @player
      @player.get_winnings(@bank)
      puts "Вы выиграли, ваш выигрыш составил #{@bank}$, ваш бюджет #{@player.budget}$, бюджет компьютера: #{@computer.budget}$"
    elsif @winner == @computer
      @computer.get_winnings(@bank)
      puts "Вы проиграли, ваш бюджет #{@player.budget}$, бюджет компьютера: #{@computer.budget}$"
    else
      @player.get_winnings(@bank / 2)
      @computer.get_winnings(@bank / 2)
      puts "Ничья, ваш бюджет #{@player.budget}$, бюджет компьютера: #{@computer.budget}$"
    end
  end

  def check_budgets
    if @player.budget <= 0
      puts 'Вы проиграли все деньги, продолжить игру невозможно. Вы держитесь там, здоровья вам и всего наилучшего!'
      @finish_game = true
      return false
    elsif  @computer.budget <= 0
      puts 'Вы выиграли все деньги у компьютера! Поздравляем, продолжить можно будет через минуту, когда компьютер остынет'
      @finish_game = true
      return false
    end
    true
  end

  def game_over
    print 'Желаете продолжить игру? [any/n]:' if check_budgets
    action = gets
    @finish_game = true if action.strip.upcase == 'N'
  end
end
