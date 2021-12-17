WINNING_LINES = [
  [1, 2, 3], [4, 5, 6], [7, 8, 9],
  [1, 4, 7], [2, 5, 8], [3, 6, 9],
  [1, 5, 9], [3, 5, 7]
]
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
NUM_GAMES_TO_WIN = 5

def prompt(msg)
  puts "=> #{msg}"
end

def joinor(arr, delimeter = ', ', word = 'or')
  return arr[0] if arr.size == 1
  return "#{arr[0]} #{word} #{arr[1]}" if arr.size == 2
  return "#{arr[0..-2].join(delimeter)}#{delimeter}#{word} #{arr[-1]}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
 # system 'clear'
  puts "You're #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def choose_first_player
  answer = nil
  loop do
    prompt "Who should go first? ('p' for you, 'c' for computer, or 'r' for random)"
    answer = gets.chomp.downcase
    break if ['p', 'c', 'r'].include?(answer)
    puts "Invalid input. Please type 'p', 'c', or 'r'."
  end

  case answer
  when 'p'
    'Player'
  when 'c'
    'Computer'
  else
    ['Player', 'Computer'].sample
  end
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def player_places_piece!(brd)
  square = ''
  available = empty_squares(brd)
  loop do
    prompt "Choose a square: #{joinor(available)}"
    square = gets.chomp.to_i
    break if available.include?(square)
    prompt "Sorry, that's not a valid choice."
  end
  brd[square] = PLAYER_MARKER
end

def find_at_risk_square(line, board, marker)
  markers_in_line = line.map { |sq| board[sq] }
  if markers_in_line.select { |val| val === marker }.size === 2
    unused_square = line.select { |sq| board[sq] === INITIAL_MARKER }
    return unused_square[0] if unused_square.size > 0
  end
  nil
end

def computer_places_piece!(brd)
  square = nil
  WINNING_LINES.each do |line|
    # Offensive
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
    # Defensive
    square = find_at_risk_square(line, brd, PLAYER_MARKER)
    break if square
  end
  # Center square
  if !square && (brd[5] == INITIAL_MARKER)
    square = 5
  end
  # Random
  if !square
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def place_piece(brd, player)
  if player == 'Computer'
    computer_places_piece!(brd)
  else
    player_places_piece!(brd)
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(line[0], line[1], line[2]).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(line[0], line[1], line[2]).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def play_again?
  prompt "Play again? (y or n)"
  answer = gets.chomp
  answer.downcase.start_with?('y')
end

# Start new match
loop do
  score = { 'Player' => 0, 'Computer' => 0 }
  # Start individual game
  while !score.value?(5)
    board = initialize_board
    display_board(board)
    current_player = choose_first_player
    puts current_player

    loop do
      place_piece(board, current_player)
      break if someone_won?(board) || board_full?(board)
      display_board(board)
      current_player = current_player == 'Player' ? 'Computer' : 'Player'
    end

    display_board(board)

    if someone_won?(board)
      winner = detect_winner(board)
      puts score[winner]
      score[winner] += 1
      prompt "#{winner} won!"
    else
      prompt "It's a tie!"
    end

    prompt "Your score: #{score['Player']}. Computer score: #{score['Computer']}"
    break unless play_again?
  end

  if score['Player'] == NUM_GAMES_TO_WIN
    prompt "You won the match!"
  elsif score['Computer'] == NUM_GAMES_TO_WIN
    prompt "Sorry, the computer won the match!"
  else
    break
  end

  break unless play_again?
end

prompt "Thanks for playing Tic Tac Toe! Goodbye!"

