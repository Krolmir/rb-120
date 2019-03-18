module Helper
  def prompt(msg)
    puts "=> #{msg}"
  end

  def filler
    puts "-------------------"
  end

  def big_filler
    puts "--------------------------------"
  end

  def clear
    system('clear') || system('cls')
  end

  def empty_line
    puts ""
  end

  def joinor(arr, del1 = ', ', del2 = 'or')
    return arr[0].to_s if arr.size == 1
    return arr[0].to_s + ' ' + del2 + ' ' + arr[1].to_s if arr.size == 2
    arr[-1] = "#{del2} #{arr.last}"
    arr.join(del1)
  end

  def pause
    sleep(1.5)
  end
end

module Displayable
  include Helper

  def display_welcome_message
    clear
    big_filler
    prompt("Welcome to Tic Tac Toe!")
    empty_line
    pause
    clear
  end

  def display_goodbye_message
    prompt("Thanks for playing Tic Tac Toe! Goodbye!")
  end

  def display_invalid_choice
    prompt("Sorry, that's not a valid choice.")
  end

  def display_play_again_prompt
    prompt("Would you like to play again? (y/n)")
  end

  def display_invalid_play_again_choice
    prompt("Sorry, must be y or n")
  end

  def display_lets_play_again
    prompt("Let's play again!")
  end

  def display_invalid_name
    prompt("Invalid name entry. Please follow the rules for inputing a "\
            "valid name")
  end
end

module Drawable
  def draw_square_line
    puts "     |     |"
  end

  def draw_spacer_line
    puts "-----+-----+-----"
  end

  def draw_top_section
    draw_square_line
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  "\
         "#{@squares[3]}"
    draw_square_line
  end

  def draw_mid_section
    draw_spacer_line
    draw_square_line
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  "\
         "#{@squares[6]}"
    draw_square_line
    draw_spacer_line
  end

  def draw_bottom_section
    draw_square_line
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  "\
         "#{@squares[9]}"
    draw_square_line
  end

  def draw_board
    draw_top_section
    draw_mid_section
    draw_bottom_section
  end
end

class Board
  include Helper, Drawable
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarkerd? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def three_identical_markers?(squares)
    temp = squares.select { |v| v.marker != ' ' }
    temp.size == 3 &&
      temp[0].marker == temp[1].marker &&
      temp[1].marker == temp[2].marker
  end

  def winning_marker
    marker = nil
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      marker = squares[0].marker if three_identical_markers?(squares)
    end
    marker
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def display(human, computer, score)
    big_filler
    prompt("#{human.name} is '#{human.marker}'. #{computer.name} "\
           "is '#{computer.marker}'.")
    big_filler
    score.display
    empty_line
    draw_board
    empty_line
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarkerd?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :name, :score, :marker

  def initialize(marker, name = ' ')
    @marker = marker
    @name = name
    @score = 0
  end
end

class Score
  include Helper
  attr_reader :player1, :player2

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end

  def display
    empty_line
    puts "We are playing first to #{TTTGame::GRAND_WINNER_TOTAL} wins."
    empty_line
    puts "Score Board:"
    filler
    puts "#{player1.name}: #{player1.score}"
    puts "#{player2.name}: #{player2.score}"
    filler
  end

  def update(player)
    player.score += 1
  end
end

