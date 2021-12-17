class Card
  attr_reader :label, :suit

  def initialize(label, suit)
    @label = label
    @suit = suit
  end

  def to_s
    "#{label} of #{suit}"
  end
end

class Deck
  SUITS = %w[Hearts Diamonds Spades Clubs]
  LABELS = (1..10).to_a + %w[Jack Queen King Ace]

  attr_reader :cards

  def initialize
    @cards = []
    SUITS.each do |suit|
      LABELS.each do |label|
        @cards << Card.new(label, suit)
      end
    end
    @cards.shuffle!
  end

  def deal
    cards.shuffle!
    @cards.pop
  end
end

class Participant
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def total_hand
    total = 0
    has_ace = false
    hand.each do |card|
      if %w[Jack Queen King].include?(card.label)
        total += 10
      elsif card.label == 'Ace'
        has_ace = true
        total += 11
      else
        total += card.label.to_i
      end
    end

    total -= 10 if has_ace && total > Game::MAX_HAND_VALUE
    total
  end

  def busted?
    total_hand > Game::MAX_HAND_VALUE
  end
end

class Player < Participant
  def show_cards
    cards = hand.map(&:to_s).join(', ')
    puts "You now have: #{cards}"
  end

  def choice
    answer = nil
    loop do
      puts 'Hit or stay?'
      answer = gets.chomp.downcase
      break if %w[hit stay].include?(answer)

      puts 'Please enter hit or stay.'
    end
    answer
  end

  def make_move(deck)
    loop do
      if choice == 'stay'
        puts 'You chose to stay!'
        return 'stay'
      elsif choice == 'hit'
        hit(deck)
        if busted?
          puts 'You busted!'
          return 'busted'
        end
      end
    end
  end

  def hit(deck)
    puts 'You chose to hit!'
    hand << deck.deal
    show_cards
  end
end

class Dealer < Participant
  def show_cards
    card = hand.sample
    puts "Dealer has: #{card} and unknown card"
  end

  def make_move(deck)
    while total_hand < (Game::MAX_HAND_VALUE - 4) # 17
      hand << deck.deal
      puts "Dealer hits, now has a total of #{total_hand}."
    end

    if total_hand > Game::MAX_HAND_VALUE
      puts 'The dealer busted.'
      'busted'
    else
      puts "The dealer's turn has ended."
    end
  end
end

class Game
  MAX_HAND_VALUE = 21
  POINTS_TO_WIN = 5

  attr_accessor :deck
  attr_reader :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    loop do
      display_welcome
      deal_cards
      show_initial_cards
      player_result = player.make_move(deck)
      winner = 'Dealer' if player_result == 'busted'

      unless winner
        dealer_result = dealer.make_move(deck)
        winner = 'Player' if dealer_result == 'busted'
      end

      winner ||= determine_winner
      show_result(winner)

      break unless play_again?

      reset
    end
  end

  private

  def display_welcome
    puts "Welcome to #{MAX_HAND_VALUE}! The first player to win #{POINTS_TO_WIN} rounds wins the match!`"
  end

  def deal_cards
    2.times do
      player.hand << deck.deal
      dealer.hand << deck.deal
    end
  end

  def show_initial_cards
    player.show_cards
    dealer.show_cards
  end

  def determine_winner
    player_total = player.total_hand
    dealer_total = dealer.total_hand
    puts "Your total: #{player_total}. Dealer total: #{dealer_total}"

    if player_total > dealer_total
      'Player'
    elsif player_total < dealer_total
      'Dealer'
    else
      'Tie'
    end
  end

  def show_result(winner)
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

  def reset
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    system 'clear'
  end
end

Game.new.start
