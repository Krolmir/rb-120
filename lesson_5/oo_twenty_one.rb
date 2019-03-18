module Helper
  def prompt(msg)
    puts "=> #{msg}"
  end

  def line_spacer
    puts ""
  end

  def clear
    system('clear') || system('cls')
  end

  def filler
    puts "-------------------"
  end

  def big_filler
    puts "--------------------------------"
  end

  def strip_brackets(element)
    element.to_s.delete(']').delete('[')
  end

  def pause
    sleep(1.5)
  end
end

class Player
  VALUE = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
            '8' => 8, '9' => 9, '1' => 10, 'J' => 10, 'Q' => 10, 'K' => 10,
            'A' => 11 }

  attr_accessor :cards, :name, :total

  def initialize(name = ' ')
    @cards = []
    @name = name
    @total = 0
  end

  def <<(card)
    cards << card
  end

  def calculate_total
    self.total = 0
    ace_count = 0
    cards.each do |card|
      if VALUE.values_at(card[1]) == [11]
        self.total += 11
        ace_count += 1
      else
        self.total += VALUE.values_at(card[1])[0]
      end
    end

    while ace_count > 0
      self.total = when_ace(self.total)
      ace_count -= 1
    end

    self.total
  end

  def when_ace(total)
    if total > 21
      total -= 10
    end

    total
  end
end

class Human < Player
  attr_accessor :bet_amount
  attr_writer :chips

  def initialize(chips)
    super
    @chips = chips
    @bet_amount = 0
  end

  def chips
    @chips.to_i
  end
end

class Deck
  RANK = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  SUIT = ['♣', '♥', '♠', '♦']

  attr_reader :deck

  def initialize
    @deck = RANK.map { |n| SUIT.map { |s| '|' + n + s + '|' } }.flatten
  end

  def shuffle_cards
    deck.shuffle!
  end

  def pop
    deck.pop
  end

  def deal_card(player)
    player.cards << pop
  end
end

class Table
  include Helper

  attr_reader :max_bet, :min_bet

  def initialize(min_bet, max_bet)
    @max_bet = max_bet
    @min_bet = min_bet
  end

  def initial_display(human, dealer)
    display_top
    puts "| Dealer:  #{dealer.cards[0]}|  "
    puts "|                                          |"
    puts "| Dealer total: "\
         "#{strip_brackets(Player::VALUE.values_at(dealer.cards[0][1]))}"
    display_bottom(human)
  end

  def display(human, dealer)
    display_top
    puts "| Dealer:  #{dealer.cards.join}"
    puts "|                                          |"
    puts "| Dealer total: #{dealer.total}"
    display_bottom(human)
  end

  def display_line_break
    puts "|__________________________________________|"
  end

  def display_top
    clear
    puts "                TWENTY ONE!                "
    line_spacer
    puts "Table Rules: "
    puts "Minimum Bet allowed: #{min_bet}"
    puts "Maximum Bet allowed: #{max_bet}"
    puts " __________________________________________"
    puts "|                                          |"
  end

  def display_bottom(human)
    display_line_break
    puts "|                                          |"
    puts "| Bankroll: #{human.chips}  Current Bet: #{human.bet_amount}"
    puts "|                                          |"
    puts "| #{human.name}:  #{human.cards.join} "
    puts "|                                          |"
    puts "| Current total: #{human.total}"
    display_line_break
    line_spacer
  end
end