class TTTGame
  include Displayable
  FIRST_TO_MOVE = 'X'
  GRAND_WINNER_TOTAL = 5

  attr_reader :board, :human, :computer, :count, :score

  def initialize
    @current_marker = FIRST_TO_MOVE
    @board = Board.new
    @human = Player.new('X')
    @computer = Player.new('O')
    @score = Score.new(@human, @computer)
  end

  def play
    choose_name_marker_and_display_welcome_message

    loop do
      board.display(human, computer, score)
      choose_move_gameplay
      update_score_and_display_result

      if grand_winner?
        display_grand_winner(name_of_grand_winner)
        play_again? ? reset_game_and_score : break
      else
        reset_game
      end
    end

    display_goodbye_message
  end

  private

  def choose_name_marker_and_display_welcome_message
    display_welcome_message
    choose_names
    choose_marker
  end

  def choose_names
    computer.name = ['Pogo', 'Diego', 'Justin', 'Brian', 'Ben'].sample
    n = ''
    loop do
      display_choose_name
      n = gets.chomp
      break unless n.size < 2 || n.size > 10 || n =~ /[^A-Za-z0-9]+/
      display_invalid_name
    end
    clear
    human.name = n
  end

  def choose_marker
    input = ''
    loop do
      diplay_choose_marker_prompt
      input = gets.chomp.upcase
      break if input == 'X' || input == 'O'
      display_invalid_choice
    end

    human.marker = input
    computer.marker = 'X' if human.marker == 'O'
    clear
  end

  def choose_move_gameplay
    loop do
      current_player_moves
      break if game_ending_condition?
      clear_screen_and_display_board if human_turn?
    end
  end

  def current_player_moves
    human_moves if human_turn?
    computer_moves if computer_turn?
    swap_turn
  end

  def human_moves
    display_choose_square(board)
    square = nil

    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      display_invalid_choice
    end

    board[square] = human.marker
  end

  def computer_moves
    if high_risk?(computer.marker)
      attack_high_risk
    elsif high_risk?(human.marker)
      defend_high_risk
    elsif board.squares[5].marker == ' '
      take_middle_square
    else
      take_random_square
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def computer_turn?
    @current_marker == computer.marker
  end

  def swap_turn
    @current_marker = if human_turn?
                        computer.marker
                      else
                        human.marker
                      end
  end

  def high_risk_square(risk_marker)
    board.unmarked_keys.each do |key|
      temp = Board::WINNING_LINES.select { |v| v.include?(key) }
      temp.each do |array|
        arr = array.map { |value| board.squares[value].marker }
        return key if arr.count(risk_marker) == 2
      end
    end
  end

  def high_risk?(risk_marker)
    board.unmarked_keys.each do |key|
      temp = Board::WINNING_LINES.select { |v| v.include?(key) }
      temp.each do |array|
        arr = array.map { |value| board.squares[value].marker }
        return true if arr.count(risk_marker) == 2
      end
    end
    false
  end

  def attack_high_risk
    board[high_risk_square(computer.marker)] = computer.marker
  end

  def defend_high_risk
    board[high_risk_square(human.marker)] = computer.marker
  end

  def take_middle_square
    board[5] = computer.marker
  end

  def take_random_square
    board[board.unmarked_keys.sample] = computer.marker
  end

  def game_ending_condition?
    board.someone_won? || board.full?
  end

  def update_score_and_display_result
    update_score
    display_result
    pause
  end

  def update_score
    score.update(human) if board.winning_marker == human.marker
    score.update(computer) if board.winning_marker == computer.marker
  end

  def name_of_grand_winner
    human.name if human.score == GRAND_WINNER_TOTAL
    computer.name if computer.score == GRAND_WINNER_TOTAL
  end

  def grand_winner?
    human.score == GRAND_WINNER_TOTAL || computer.score == GRAND_WINNER_TOTAL
  end

  def play_again?
    answer = nil
    loop do
      display_play_again_prompt
      answer = gets.chomp.downcase
      break if %w(y n yes no).include? answer
      display_invalid_play_again_choice
    end

    answer == 'y' || answer == 'yes'
  end

  def clear_screen_and_display_board
    clear
    board.display(human, computer, score)
  end

  def reset_game_and_score
    reset_game
    human.score = 0
    computer.score = 0
    choose_marker
  end

  def reset_game
    board.reset
    clear
    empty_line
    reset_current_marker
  end

  def reset_current_marker
    @current_marker = FIRST_TO_MOVE
  end

  def display_result
    clear
    board.display(human, computer, score)

    case board.winning_marker
    when human.marker
      prompt("#{human.name} won!")
    when computer.marker
      prompt("#{computer.name} won!")
    else
      prompt("It's a tie!")
    end
  end

  def display_choose_square(board)
    prompt("Choose a square (#{joinor(board.unmarked_keys, ', ')}): ")
  end

  def diplay_choose_marker_prompt
    big_filler
    prompt("Please choose a marker: 'X' or 'O'")
    big_filler
  end
  
  def display_grand_winner(name)
    prompt("#{name} is the Grand Winner!!!")
  end

  def display_choose_name
    big_filler
    prompt("Please enter a name: ")
    prompt("*Must be 2-10 characters")
    prompt("*Numbers and characters only")
    big_filler
  end
end

game = TTTGame.new
game.play
