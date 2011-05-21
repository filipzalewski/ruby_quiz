class SolitaireCipher

  @@letters = Hash.new
  attr_accessor :text

  def self.letters
    if @@letters.empty? 
      @@letters = Hash.new
      letters = ('A'..'Z').to_a
      letters.each_index{ |idx| 
        @@letters[letters[idx]] = idx + 1
      }
    end
    @@letters
  end

  def self.to_numbers(words)
    numbers = words.map{|word|
      trans = String.new
      word.chars { |letter| 
        trans << self.letters[letter].to_s+" "
      }
      trans.strip!
    }
    numbers 
  end

  def self.to_letters(numbers)
    alphabet = ('A'..'Z').to_a

    letters = numbers.map{|number|
      alphabet[number.to_i - 1]
    }
    letters 
  end

  def self.to_letter(number)
    number = number - ((number / 26) * 26)
    to_letters([number])[0]
  end

  def initialize(text) 
    @text = text
    @keystream = Keystream.new
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

  def cipher_keys
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
    @keystream.next_key
  end

  def encrypt
    normalize
    cipher_keys

    c = Array.new
    a = SolitaireCipher.to_numbers(@normalized)
    b = SolitaireCipher.to_numbers(@cipher_keys)
    a.collect!{|x| x.split(/\s/) }.flatten!
    b.collect!{|x| x.split(/\s/) }.flatten!

    b.each_index{ |idx| 
      result = (a[idx].to_i + b[idx].to_i)
      c[idx] = result - ((result / 26) * 26)
    }

    letters = SolitaireCipher.to_letters(c).join("")
    to_words(letters)
  end

  def decrypt
    normalize 
    cipher_keys

    c = Array.new
    a = SolitaireCipher.to_numbers(@normalized)
    b = SolitaireCipher.to_numbers(@cipher_keys)

    a.collect!{|x| x.split(/\s/).collect{|y| y.to_i }}.flatten!
    b.collect!{|x| x.split(/\s/).collect{|y| y.to_i }}.flatten!

    b.each_index{ |idx| 
      if(a[idx] <= b[idx]) 
        a[idx] = a[idx] + 26
      end
      c[idx] = (a[idx] - b[idx])
    }

    letters = SolitaireCipher.to_letters(c).join("")
    to_words(letters)
  end

  def to_words(str)
    str.split(/(.{5})/).delete_if{ |x| x == "" }
  end

end

class Keystream 

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
    @cards.swap(card, places)
  end

  def triple_cut
    a_idx = @cards.index("A")
    b_idx = @cards.index("B")

    top = a_idx < b_idx ? a_idx : b_idx
    bottom = a_idx == top ? b_idx : a_idx

    bottom_slice = @cards.slice!(bottom + 1, 54 - bottom)
    top_slice = @cards.slice!(0,top)

    @cards.insert(0, bottom_slice)
    @cards.push(top_slice)
    
    @cards.flatten!

  end

  def move_a 
    is_last("A") ? self.move("A", 2) : self.move("A", 1)
  end

  def move_b
    is_last("B") || is_second_last("B") ? self.move("B", 3) : self.move("B", 2)
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

  def is_last(card)
    @cards.index(card) == @cards.length - 1
  end

  def is_second_last(card)
    (@cards.index(card) == @cards.length - 1) ||
      (@cards.index(card) == @cards.length - 2)
  end

  def is_joker(card)
    card == "A" || card == "B" 
  end

  def next_key 
    move_a
    move_b
    triple_cut
    count_cut
    output = is_joker(cards[0]) ? cards[53] : cards[cards[0]]
    is_joker(output) ? nil : output
  end

end

class Array
  
  def swap(el, *args)

    if args.size > 0
      places = args[0]
      if places < 1 || places > self.length - 1
        self
      end
    end

    idx = self.index(el)

    if idx == nil
      return self 
    end

    if idx < self.length
      if idx == self.length - 1
        insert(0, pop)
      elsif
        self[idx, 2] = slice(idx, 2).reverse
      end
    end

    if args.size > 0 && args[0] > 1
      swap(el, args[0] -= 1)
    end

    self
  end

end

