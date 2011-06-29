require 'iconv'

module PoetryUtils
    # patterns that subtract 1 from the syllable count
       SubSyl = 
        ['cial',
	     'tia',
	     'cius',
	     'cious',
	     'giu',              # belgium!
	     'ion',
	     'iou',
	     'sia$',
	     '.ely$']            # absolutely! (but not ely!)
         
      # patterns that add 1 to the syllable count
      AddSyl = [ 
	   'ia',
	   'riet',
	   'dien',
	   'iu',
	   'io',
	   'ii',
	   '[aeiouym]bl$',     # -Vble, plus -mble
	   '[aeiou]{3}',       # agreeable
	   '^mc',
	   'ism$',             # -isms
	   '([^aeiouy])\1l$',  # middle twiddle battle bottle, etc.
	   '[^l]lien',         # alien, salient [1]
           '^coa[dglx].',      # [2]
	   '[^gq]ua[^auieo]',  # i think this fixes more than it breaks
 	   'dnt$',           # couldn't
	  ]
        
    def PoetryUtils.syllables(word)
            word = word.downcase
            word = word.gsub(/\'/,"")	# fold contractions.  not very effective.
            word = word.gsub(/e$/, "")	# strip trailing "e"s
            scrugg = word.split(/[^aeiouy]+/).select{|s| s.length > 0} 
            count = 0;
            # special cases
            SubSyl.each { |syll| count = count - 1 if word.match(syll) }
            AddSyl.each { |syll| count = count + 1 if word.match(syll) }
            count = count + 1 if word.length == 1	# 'x'
            # count vowel groupings
            count = count + scrugg.length
            return (count == 0) ? 1 : count-1 
    end

    def PoetryUtils.clean(line)
	  # Fix UTF8 issues
	  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
	  line = ic.iconv(line << ' ')[0..-2]
	  
	  line.strip! == "" ? false : line
	end

    def PoetryUtils.words(line)
      line.scan(/[a-zA-Z\-']+/)
    end

    def PoetryUtils.select_word(index)
	  lambda do |line|
	    PoetryUtils.words(line)[index]
	  end
	end

    def PoetryUtils.clean_lines(file)
      file.lines.each do |line|
	    next unless line = PoetryUtils.clean(line)
	    yield(line)
	   end
    end
end
