class SolitaireCipher

  attr_accessor :text

  def self.to_numbers(words)
    letters = ('A'..'Z').to_a
    numbers = words.map{|word|
      trans = String.new
      word.chars { |letter| 
        trans << (letters.index(letter) + 1).to_s+" "
      }
      trans.strip!
    }
    numbers 
  end

  def self.to_letters(numbers)
    alphabet = ('A'..'Z').to_a
    numbers.map!{|number|
      alphabet[number.to_i - 1]
    }
  end

  def self.to_letter(number)
    to_letters([number - ((number / 26) * 26)])[0]
  end

  def initialize(text) 
    @text = text
    @deck = Deck.new
  end

  def normalize
    @normalized = Array.new
    @text.gsub(/[^A-Za-z]/, '')
      .upcase
      .split(/(.{5})/)
      .each{ |match| 
        if match.empty?
          next
        elsif match.length < 5
          (5 - match.length).times{ match << "X" }
        end
        @normalized << match
      }
    @normalized
  end

  def generate_cipher_keys
    keys = String.new

    while keys.size < (@normalized.size * 5) do
      key = next_cipher
      if(key != nil)
        keys << SolitaireCipher.to_letter(key)
      end
    end

    @cipher_keys = keys.split(/(.{5})/).delete_if{ |x| x == ""}
    @cipher_keys
  end

  def next_cipher
    @deck.next_key
  end

  def encrypt
    cipher{ |a, b|
      (a + b) - (((a + b) / 26) * 26)
    }
  end

  def decrypt
   cipher{|a, b| 
      a <= b ? a + 26 - b : a - b
    }
  end

  def cipher 
    normalize 
    generate_cipher_keys

    c = Array.new
    a = SolitaireCipher.to_numbers(@normalized)
    b = SolitaireCipher.to_numbers(@cipher_keys)
    [a, b].each{ |text|
      text.collect!{|x| 
        x.split(/\s/).collect{
          |y| y.to_i }
      }.flatten!
    }

    b.each_index{ |idx| 
      c[idx] = yield(a[idx], b[idx])
    }

    letters = SolitaireCipher.to_letters(c).join("")
    to_words(letters)
  end

  def to_words(str)
    str.split(/(.{5})/).delete_if{ |x| x == "" }
  end

end

class Deck 

  attr_reader :cards
  
  def initialize(*size) 
    if(size.length > 0) 
      last = size[0]
    else
      last = 52
    end
    @cards = (1..last).to_a.push('A', 'B')
  end

  def move(card, places)
    idx = @cards.index(card)
    pos = idx + places < @cards.length ? idx + places : idx + places - @cards.length + 1
    @cards.insert(pos, @cards.delete_at(idx))
    @cards.compact!
  end

  def triple_cut
    a = @cards.index("A")
    b = @cards.index("B")

    a,b = b,a if a > b

    @cards = @cards[b + 1..53]
      .push(@cards[a..b])
      .push(@cards[0..a-1]).flatten!
  end

  def count_cut
    last = @cards.pop
    if(!is_joker(last))
      shift = @cards.shift(last)
      @cards.insert(@cards.length, shift)
      @cards.flatten!
    end
    @cards << last 
  end

  def is_joker(card)
    card == "A" || card == "B" 
  end

  def next_key 
    move("A", 1)
    move("B", 2)
    triple_cut
    count_cut
    output = is_joker(cards[0]) ? cards[53] : cards[cards[0]]
    is_joker(output) ? nil : output
  end

end
