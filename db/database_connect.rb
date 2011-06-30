require 'mongo'
require_relative 'poetry_utils.rb'

class Database_Connect
	
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
