# Problem: Write a method that takes 1 long string and removes all the WUB's
#          from it and returns the string with the original words/song
# Input: String
# Output: String
# Steps:
# => strip the string of all wubs using a gsub invocation
# => remove all extra white space with the squeeze method

def song_decoder(str)
  new_str = str.gsub('WUB', ' ')
  new_str.squeeze(' ').strip
end

# Examples: 

p song_decoder("WUBHIWUBWUBMYWUBNAMEWUBISWUB")
# => "HI MY NAME IS"
p song_decoder("WUBDOWUBWUBYOUWUBWUBWUBWUBREALLYWUBWANTWUBTOWUBWUBHURTWUBWUBME")
# => "DO YOU REALLY WANT TO HURT ME"