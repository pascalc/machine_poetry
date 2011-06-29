require 'mongo'
require 'iconv'

class Database_Maker
	
	protected

	DB_NAME = "machine_poetry_db"
	
	def connect_db
	  @conn = Mongo::Connection.new
	  db = @conn.db(DB_NAME)
	end	

	def clean(line)
	  # Fix UTF8 issues
	  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
	  line = ic.iconv(line << ' ')[0..-2]
	  
	  line.strip! == "" ? false : line
	end

	def select_word(index)
	  lambda do |line|
	    words = line.scan(/[a-zA-Z\-']+/)
	    words[index]
	  end
	end

	def close_db
	  @conn.close
	end

	public

	def process(file)
	  db = connect_db
	  file.lines.each do |line|
	    next unless line = clean(line)
	    yield(db,line)
	   end
	  close_db
	end
end
