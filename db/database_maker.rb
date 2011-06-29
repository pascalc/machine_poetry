require 'mongo'
require './poetry_utils.rb'

class Database_Maker
	
	protected

	DB_NAME = "machine_poetry_db"
	
	def connect_db
	  @conn = Mongo::Connection.new
	  db = @conn.db(DB_NAME)
	end	

	def close_db
	  @conn.close
	end

	public

	def process(file)
	  db = connect_db
	  file.lines.each do |line|
	    next unless line = PoetryUtils.clean(line)
	    yield(db,line)
	   end
	  close_db
	end
end
