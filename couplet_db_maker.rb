require './database_maker.rb'

class Couplet_DB_Maker < Database_Maker

	COUPLET_CORPUS = "couplet_corpus"
	RHYMES = "rhymes"
	
	private 

	def make_tests
		# Declare tests
		tests = []
		length = { :name => "length", :func => lambda { |line| line.length } }
		tests << length

		first_word = { :name => "firstword", 
			       :func => select_word(0) }
		tests << first_word
		last_word = { :name => "lastword", 
			      :func => select_word(-1) }
		tests << last_word
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
		process(file) do |db,line|
			couplet_corpus = db[COUPLET_CORPUS]
			rhymes = db[RHYMES]

			insert_corpus_row(line,tests,couplet_corpus)
		end
	end
end
