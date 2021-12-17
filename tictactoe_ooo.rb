class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def display
    puts '     |     |     '
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts '     |     |     '
    puts '-----+-----+-----'
    puts '     |     |     '
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts '     |     |     '
    puts '-----+-----+-----'
    puts '     |     |     '
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts '     |     |     '
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def [](key)
    @squares[key].marker
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # return winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_identical_markers?(squares)
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3

    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name

  def initialize
    @marker = nil
    @name = nil
  end
end

class TTTGame
  MARKER_CHOICES = %w(X O)
  NUM_GAMES_TO_WIN = 5

  attr_reader :board, :human, :computer
  attr_accessor :score

  def initialize
    @board = Board.new
    @human = Player.new # (HUMAN_MARKER)
    @computer = Player.new # (COMPUTER_MARKER)
    @score = { human => 0, computer => 0 }
  end

  def play
    clear_screen
    get_name
    get_player_marker
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def get_name
    player_name = nil
    loop do
      puts 'What is your name?'
      player_name = gets.chomp
      break unless player_name.empty?

      puts 'Please enter a name'
    end

    human.name = player_name
    computer.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def get_player_marker
    choice = nil
    loop do
      puts 'What would you like to be, X or O?'
      choice = gets.chomp.upcase
      puts MARKER_CHOICES
      puts choice
      break if MARKER_CHOICES.include?(choice)

      puts 'Sorry, please type X or O.'
    end

    human.marker = choice
    choice == 'X' ? computer.marker = 'O' : computer.marker = 'X'
  end

  def display_welcome_message
    puts "Hello #{human.name}. Welcome to Tic Tac Toe! The first player to win 5 games wins the match"
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def display_board
    puts "#{human.name} is #{human.marker}. #{computer.name} is #{computer.marker}."
    puts ''
    board.display
    puts ''
  end

  def main_game
    loop do
      display_board
      human_turn = true
      player_move(human_turn)
      display_result
      puts "Your score: #{score[human]}. Computer score: #{score[computer]}"

      if score[human] == 5
        puts 'Congratulations, You won the match!'
        break
      elsif score[computer] == 5
        puts 'Sorry, the computer won the match!'
        break
      end
      break unless play_again?
      reset

      display_play_again_message
    end
  end

  def player_move(human_turn)
    loop do
      human_turn ? human_moves : computer_moves
      break if board.someone_won? || board.full?

      clear_screen_and_display_board # if human_turn
      human_turn = !human_turn
    end
  end

  def clear_screen_and_display_board
    clear_screen
    board.display
  end

  def human_moves
    puts "Choose a square: (#{joinor(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)

      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    square = nil

    Board::WINNING_LINES.each do |line|
      # Offensive
      square = find_at_risk_square(line, board, computer.marker)
      break if square
      # Defensive
      square = find_at_risk_square(line, board, human.marker)
      break if square
    end
    # Center square
    square = 5 if !square && (board[5] == Square::INITIAL_MARKER)
    # Random
    square = board.unmarked_keys.sample if !square

    board[square] = computer.marker
  end

  def find_at_risk_square(line, board, marker)
    markers_in_line = line.map { |sq| board[sq] }
    if markers_in_line.select { |val| val === marker }.size === 2
      unused_square = line.select { |sq| board[sq] === Square::INITIAL_MARKER }
      return unused_square[0] if unused_square.size > 0
    end
    nil
  end

  def display_result
    display_board
    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
      score[human] += 1
    when computer.marker
      puts "#{computer.name} won!"
      score[computer] += 1
    else
      puts 'It was a tie!'
    end
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again?'
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)

      puts 'Sorry, must enter y or n'
    end

    answer == 'y'
  end

  def clear_screen
    system 'clear'
  end

  def reset
    board.reset
    clear_screen
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def joinor(arr, delimeter = ', ', word = 'or')
    return arr[0] if arr.size == 1
    return "#{arr[0]} #{word} #{arr[1]}" if arr.size == 2
    return "#{arr[0..-2].join(delimeter)}#{delimeter}#{word} #{arr[-1]}"
  end
end

game = TTTGame.new
game.play
