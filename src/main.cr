require "option_parser"

require "./exercise.cr"
require "./collection.cr"

db_file = ENV["SRSH_DB"]? || "~/srsh.db"

OptionParser.parse do |parser|
  parser.on("-d PATH", "--database=PATH", "Database file to use") do |db_path|
    db_file = db_path
  end
end

puts "Using database #{db_file}"

collection = Collection.new db_file

if ARGV[0]? == "id"
  puts collection.max_id + 1
elsif ARGV[0]? == "import"
  collection.import ARGV[1]
else
  collection.run_session(20)
end
