ONE_DAY = 86400_i64
class Card
  property id = ""
  property topic = "Shell"
  property front = ""
  property back = ""
  property next_review = 0_i64
  property interval : Int64 = 86400_i64
  property e_factor : Float32 = 2.0
  property deleted = false
  
  def initialize
    @next_review = Time.utc.to_unix
  end
  def initialize(@id, @topic, @front, @back, @next_review, @interval, @e_factor)
    
  end
  
  def check(answer : String)
    answer == back
  end

  def test
    puts topic.upcase + ": " + front
    right = false
    printf "❯ "
    maybe_answer = gets
    answer = maybe_answer ? maybe_answer : ""
    if answer == "!del"
      @deleted = true
      puts "Card deleted."
      return
    end
    right = check answer
    printf "\x1b[1A\x1b[2K"
    if right
      puts "✔ " + answer
    else
      puts "𝗫 " + answer
      puts "✔ " + back
      printf "Close enough? "
      char : (Char | Nil) = nil
      STDIN.raw do
        char = STDIN.read_char
      end
      if char == 'y'
        right = true
        puts "Yes."
      else
        puts "No."
      end
    end
    if right
      @interval *= 2
    else
      @interval = ONE_DAY
    end
    @next_review = Time.utc.to_unix + interval
  end
end

