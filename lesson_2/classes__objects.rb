class Person
  attr_reader :first_name, :last_name
  
  def initialize(name)
    parse_full_name(name)
  end
  
  def name=(name)
    parse_full_name(name)
  end
  
  def name
    @first_name + ' ' + @last_name
  end
  
  def first_name=(f_name)
    @first_name = f_name
  end    
  
  def last_name=(l_name)
    @last_name = l_name
  end
  
  def to_s
    name
  end

  private
  
  def parse_full_name(name)
    self.first_name, self.last_name = name.split(' ')
    
    if self.last_name == nil
      self.last_name = ''
    end
  end
end


bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')

p bob.name == rob.name

bob = Person.new("Robert Smith")
puts "The person's name is: #{bob}"