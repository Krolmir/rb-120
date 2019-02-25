class Moves
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  attr_accessor :outcome

  def initialize
    @outcome = 'tie'
  end

  def >(other_move)
    index = VALUES.index(to_s.downcase)
    beatable_plays = [VALUES[index - 1], VALUES[index - 3]]
    beatable_plays.include?(other_move.to_s.downcase)
  end
end

class Rock < Moves
  def verb(_other_move_)
    'smashes'
  end

  def to_s
    'Rock'
  end
end

class Paper < Moves
  def verb(other_move)
    verb = 'covers' if other_move.class == Rock
    verb = 'disproves' if other_move.class == Spock
    verb
  end

  def to_s
    'Paper'
  end
end

class Scissors < Moves
  def verb(other_move)
    verb = 'cuts' if other_move.class == Paper
    verb = 'decapitates' if other_move.class == Lizard
    verb
  end

  def to_s
    'Scissors'
  end
end

class Spock < Moves
  def verb(other_move)
    verb = 'vaporizes' if other_move.class == Rock
    verb = 'smashes' if other_move.class == Scissors
    verb
  end

  def to_s
    'Spock'
  end
end

class Lizard < Moves
  def verb(other_move)
    verb = 'eats' if other_move.class == Paper
    verb = 'poisons' if other_move.class == Spock
    verb
  end

  def to_s
    'Lizard'
  end
end

class Player
  attr_accessor :move, :name, :move_history, :score

  def initialize
    set_name
    @move_history = []
    @score = 0
  end

  def assign_move(move_str)
    result = case move_str
             when 'rock' then Rock.new
             when 'paper' then Paper.new
             when 'scissors' then Scissors.new
             when 'spock' then Spock.new
             when 'lizard' then Lizard.new
             end

    @move_history << result
    result
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry, must enter a value"
    end

    self.name = n
  end

  def display_s_error
    puts "Do you mean Spock or Scissors?"
  end

  def choose
    choice = nil
    puts "Please choose (r)ock, (p)aper, (sc)issors, (sp)ock, (l)izard:"
    i = 0
    loop do
      puts "Sorry #{@name}, that's not a valid choice." if i > 0
      i += 1
      choice = gets.chomp.downcase.strip

      display_s_error if choice == 's'
      next if choice == 's' || choice.empty?

      Moves::VALUES.each do |move_str|
        return self.move = assign_move(move_str) if move_str.start_with?(choice)
      end
    end
  end
end

class Computer < Player
  MIN_LOSE_RATIO = 0.6

  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    good_moves = Moves::VALUES.select do |move_str|
      good_move?(move_str)
    end

    multiplier = 2**(4 - good_moves.size).abs
    move_str = (Moves::VALUES + good_moves * multiplier).sample
    self.move = assign_move(move_str)
  end

  protected

  def good_move?(move_str)
    lose_ratio = nil
    total_moves = @move_history.count { |move| move.to_s.downcase == move_str }
    total_losses = @move_history.count do |move|
      move.outcome == 'lose' && move.to_s.downcase == move_str
    end

    lose_ratio = total_losses / total_moves.to_f if total_moves > 0
    return lose_ratio < MIN_LOSE_RATIO if lose_ratio
    true
  end
end

# Game Orchestration Engine
class RPSGame
  MAX_ROUND = 10
  PAUSE_TIME = 0.8
  attr_accessor :human, :computer, :tie

  def initialize
    clear_screen
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
    @current_winner = nil
    @current_loser = nil
    @tie = 0
  end

  def clear_screen
    system('clear') || system('cls')
    puts "\n\n"
  end

  def pause
    sleep(PAUSE_TIME)
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
    puts "First player to #{MAX_ROUND} wins the round.\n\n"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Good-bye!"
  end

  def display_moves
    puts "--------------------------------"
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    puts "--------------------------------"
    pause
  end

  def determine_winner
    tie_round = true
    if @human.move > @computer.move
      tie_round = false
      @current_winner = @human
      @current_loser = @computer
    elsif @computer.move > @human.move
      tie_round = false
      @current_winner = @computer
      @current_loser = @human
    end

    @current_winner.move.outcome = 'win' unless tie_round
    @current_loser.move.outcome = 'lose' unless tie_round
  end

  def update_scores
    if human.move.outcome == 'tie' && computer.move.outcome == 'tie'
      @tie += 1
    else
      @current_winner.score += 1
    end
  end

  def display_winner
    if human.move.outcome == 'tie'
      puts "It's a tie."
    else
      verb_text = @current_winner.move.verb(@current_loser.move)
      puts "#{@current_winner.move} #{verb_text} #{@current_loser.move}."
      puts "#{@current_winner.name} wins!"
    end
    puts "--------------------------------"
  end

  def display_score
    puts "--------------------------------"
    puts "Current Score"
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts "Tie: #{@tie}"
    puts "--------------------------------"
  end

  def round_over?
    human.score >= MAX_ROUND || computer.score >= MAX_ROUND
  end

  def reset_scores
    @human.score = 0
    @computer.score = 0
    @tie = 0
  end

  def press_enter
    puts "press ENTER to continue"
    gets
  end

  def display_round
    round_winner = computer.score > human.score ? computer.name : human.name
    puts "#{round_winner} won the round!!"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n"
    end

    answer == 'y' ? true : false
  end

  def game_ops
    display_score
    @human.choose
    @computer.choose
    display_moves
    determine_winner
    update_scores
    display_winner
    pause
    press_enter
    clear_screen
  end

  def play
    clear_screen

    loop do
      game_ops

      if round_over?
        display_score
        display_round
        break unless play_again?
        reset_scores
        clear_screen
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play