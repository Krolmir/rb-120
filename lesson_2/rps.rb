module HelperMethods
  SLEEP = 0.5

  def prompt(msg)
    puts "=> #{msg}"
  end

  def clear
    system('clear') || system('cls')
  end

  def rest
    sleep(SLEEP)
  end

  def new_line
    puts " "
  end

  def small_spacer
    puts '---------------------------'
  end

  def big_spacer
    puts "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
  end
end

module Displayable
  include HelperMethods
  AMOUNT_OF_WINS_NEEDED = 5

  def display_welcome_message
    prompt("Welcome to Rock, Paper, Scissor, Lizard and Spock! This is a " \
           "first to #{AMOUNT_OF_WINS_NEEDED} wins! Goodluck!")
  end

  def display_goodbye_message
    prompt("Thanks for playing Rock, Paper, Scissors, Lizard and Spock. Good "\
           "bye!")
  end

  def display_moves
    small_spacer
    rest
    prompt("#{human.name} chose #{human.move}.")
    rest
    prompt("#{computer.name} chose #{computer.move}.")
    small_spacer
  end

  def display_winner(hum, comp)
    if hum > comp
      rest
      prompt("#{hum} #{hum.action(comp)} "\
             "#{comp}")
      prompt("Point for #{human.name}!")
    elsif comp > hum
      rest
      prompt("#{comp} #{comp.action(hum)} "\
             "#{hum}")
      prompt("Point for #{computer.name}!")
    else
      rest
      prompt("It's a tie!")
    end
  end

  def display_grand_winner
    if score.human_total == AMOUNT_OF_WINS_NEEDED
      big_spacer
      prompt("Congratulations #{human.name}. You have won in the race to "\
             "#{AMOUNT_OF_WINS_NEEDED} wins!")
      new_line
      big_spacer
    elsif score.computer_total == AMOUNT_OF_WINS_NEEDED
      prompt("Sorry #{human.name}, but you have lost. #{computer.name} has won"\
             " in the race to #{AMOUNT_OF_WINS_NEEDED} wins. Better luck next "\
             "time.")
    end
  end

  def display_player
    clear
    prompt("#{human.name} VS #{computer.name}")
  end

  def display_name_rules
    prompt("Please enter your name:")
    prompt("Must contain 1-10 characters")
    prompt("Numbers and letters only")
  end

  def display_score(player1, computer)
    rest
    small_spacer
    puts "Score: #{player1}: #{human_total}"
    puts "       #{computer}: #{computer_total}"
    small_spacer
    new_line
  end

  def display_name_error
    prompt("Sorry, you must enter a valid name. Try Again.")
  end

  def display_choose_move
    prompt("Please choose 'r' of 'rock' for rock , 'p' or 'paper' for paper, "\
           "'sc' or 'scissors' for scissors, 'l' or 'lizard for lizard OR 'sp'"\
           " or 'spock' for spock:")
  end

  def display_choose_error
    prompt("Sorry, invalid choice.")
  end

  def display_new_opponent_option
    prompt("Would you like a new opponent? (y/n)")
  end

  def display_yes_no_error
    prompt("Sorry, must be y or n.")
  end

  def display_play_again_prompt
    prompt("Would you like to play again? (y/n)")
  end

  def display_tracker
    new_line
    puts "#{human.name} move tracker!"
    small_spacer
    Move.move_tracker(Move.human_history)
    small_spacer
    new_line
    puts "Computer move tracker!"
    small_spacer
    Move.move_tracker(Move.computer_history)
    small_spacer
  end
end

class Score
  include Displayable
  attr_reader :human_total, :computer_total

  def initialize
    @human_total = 0
    @computer_total = 0
  end

  def human_win
    @human_total += 1
  end

  def computer_win
    @computer_total += 1
  end
end

class Move
  include Displayable
  VALUES = ['r', 'p', 'sc', 'l', 'sp', 'rock', 'paper', 'scissors', 'lizard',
            'spock']
  attr_reader :value

  @@human_history = { 'Rock' => 0,
                      'Paper' => 0,
                      'Scissors' => 0,
                      'Lizard' => 0,
                      'Spock' => 0 }
  @@computer_history = { 'Rock' => 0,
                         'Paper' => 0,
                         'Scissors' => 0,
                         'Lizard' => 0,
                         'Spock' => 0 }

  def initialize(value, player)
    if player.human?
      @@human_history[value] += 1
    else
      @@computer_history[value] += 1
    end
    @value = value
  end

  def self.human_history
    @@human_history
  end

  def self.computer_history
    @@computer_history
  end

  def self.move_tracker(history_hash)
    history_hash.each do |key, value|
      puts "#{key}: #{value}"
    end
  end
end

class Rock < Move
  def action(_)
    'crushes'
  end

  def >(other_move)
    other_move.class == Scissors || other_move.class == Lizard
  end

  def to_s
    'Rock'
  end
end

class Paper < Move
  def action(other_move)
    action = 'covers' if other_move.class == Rock
    action = 'disproves' if other_move.class == Spock
    action
  end

  def >(other_move)
    other_move.class == Rock || other_move.class == Spock
  end

  def to_s
    'Paper'
  end
end

