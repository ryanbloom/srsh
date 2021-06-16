require "sqlite3"
require "./card.cr"

class Collection
  property cards = [] of Card
  property db : DB::Database

  def initialize(path : String)
    existed = File.exists? path
    @db = DB.open "sqlite3://" + path
    unless existed
      db.exec "create table cards (id text primary key, topic text, front text, back text, next_review integer, interval integer, e real)"
    end
  end

  def merge(new_cards : Array(Card))
    new_cards.each do |c|
      db.exec "insert into cards values (?, ?, ?, ?, ?, ?, ?) ON CONFLICT(id) DO UPDATE SET topic=?, front=?, back=?", c.id, c.topic, c.front, c.back, c.next_review, c.interval, c.e_factor, c.topic, c.front, c.back
    end
  end

  def get_session(count : Int)
    cards = [] of Card
    db.query "select * from cards where next_review < #{Time.utc.to_unix} order by next_review asc limit #{count}" do |rs|
      rs.each do
        id = rs.read(String)
        topic = rs.read(String)
        front = rs.read(String)
        back = rs.read(String)
        next_review = rs.read(Int64)
        interval = rs.read(Int64)
        e = rs.read(Float32)

        cards << Card.new(id, topic, front, back, next_review, interval, e)
      end
    end
    return cards
  end

  def update(c : Card)
    if c.deleted
      db.exec "delete from cards where id=?", c.id
      return
    end
    db.exec "update cards set next_review=?, interval=?, e=? where front=?", c.next_review, c.interval, c.e_factor, c.front
  end

  def run_session(count : Int)
    sess = get_session(count)
    remaining = sess.size
    if remaining == 0
      puts "Nothing to study right now. Import a file or check back later."
    end
    sess.each do |card|
      puts "#{remaining} cards left"
      card.test
      update card
      remaining -= 1
    end
    puts "All done for now!"
  end

  def import_cards(source_file : String) 
    f = File.read(source_file)
    heading = ""
    next_stage = 0
    imported_cards = [] of Card
    card = Card.new
    f.each_line do |line|
      if line.empty?
        next
      elsif line.starts_with? "## "
        heading = line[3..]
        next
      end
      if next_stage == 0
        card = Card.new
        card.topic = heading
        card.id = line
        next_stage = 1
        if line.to_i?
          # This isn't the front, so go on to the next line
          next
        end
      end
      if next_stage == 1
        card.front = line
        next_stage = 2
        next
      end
      if next_stage == 2
        card.back = line
        imported_cards << card
        next_stage = 0
        next
      end
    end
    merge imported_cards
    puts "Imported cards from #{source_file}"
  end

  def finalize
    puts "Closing database"
    db.close
  end

end
