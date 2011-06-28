#!/usr/bin/env ruby

require 'mongo'
require 'iconv'

#### VARIABLES ####

SCRIPT_NAME = "make_database.rb"
DB_NAME = "machine_poetry_db"
CORPUS_NAME = "corpus"

# Declare tests
tests = []
length = { :name => "length", :func => lambda { |line| line.length } }
tests << length

def select_word(index)
  lambda do |line|
    words = line.scan(/[a-zA-Z\-']+/)
    words[index]
  end
end
first_word = { :name => "firstword", 
               :func => select_word(0) }
tests << first_word
last_word = { :name => "lastword", 
              :func => select_word(-1) }
tests << last_word

#### FUNCTIONS ####

def clean(line)
  # Fix UTF8 issues
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  line = ic.iconv(line << ' ')[0..-2]
  
  line.strip! == "" ? false : line
end

def process(file,tests,corpus)
  file.lines.each do |line|
    next unless line = clean(line)
    row = { "text" => line }
    tests.each do |test|
      row[test[:name]] = test[:func].call(line)
    end
    corpus.insert(row)
  end
end

#### SCRIPT #######

if not ARGV.length == 1
  puts "USAGE: #{SCRIPT_NAME} [corpus]"
  exit
end

# Connect to the database
conn = Mongo::Connection.new
db = conn.db(DB_NAME)
db.drop_collection(CORPUS_NAME)
corpus = db[CORPUS_NAME]

# Process corpus.txt
file = File.open(ARGV[0])
process(file,tests,corpus)

# Disconnect from the database
conn.close

puts "Corpus #{ARGV[0]} stored in collection #{CORPUS_NAME} in MongoDB database #{DB_NAME}."