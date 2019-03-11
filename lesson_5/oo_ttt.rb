require 'pry'

module Helper
  def prompt(msg)
    puts "=> #{msg}"
  end

  def filler
    puts "----------------"
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
    arr.join(del1).reverse.sub(del1.strip, del2.reverse + ' ' + del1.strip).reverse
  end

  def pause
    sleep(1.6)
  end
end

module Displayable
  include Helper

  def display_welcome_message
    clear
    prompt("Welcome to Tic Tac Toe!")
    empty_line
    pause
    clear
  end

  def display_goodbye_message
    prompt("Thanks for playing Tic Tac Toe! Goodbye!")
  end

  def display_board
    prompt("#{human.name} is '#{human.marker}'. #{computer.name} "\
           "is '#{computer.marker}'.")
    score.display
    empty_line
    board.draw_board
    empty_line
  end

  def display_result
    clear
    display_board

    case board.winning_marker
    when human.marker
      prompt("You won!")
    when computer.marker
      prompt("Computer won!")
    else
      prompt("It's a tie!")
    end
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

  def display_grand_winner(name)
    prompt("#{name} is the Grand Winner!!!")
  end

  def display_choose_name
    prompt("Please enter a name: ")
    prompt("*Must be 2-10 characters")
    prompt("*Numbers and characters only")
  end

  def display_invalid_name
    prompt("Invalid name entry. Please follow the rules for inputing a "\
            "valid name")
  end

  def display_next_game
    prompt("Next Game in our race to #{TTTGame::GRAND_WINNER_TOTAL}")
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
  attr_accessor :name, :score
  attr_reader :marker

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
    puts "Score Board"
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
  include Helper, Displayable
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER
  GRAND_WINNER_TOTAL = 3

  attr_reader :board, :human, :computer, :count, :score

  def initialize
    @current_marker = FIRST_TO_MOVE
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @score = Score.new(@human, @computer)
  end

  def play
    display_welcome_message
    choose_names

    loop do
      loop do
        display_board

        loop do
          current_player_moves
          break if game_ending_condition?
          clear_screen_and_display_board if human_turn?
        end

        update_score
        display_result
        pause

        break if grand_winner?
        reset_game
      end

      display_grand_winner(name_of_grand_winner)
      break unless play_again?
      reset_game_and_score
    end

    display_goodbye_message
  end

  private

  def update_score
    score.update(human) if board.winning_marker == HUMAN_MARKER
    score.update(computer) if board.winning_marker == COMPUTER_MARKER
  end

  def choose_names
    computer.name = ['Pogo', 'Diego', 'Justin', 'Brian'].sample
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

  def name_of_grand_winner
    return human.name if human.score == GRAND_WINNER_TOTAL
    return computer.name if computer.score == GRAND_WINNER_TOTAL
  end

  def grand_winner?
    human.score == GRAND_WINNER_TOTAL || computer.score == GRAND_WINNER_TOTAL
  end

  def swap_turn
    @current_marker = if human_turn?
                        COMPUTER_MARKER
                      else
                        HUMAN_MARKER
                      end
  end

  def reset_current_marker
    @current_marker = FIRST_TO_MOVE
  end

  def human_moves
    prompt("Choose a square (#{joinor(board.unmarked_keys, ', ')}): ")
    square = nil

    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      display_invalid_choice
    end

    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def play_again?
    answer = nil
    loop do
      display_play_again_prompt
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      display_invalid_play_again_choice
    end

    answer == 'y'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def reset_game_and_score
    reset_game
    human.score = 0
    computer.score = 0
  end

  def reset_game
    board.reset
    clear
    display_next_game
    empty_line
    reset_current_marker
  end

  def game_ending_condition?
    board.someone_won? || board.full?
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def computer_turn?
    @current_marker == COMPUTER_MARKER
  end

  def current_player_moves
    human_moves if human_turn?
    computer_moves if computer_turn?
    swap_turn
  end
end

game = TTTGame.new
game.play
