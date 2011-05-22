require './solitaire_cipher'
require 'test/unit'

class TestSolitaireCipher < Test::Unit::TestCase

  def test_translates_from_letter_to_number
    assert_equal (1..26).to_a.map{|num| num.to_s}, SolitaireCipher.to_numbers(('A'..'Z').to_a)
  end

  def test_translates_from_number_to_letter
    assert_equal ('A'..'Z').to_a, SolitaireCipher.to_letters((1..26).to_a)
  end

  def test_simple
    cipher = SolitaireCipher.new("Hello, my name is Jim")
    assert_equal(%w{HELLO MYNAM EISJI MXXXX}, cipher.normalize)

    cipher = SolitaireCipher.new("Hi")
    assert_equal(%w{HIXXX}, cipher.normalize)
   
    cipher = SolitaireCipher.new("Hi000")
    assert_equal(%w{HIXXX}, cipher.normalize)
  end

  def test_move
    d = Deck.new
    d.next_key
    d.next_key
  end

  def test_to_letter
    assert_equal('A', SolitaireCipher.to_letter(1))
    assert_equal('A', SolitaireCipher.to_letter(27))
    assert_equal('Z', SolitaireCipher.to_letter(26))
    assert_equal('Z', SolitaireCipher.to_letter(52))
  end

  def test_encrypt
    sc = SolitaireCipher.new("Code in Ruby, live longer!")
    assert_equal(%w(GLNCQ MJAFF FVOMB JIYCB), sc.encrypt)
  end

  def test_decrypt
    assert_equal(%w(CODEI NRUBY LIVEL ONGER), SolitaireCipher.new("GLNCQ MJAFF FVOMB JIYCB").decrypt)
    assert_equal(%w(YOURC IPHER ISWOR KINGX), SolitaireCipher.new("CLEPK HHNIY CFPWH FDFEH").decrypt)
    assert_equal(%w(WELCO METOR UBYQU IZXXX), SolitaireCipher.new("ABVAW LWZSY OORYK DUPVH").decrypt)
  end

  def test_keystream
    sc = SolitaireCipher.new('text')
    keys = [4, 49, 10, nil, 24, 8, 51, 44, 6, 4, 33]
    output = Array.new
    11.times do
      output << sc.next_cipher
    end

    assert_equal(keys, output)
  end

end
