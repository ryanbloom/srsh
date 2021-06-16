require "sqlite3"
require "./exercise.cr"

class Collection
  property db : DB::Database

  def initialize(path : String)
    existed = File.exists? path
    @db = DB.open "sqlite3://" + path
    unless existed
      db.exec "create table exercises (id text primary key, topic text, front text, back text, last_review integer, next_review integer)"
    end
  end

  def max_id : Int32
    highest = 0
    db.query "select id from exercises " do |rs|
      rs.each do
        id = rs.read(String).to_i?
        if id && id > highest
          highest = id
        end
      end
    end
    return highest
  end

  def merge(new_exercises : Array(Exercise))
    new_exercises.each do |e|
      db.exec "insert into exercises values (?, ?, ?, ?, ?, ?) ON CONFLICT(id) DO UPDATE SET topic=?, front=?, back=?", e.id, e.topic, e.front, e.back, e.last_review, e.next_review, e.topic, e.front, e.back
    end
  end

  def get_session(count : Int)
    exercises = [] of Exercise
    db.query "select * from exercises where next_review < #{Time.utc.to_unix} order by next_review asc limit #{count}" do |rs|
      rs.each do
        id = rs.read(String)
        topic = rs.read(String)
        front = rs.read(String)
        back = rs.read(String)
        last_review = rs.read(Int64)
        next_review = rs.read(Int64)

        exercises << Exercise.new(id, topic, front, back, last_review, next_review)
      end
    end
    return exercises
  end

  def update(e : Exercise)
    if e.deleted
      db.exec "delete from exercises where id=?", e.id
      return
    end
    db.exec "update exercises set last_review=?, next_review=? where id=?", e.last_review, e.next_review, e.id
  end

  def run_session(count : Int)
    sess = get_session(count)
    remaining = sess.size
    if remaining == 0
      puts "Nothing to study right now. Import a file or check back later."
    end
    sess.each do |exercise|
      puts "#{remaining} exercises left"
      exercise.test
      update exercise
      remaining -= 1
    end
    puts "All done for now!"
  end

  def import(source_file : String) 
    f = File.read(source_file)
    heading = ""
    next_stage = 0
    imported_exercises = [] of Exercise
    exercise = Exercise.new
    f.each_line do |line|
      if line.empty?
        next
      elsif line.starts_with? "# "
        heading = line[2..]
        next
      end
      if next_stage == 0
        exercise = Exercise.new
        exercise.topic = heading
        exercise.id = line
        next_stage = 1
        if line.to_i?
          # This isn't the front, so go on to the next line
          next
        end
      end
      if next_stage == 1
        exercise.front = line
        next_stage = 2
        next
      end
      if next_stage == 2
        exercise.back = line
        imported_exercises << exercise
        next_stage = 0
        next
      end
    end
    merge imported_exercises
    puts "Imported exercises from #{source_file}"
  end

  def finalize
    puts "Closing database"
    db.close
  end

end
