require 'mongo'
require './poetry_utils.rb'

class Database_Maker
	
	protected

	DB_NAME = "machine_poetry_db"
	
	def connect
	  @conn = Mongo::Connection.new
	  db = @conn.db(DB_NAME)
	end	

	def close
	  @conn.close
	end

	public

    def database
      db = connect
      yield(db)
      close
    end
end