class Game
  include Helper

  STARTING_CHIPS = 2500

  attr_accessor :deck
  attr_reader :human, :dealer, :table

  def initialize
    @deck = Deck.new
    @human = Human.new(STARTING_CHIPS)
    @dealer = Player.new("Dealer")
    @table = Table.new(20, 1000)
  end

  def play
    display_welcome_choose_name

    loop do
      placing_bets_dealing_cards
      main_gameflow_and_checking_early_wins

      if human.chips < table.min_bet
        break unless reload?
        reload_chips
      else
        break unless play_again?
      end

      reset_game
    end

    display_goodbye_message
  end

  def display_welcome_choose_name
    display_welcome_message
    choose_name
  end

  def placing_bets_dealing_cards
    place_bets
    display_dealing_cards
    pause
    deal_cards
    calculate_totals
    table.initial_display(human, dealer)
  end

  def main_gameflow_and_checking_early_wins
    if check_black_jack?(human)
      display_early_result
    elsif dealer_card_value_10_11?
      display_checking_blackjack
      pause
      if check_black_jack?(dealer)
        display_early_result
      else
        display_continue_message
        human_turn_dealer_turn_gameflow
      end
    else
      human_turn_dealer_turn_gameflow
    end
  end

  def display_welcome_message
    clear
    display_welcome_message_prompt
    action = gets.chomp.downcase
    display_rules if action == 'r' || action == 'rules'
  end

  def human_turn_dealer_turn_gameflow
    human_turn
    dealer_turn_with_show_result if !check_bust?(human)
  end

  def dealer_turn_with_show_result
    dealer_turn
    show_result
  end

  def choose_name
    clear
    name = ''
    loop do
      display_choose_name
      name = gets.chomp
      break unless name.size < 2 || name.size > 10 || name =~ /[^A-Za-z0-9]+/
      display_invalid_name
    end
    human.name = name
  end

  def place_bets
    table.display(human, dealer)

    bet = 0
    loop do
      display_place_bets_prompt
      bet = gets.chomp.to_i
      break if valid_bet_conditions?(bet)
      display_invalid_entry
    end
    human.bet_amount = bet
    human.chips -= bet
  end

  def valid_bet_conditions?(bet)
    bet >= table.min_bet && bet <= table.max_bet && bet <= human.chips
  end

  def deal_cards
    deck.shuffle_cards
    2.times do
      deck.deal_card(human)
      deck.deal_card(dealer)
    end
  end

  def calculate_totals
    human.calculate_total
    dealer.calculate_total
  end

  def check_black_jack?(player)
    player.total == 21
  end

  def dealer_card_value_10_11?
    strip_brackets(Player::VALUE.values_at(dealer.cards[0][1])) == '11' ||
      strip_brackets(Player::VALUE.values_at(dealer.cards[0][1])) == '10'
  end

  def display_early_result
    if human_blackjack?
      human.chips += (human.bet_amount + (human.bet_amount * 1.5))
      display_early_blackjack(human)
    else
      table.display(human, dealer)
      display_early_blackjack(dealer)
    end
  end

  def human_blackjack?
    human.total == 21
  end

  def human_turn
    loop do
      action = ''
      loop do
        initial_human_turn_display
        action = gets.chomp.downcase
        break if valid_move_input?(action)
      end

      human_hit_or_stay(action)
      break if stay?(action)

      updating_total_and_table
      human_bust_or_blackjack
      break if check_bust?(human) || human_blackjack?
    end
  end

  def updating_total_and_table
    human.calculate_total
    table.initial_display(human, dealer)
  end

  def initial_human_turn_display
    display_human_total
    display_hit_or_stay_prompt
  end

  def human_bust_or_blackjack
    if check_bust?(human)
      display_busted(human.name)
    elsif human_blackjack?
      display_human_total
      pause
    end
  end

  def human_hit_or_stay(action)
    if hit?(action)
      display_dealing_card
      pause
      deck.deal_card(human)
    elsif stay?(action)
      display_human_stay
      pause
    end
  end

  def valid_move_input?(action)
    action == 'h' || action == 'hit' || action == 'stay' || action == 's'
  end

  def hit?(action)
    action == 'hit' || action == 'h'
  end

  def stay?(action)
    action == 'stay' || action == 's'
  end

  def dealer_turn
    table.display(human, dealer)

    loop do
      dealer.calculate_total

      dealer_hit_or_stay
      break if dealer_stay?

      update_dealer_total_and_display

      if check_bust?(dealer)
        display_busted("Dealer")
        break
      end
    end
  end

  def update_dealer_total_and_display
    dealer.calculate_total
    table.display(human, dealer)
    display_dealer_total
    pause
  end

  def dealer_hit?
    dealer.total < 17
  end

  def dealer_stay?
    dealer.total >= 17
  end

  def dealer_hit_or_stay
    if dealer_hit?
      display_dealer_hits
      pause
      deck.deal_card(dealer)
    elsif dealer_stay?
      display_dealer_stays
      pause
    end
  end

  def check_bust?(player)
    player.total > 21
  end

  def show_result
    big_filler
    if check_bust?(dealer)
      display_human_win_with_dealer_bust
    elsif human_win?
      display_human_win
    elsif dealer_win?
      display_computer_win
    else
      display_tie
    end
    big_filler
  end

  def human_win?
    human.total > dealer.total && !check_bust?(human)
  end

  def dealer_win?
    dealer.total > human.total && !check_bust?(dealer)
  end

  def reload_chips
    human.chips = STARTING_CHIPS
  end

  def reload?
    display_reload_prompt

    action = ''
    loop do
      display_yes_no_prompt
      action = gets.chomp.downcase
      break if valid_action?(action)
      display_invalid_entry
    end
    if yes?(action)
      true
    else
      false
    end
  end

  def play_again?
    action = ''
    loop do
      display_play_again_prompt
      action = gets.chomp.downcase
      break if valid_action?(action)
      display_invalid_entry
    end
    if yes?(action)
      true
    else
      false
    end
  end

  def valid_action?(action)
    action == 'y' || action == 'yes' || action == 'n' || action == 'no'
  end

  def yes?(action)
    action == 'y' || action == 'yes'
  end

  def reset_game
    self.deck = Deck.new
    human.cards = []
    dealer.cards = []
    human.total = 0
    dealer.total = 0
    human.bet_amount = 0
  end

  def win_amount
    human.bet_amount * 2
  end

  def display_busted(player)
    prompt("#{player} has busted.")
  end

  def display_checking_blackjack
    prompt("Checking if dealer has blackjack...")
  end

  def display_choose_name
    big_filler
    prompt("Please enter a name: ")
    prompt("*Must be 2-10 characters")
    prompt("*Numbers and characters only")
    big_filler
  end

  def display_computer_win
    prompt("#{human.name} you have #{human.total}")
    prompt("#{dealer.name} has #{dealer.total}")
    prompt("Dealer has beaten you. Better luck next time.")
  end

  def display_continue_message
    prompt("Dealer does not have blackjack. Let us continue.")
  end

  def display_dealing_cards
    line_spacer
    prompt("Dealing cards...")
  end

  def display_dealing_card
    line_spacer
    prompt("Dealing card...")
  end

  def display_dealer_hits
    prompt("Dealer hits...")
  end

  def display_dealer_stays
    prompt("Dealer stays.")
  end

  def display_dealer_total
    prompt("Dealer has #{dealer.total}")
  end

  def display_early_blackjack(player)
    prompt("#{player.name} has BlackJack!")
    display_early_blackjack_win_message if player.class == Human
  end

  def display_early_blackjack_win_message
    prompt("#{human.name} you have won. "\
           "#{(human.bet_amount * 1.5) + human.bet_amount} has been added to"\
           " your bankroll! Congratulations.")
  end

  def display_goodbye_message
    prompt("You have cashed out #{human.chips}.  See you next time.")
  end

  def display_hit_or_stay_prompt
    prompt("Would you like to hit or stay: (Enter 'hit', 'h', 'stay' or 's')")
  end

  def display_human_stay
    prompt("#{human.name} you have stayed.")
  end

  def display_human_total
    prompt("#{human.name} you have #{human.total}")
  end

  def display_human_win
    prompt("#{human.name} you have #{human.total}")
    prompt("#{dealer.name} has #{dealer.total}")
    prompt("#{human.name} you have won. #{win_amount} has been"\
           " added to your bankroll! Congratulations.")
    human.chips += win_amount
  end

  def display_human_win_with_dealer_bust
    prompt("#{human.name} you have won. #{win_amount} has been"\
           " added to your bankroll! Congratulations.")
    human.chips += win_amount
  end

  def display_invalid_entry
    prompt("Invalid input. Please try again.")
  end

  def display_invalid_name
    prompt("Invalid name entry. Please follow the rules for inputing a "\
            "valid name")
  end

  def display_place_bets_prompt
    prompt("Please place your bet: (Must be within the range of the table"\
           "min/max and can not exceed your maximum bankroll)")
  end

  def display_play_again_prompt
    prompt("Would you like to play again? (Enter 'y', 'yes', 'n', or 'no')")
  end

  def display_reload_prompt
    prompt("#{human.name} you don't have enough chips for the minimum bet. "\
           "Would you like to reload your chips?")
  end

  def display_rules
    clear
    File.open("twenty_one_rules.txt").each do |line|
      puts line
    end
    prompt("Hit enter to continue:")
    gets
  end

  def display_tie
    prompt("#{human.name} you have #{human.total}")
    prompt("#{dealer.name} has #{dealer.total}")
    prompt("It's a tie. ")
    human.chips += human.bet_amount
  end

  def display_welcome_message_prompt
    prompt("Welcome to Twenty One! A modified version of BlackJack.")
    prompt("For a list of the full rules please type 'r' or 'rules: (hit "\
           "anything else to continue)")
  end

  def display_yes_no_prompt
    prompt("'y', 'yes', 'n', or 'no':")
  end
end

game_on = Game.new
game_on.play
