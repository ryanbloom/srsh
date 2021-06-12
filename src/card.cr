ONE_DAY = 86400_i64
class Card
  property id = ""
  property topic = "Shell"
  property front = ""
  property back = ""
  property next_review = 0_i64
  property interval : Int64 = 86400_i64
  property e_factor : Float32 = 2.0

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
    right = check answer
    printf "\x1b[1A\x1b[2K"
    if right
      puts "✔ " + answer
      @interval *= 2
    else
      puts "𝗫 " + answer
      puts "✔ " + back
      @interval = ONE_DAY
    end
    @next_review = Time.utc.to_unix + interval
  end
end

