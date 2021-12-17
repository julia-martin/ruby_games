MAX_HAND_VALUE = 21
POINTS_TO_WIN = 5
score = { 'Player' => 0, 'Dealer' => 0 }

def init_hand(deck)
  [] << deck.pop << deck.pop
end

def calc_hand(hand)
  total = 0
  hand.each do |card|
    if ['Jack', 'Queen', 'King'].include?(card[0])
      total += 10
    elsif card[0] == 'Ace'
      total += 11
    else
      total += card[0].to_i
    end
  end

  cards = hand.map { |card| card[0] }
  total -= 10 if cards.include?('Ace') && total > MAX_HAND_VALUE
  total
end

def update_dealer(dealer_hand)
  dealer_hand.shuffle!
  puts "Dealer has: #{dealer_hand[0][0]} and unknown card"
end

def hit_or_stay
  answer = nil
  loop do
    puts 'hit or stay?'
    answer = gets.chomp.downcase
    break if ['hit', 'stay'].include?(answer)
    puts 'Please enter hit or stay.'
  end
  answer
end

def show_cards(hand)
  player_cards = hand.map { |card| card[0] }.join(', ')
  puts "You have: #{player_cards}."
end

def busted?(hand)
  calc_hand(hand) > 21
end

def player_turn(hand, deck)
  update_dealer(hand)
  show_cards(hand)

  answer = nil
  loop do
    answer = hit_or_stay
    if answer == 'hit'
      hand << deck.pop
      show_cards(hand)
    end
    break if answer == 'stay' || busted?(hand)
  end
  busted?(hand) ? 'busted' : 'stay'
end

def dealer_turn(hand, deck)
  total = calc_hand(hand)
  while total < (MAX_HAND_VALUE - 4) # 17
    puts 'Dealer hits.'
    hand << deck.pop
    total = calc_hand(hand)
    puts "Dealer now has a total of #{total}."
  end

  if calc_hand(hand) > MAX_HAND_VALUE
    puts 'The dealer busted.'
    'busted'
  else
    puts "The dealer's turn has ended."
  end
end

def get_winner(player_hand, dealer_hand)
  puts "Your total: #{calc_hand(player_hand)}"
  puts "Dealer total: #{calc_hand(dealer_hand)}"

  if calc_hand(player_hand) > calc_hand(dealer_hand)
    'Player'
  elsif calc_hand(player_hand) < calc_hand(dealer_hand)
    'Dealer'
  else
    'Tie'
  end
end

def display_result(winner)
  case winner
  when 'Player'
    puts 'Congratulations, you won!'
  when 'Dealer'
    puts 'Sorry, you lost!'
  when 'Tie'
    puts 'It was a tie!'
  end
end

def play_again?
  puts '------------------------------------'
  puts 'Do you want to play again? (y/n)'
  answer = gets.chomp.downcase
  answer.start_with?('y')
end

loop do
  # rubocop:disable Layout/LineLength
  puts "Welcome to #{MAX_HAND_VALUE}! The first player to win #{POINTS_TO_WIN} rounds wins the match!`"
  # rubocop:enable Layout/LineLength
  deck = [
    ['2', 'D'], ['2', 'S'], ['2', 'H'], ['2', 'C'],
    ['3', 'D'], ['3', 'S'], ['3', 'H'], ['3', 'C'],
    ['4', 'D'], ['4', 'S'], ['4', 'H'], ['4', 'C'],
    ['5', 'D'], ['5', 'S'], ['5', 'H'], ['5', 'C'],
    ['6', 'D'], ['6', 'S'], ['6', 'H'], ['6', 'C'],
    ['7', 'D'], ['7', 'S'], ['7', 'H'], ['7', 'C'],
    ['8', 'D'], ['8', 'S'], ['8', 'H'], ['8', 'C'],
    ['9', 'D'], ['9', 'S'], ['9', 'H'], ['9', 'C'],
    ['10', 'D'], ['10', 'S'], ['10', 'H'], ['10', 'C'],
    ['Jack', 'D'], ['Jack', 'S'], ['Jack', 'H'], ['Jack', 'C'],
    ['Queen', 'D'], ['Queen', 'S'], ['Queen', 'H'], ['Queen', 'C'],
    ['King', 'D'], ['King', 'S'], ['King', 'H'], ['King', 'C'],
    ['Ace', 'D'], ['Ace', 'S'], ['Ace', 'H'], ['Ace', 'C']
  ]

  deck.shuffle!
  player_hand = init_hand(deck)
  dealer_hand = init_hand(deck)
  winner = nil

  player_result = player_turn(player_hand, deck)
  if player_result == 'busted'
    puts 'You busted!'
    winner = 'Dealer'
  elsif player_result == 'stay'
    puts 'You chose to stay!'
  end

  if !winner
    dealer_result = dealer_turn(dealer_hand, deck)
    winner = 'Player' if dealer_result == 'busted'
  end

  winner ||= get_winner(player_hand, dealer_hand)
  score[winner] += 1
  display_result(winner)

  # rubocop:disable Layout/LineLength
  puts "Your points so far: #{score['Player']}. Dealer's points so far: #{score['Dealer']}"
  # rubocop:enable Layout/LineLength
  if score['Player'] == POINTS_TO_WIN
    puts 'Congratulations, you won the match!'
    break
  elsif score['Dealer'] == POINTS_TO_WIN
    puts 'Sorry, you lost the match!'
    break
  elsif !play_again?
    break
  end
end

puts "Thank you for playing #{MAX_HAND_VALUE}! Goodbye!"
