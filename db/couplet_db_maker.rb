require './poetry_utils.rb'
require './database_maker.rb'

class Couplet_DB_Maker < Database_Maker

	COUPLET_CORPUS = "couplet_corpus"
	RHYMES = "rhymes"
	
	private 

	def make_tests
		tests = []

        # Line length
		length = { :name => "length", :func => lambda { |line| line.length } }
		tests << length

        # First word in line
		first_word = { :name => "firstword", 
			       :func => PoetryUtils.select_word(0) }
		tests << first_word

        # Last word in line
		last_word = { :name => "lastword", 
			      :func => PoetryUtils.select_word(-1) }
		tests << last_word

        # Number of syllables in line
        syllables = { :name => "syllables",
                  :func => lambda do |line|
                            #  PoetryUtils.words(line).map {|w| PoetryUtils.syllables(w) }.inject(:+)
                            PoetryUtils.syllables(line)
                           end }
        tests << syllables       
	end
	
	def insert_corpus_row(line,tests,corpus) 
		row = { "text" => line }
		tests.each do |test|
			row[test[:name]] = test[:func].call(line)
		end
		corpus.insert(row)
	end
	
	public

	def make_db(filename)
		tests = make_tests
		file = File.open(filename)
        database do |db|
                db.drop_collection(COUPLET_CORPUS)
                db.drop_collection(RHYMES)
                couplet_corpus = db[COUPLET_CORPUS]
                rhymes = db[RHYMES]
                PoetryUtils.clean_lines(file) { |line| insert_corpus_row(line,tests,couplet_corpus) }
        end
	end
end
