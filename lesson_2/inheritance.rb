class Animal
  def run
    'running!'
  end
  
  def jump
    'jumping!'
  end
end

class Dog < Animal
  def speak
    'bark!'
  end
  
  def swim
    'swimming!'
  end
  
  def fetch
    'fetching!'
  end
end

class Cat < Animal
  def speak
    'meow!'
  end
end

class Bulldog < Dog
  def swim
    "can't swim"
  end
end

teddy = Dog.new
puts teddy.speak           # => "bark!"
puts teddy.swim           # => "swimming!"
karl = Bulldog.new
puts karl.speak           # => "bark!"
puts karl.swim            # => "can't swim!"

pete = Animal.new
kitty = Cat.new
dave = Dog.new
bud = Bulldog.new

p pete.run                # => "running!"
# p pete.speak              # => NoMethodError

p kitty.run               # => "running!"
p kitty.speak             # => "meow!"
# p kitty.fetch             # => NoMethodError

p dave.speak              # => "bark!"

p bud.run                 # => "running!"
p bud.swim   