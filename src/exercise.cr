ONE_DAY = 86400_i64
ONE_HOUR = 3600_i64

class Exercise
  property id = ""
  property topic = "Shell"
  property front = ""
  property back = ""
  property last_review = 0_i64
  property next_review = 0_i64
  property deleted = false
  
  def initialize
    @next_review = Time.utc.to_unix
  end
  def initialize(@id, @topic, @front, @back, @last_review, @next_review)
    
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
      puts "Exercise deleted."
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
    if last_review == 0
      interval = ONE_DAY*3
    else
      interval = Time.utc.to_unix - @last_review
    end
    if right
      interval *= 2
    else
      interval = ONE_DAY
    end
    noise = Random.rand(ONE_HOUR)
    @last_review = Time.utc.to_unix
    @next_review = Time.utc.to_unix + interval + noise
  end
end