class Scissors < Move
  def action(other_move)
    action = 'cuts' if other_move.class == Paper
    action = 'decapitates' if other_move.class == Lizard
    action
  end

  def >(other_move)
    other_move.class == Paper || other_move.class == Lizard
  end

  def to_s
    'Scissors'
  end
end

class Lizard < Move
  def action(other_move)
    action = 'poisons' if other_move.class == Spock
    action = 'eats' if other_move.class == Paper
    action
  end

  def >(other_move)
    other_move.class == Paper || other_move.class == Spock
  end

  def to_s
    'Lizard'
  end
end

class Spock < Move
  def action(other_move)
    action = 'smashes' if other_move.class == Scissors
    action = 'vaporizes' if other_move.class == Rock
    action
  end

  def >(other_move)
    other_move.class == Scissors || other_move.class == Rock
  end

  def to_s
    'Spock'
  end
end

class Player
  include Displayable
  attr_accessor :move, :name

  def initialize
    set_name
  end

  def create_move(move)
    case move
    when 'r', 'rock' then Rock.new('Rock', self)
    when 'p', 'paper' then Paper.new('Paper', self)
    when 'sc', 'scissors' then Scissors.new('Scissors', self)
    when 'l', 'lizard' then Lizard.new('Lizard', self)
    when 'sp', 'spock' then Spock.new('Spock', self)
    end
  end
end

class Human < Player
  def set_name
    n = ""

    loop do
      rest
      display_name_rules
      n = gets.chomp
      clear
      break unless n.empty? || n.size > 10 || n =~ /[^A-Za-z0-9]+/
      display_name_error
    end
    self.name = n
  end

  def choose_move
    choice = nil
    loop do
      rest
      display_choose_move
      choice = gets.chomp.downcase
      break if Move::VALUES.include? choice
      display_choose_error
    end
    self.move = create_move(choice)
  end

  def human?
    true
  end
end

class Computer < Player
  @@value_array = []

  @@lose_percentage = { 'Rock' => 0,
                        'Paper' => 0,
                        'Scissors' => 0,
                        'Lizard' => 0,
                        'Spock' => 0 }

  @@win_history = { 'Rock' => [],
                    'Paper' => [],
                    'Scissors' => [],
                    'Lizard' => [],
                    'Spock' => [] }

  def set_name
    self.name = ['R2D2', 'Hal', 'Chapie', 'The Thing', 'Captain Kirk'].sample
  end

  def self.lose_percentage_to_array
    Computer.hash_to_lose_percentage
    @@value_array = []
    @@lose_percentage.each do |key, value|
      case value
      when 0..30
        3.times { @@value_array << key }
      when 31..60
        2.times { @@value_array << key }
      when 61..100
        1.times { @@value_array << key }
      end
    end
  end

  def self.hash_to_lose_percentage
    @@win_history.each do |key, value|
      if value.empty?
        lose_percentage = 0
      else
        lose_percentage = (value.reduce(:+) / value.size.to_f) * 100
      end
      @@lose_percentage[key] = lose_percentage
    end
  end

  def self.add_to_history_array(key, value)
    @@win_history[key] << value
  end

  def self.win_history
    @@win_history
  end

  def choose_move
    self.move = if name == 'Captain Kirk'
                  create_move(['spock', 'paper'].sample)
                elsif name == 'The Thing'
                  create_move('rock')
                elsif @@value_array.empty?
                  create_move(Move::VALUES.sample)
                else
                  create_move(@@value_array.sample.downcase)
                end
  end

  def human?
    false
  end
end

class RPSGame
  include Displayable

  attr_accessor :human, :computer, :score

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = Score.new
  end

  def update_score(human, computer)
    if human > computer
      score.human_win
      Computer.add_to_history_array(computer.value, 1)
    elsif computer > human
      score.computer_win
      Computer.add_to_history_array(computer.value, 0)
    end
  end

  def new_computer?
    answer = nil

    loop do
      display_new_opponent_option
      answer = gets.chomp.downcase
      break if ['y', 'n', 'yes', 'no'].include? answer
      display_yes_no_error
    end

    answer == 'y' || answer == 'yes'
  end

  def play_again?
    answer = nil

    loop do
      display_play_again_prompt
      answer = gets.chomp.downcase
      break if ['y', 'n', 'yes', 'no'].include? answer
      display_yes_no_error
    end

    answer == 'y' || answer == 'yes'
  end

  def reset_game
    self.score = Score.new
    old_comp = computer.name
    @computer = Computer.new if new_computer?
    loop do
      break unless old_comp == computer.name
      @computer = Computer.new
    end
    clear
  end

  def grand_winner?
    score.human_total == AMOUNT_OF_WINS_NEEDED ||
      score.computer_total == AMOUNT_OF_WINS_NEEDED
  end

  def choosing_moves
    human.choose_move
    computer.choose_move
  end

  def update_cycle
    update_score(human.move, computer.move)
    score.display_score(human.name, computer.name)
    Computer.lose_percentage_to_array
  end

  def play
    display_welcome_message

    loop do
      choosing_moves
      display_player
      display_moves
      display_winner(human.move, computer.move)
      update_cycle

      if grand_winner?
        display_grand_winner
        display_tracker
        play_again? ? reset_game : break
      end
    end

    display_goodbye_message
  end
end

RPSGame.new.play
