
$file_data = File.readlines("5desk.txt", chomp: true)
require 'json'

class Hangman

  def initialize
    @guesses = 7
    @used_letters = []
    @random_word = $file_data.sample.split("")
    @hidden_word = " _" * @random_word.length 
    @save_file = ""
  end

  def variables
    {
      guesses: @guesses,
      used_letters: @used_letters,
      random_word: @random_word,
      hidden_word: @hidden_word,
      save_file: @save_file
    }
  end
  
  def start_game
    puts "Welcome to hangman!"
    sleep 1
    puts "Would you like to load a save state?"
    puts "y/n"
    @yes_or_no = gets.chomp
    load_game? 
    sleep 2
    puts "Enter 'save' anytime during the game to save your progress."
    sleep 1
    puts "Here is your random word."
    puts @hidden_word
    sleep 1
    good_guess?
  end

  def load_game?   
    if @yes_or_no == 'y'
      puts "What was the name of your save file? Type it without the extension."
      puts Dir.entries("saves")
      filename = gets.chomp + '.txt'
      if File.file?('saves/' + filename)
        values = JSON.parse(File.read("saves/#{filename}"))
        @guesses = values["guesses"]
        @used_letters = values["used_letters"]
        @random_word = values["random_word"]
        @hidden_word = values["hidden_word"]
        puts @hidden_word
        good_guess?
      elsif filename == "new"
        start_game
      else
        puts "Filename does not exist."
        puts "Try again or start a new game by entering 'new'."
        load_game?
      end
    elsif yes_or_no == 'n'
    else 
      puts "invalid selection...please type 'y' or 'n'"
      load_game?
    end
  end
  
  def good_guess?
    sleep 1
    puts "#{@guesses} lives remaining."
    puts "Used letters: " + @used_letters.join(" ")
    print "Enter a letter: "
    @letter = gets.chomp.downcase.gsub " ", ""
    if @letter.match(/[a-z]/) && !(@used_letters.include?(@letter)) && @letter.size == 1
      @used_letters.push(@letter)
      check_guess
    elsif @letter == 'save'
      save_game
    else
      puts "Invalid letter. Make sure it is not one you already used!\n"
      sleep 2
      good_guess?
    end
  end

  def check_guess
    if @random_word.include? @letter
      puts "\nNice guess"
      indexes = @random_word.each_index.select {|i| @random_word[i] == @letter}
      indexes.each {|i| @hidden_word[2*i+1] = @letter}
    else
      sleep 1
      @guesses -= 1
      lose if @guesses == 0
      puts "\nTry again."
      sleep 1
    end 
    puts @hidden_word
    win if @random_word - @used_letters == []
    good_guess?
  end

  def save_game
    puts "Enter a valid name for the save file. "
    save_name = gets.chomp
    if save_name.match(/[a-zA-Z\d]/) && save_name.size < 10
      @save_file = save_name
      values = variables.to_json
      puts "Saving file..."
      Dir.mkdir('saves') unless File.exists?('saves')
      File.open("saves/#{@save_file}.txt", "w") {|f| f.write(values)}
    else 
      sleep 1
      save_game
    end
  end

  def win
    puts "You won with #{@guesses} lives remaining."
    exit
  end

  def lose
    sleep 1
    puts "You ran out of lives."
    puts "The word was #{@random_word.join}"
    exit
  end

end

test = Hangman.new
test.start_game
