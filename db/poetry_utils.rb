require 'iconv'

module PoetryUtils
    def PoetryUtils.clean(line)
	  # Fix UTF8 issues
	  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
	  line = ic.iconv(line << ' ')[0..-2]
	  
	  line.strip! == "" ? false : line
	end

    def PoetryUtils.select_word(index)
	  lambda do |line|
	    words = line.scan(/[a-zA-Z\-']+/)
	    words[index]
	  end
	end
end
