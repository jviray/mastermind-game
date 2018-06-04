class Code
  attr_reader :pegs

  PEGS = {
    "R" => "Red",
    "G" => "Green",
    "B" => "Blue",
    "Y" => "Yellow",
    "O" => "Orange",
    "P" => "Purple"
  }

  def initialize(pegs)
    @pegs = pegs
  end

  def Code.random
    Code.new(PEGS.keys.sample(4))
  end

  def Code.parse(input)
    pegs = input.upcase.split("")
    pegs.each do |peg|
      raise ParseError, "Invalid Color" unless PEGS.keys.include?(peg)
    end

    Code.new(pegs)
  end

  def [](i) # bracket method allows easier access specific item in @pegs
    @pegs[i]
  end

  def ==(code2)
    return false unless code2.is_a?(Code)
    @pegs == code2.pegs ? true : false
  end

  def exact_matches(code2)
    exact = 0
    code2.pegs.each_index do |idx| #
      exact += 1 if code2[idx] == self[idx]
    end

    exact
  end

  def near_matches(code2)
    code2_color_count = code2.color_count # assigns freq table (hash)

    near_matches = 0
    code2_color_count.each do |color, count|
      next unless self.color_count.has_key?(color)

      near_matches += [self.color_count[color], count].min
      # this ensures that the player does NOT get a free/extra hint (that there
      # is more than one peg of the same color), unless of course they guessed so
    end

    near_matches - self.exact_matches(code2) # excludes exact color matches
  end

  def color_count # histogram/freq table (hash)
    count = Hash.new(0)
    @pegs.each {|color| count[color] += 1}
    count
  end

end

class Game
  attr_reader :secret_code

  TURNS = 10

  def initialize(secret_code = Code.random)
    @secret_code = secret_code
  end

  def play

    TURNS.times do |i|
      guess = self.get_guess

      if guess == @secret_code
        puts "Youn win!"
        return
      end

      display_matches(guess)
      p "You have #{TURNS - (i + 1)} turn(s) left"
    end

    puts "You ran out of turns, better luck next time."
  end

  def get_guess
    puts "Guess the code, please no commas (Ex: RBYO)"


    begin # handles exception, rather than stop program
      Code.parse(gets.chomp)
    rescue
      puts "Invalid color used, try again"
      retry
    end
  end

  def display_matches(guess)
    exact_matches = @secret_code.exact_matches(guess)
    near_matches = @secret_code.near_matches(guess)

    puts "#{exact_matches} exact matches!"
    puts "#{near_matches} near matches!"
  end
end

if $PROGRAM_NAME == __FILE__
  Game.new.play
end
