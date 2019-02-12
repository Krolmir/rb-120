# my_car.rb

# Module for towing things :p
module Towable
  def tow
    'I can tow things'
  end
end

# Class built for vehicles
class Vehicle
  attr_accessor :color
  attr_reader :year, :model
  attr_writer :vehicle_count

  @@vehicle_count = 0

  def initialize(y, m, c)
    @year = y
    @color = c
    @model = m
    @speed = 0
    @@vehicle_count += 1
  end

  def speed_up(number)
    @speed += number
    puts "You're speeding up by #{number}."
  end

  def brake(number)
    @speed -= number
    puts "You're slowing down by #{number}."
  end

  def current_speed
    puts "You're current speed is #{@speed}."
  end

  def shut_down
    @speed = 0
    puts "You've shut off the car!"
  end

  # Add a class method that calculates the gas mileage of any car
  def self.calculate_gas_mileage(miles, gallons)
    puts "The gas mileage is #{miles / gallons} miles per gallon."
  end

  # Overide the to_s method to creat a user friendly print out of your object
  def to_s
    "The vehicles's model is #{model}, the year it's from is #{year}, and "\
    "the color is #{color}."
  end

  def spray_paint(color)
    self.color = color
    puts "You're vehicle has been colored #{color}. Enjoy!"
  end

  # Create a variable that can keep track of the number of objects created
  # that inherit from this superclass. Also creat a method to print it
  def self.vehicle_counter
    puts "The number of vehicle objects created is #{@@vehicle_count}"
  end

  # Write a method age that calls a private method to calculate the age of the
  # vehicle

  def age
    puts "The age of the #{model} is #{calculate_age}."
  end

  private

  def calculate_age
    Time.now.year - year
  end
end

# Class for cars
class MyCar < Vehicle
  NUMBER_OF_DOORS = 4
end

# Class for trucks
class MyTruck < Vehicle
  include Towable

  NUMBER_OF_DOORS = 2
end

lumina = MyCar.new(1997, 'chevy lumina', 'white')
pries = MyCar.new(2004, 'toyota pries', 'black')
escalade = MyCar.new(2017, 'chevy escalade', 'white')
explorer = MyTruck.new(2019, 'ford explorer', '')
lumina.speed_up(20)
lumina.current_speed
lumina.speed_up(20)
lumina.current_speed
lumina.brake(20)
lumina.current_speed
lumina.brake(20)
lumina.current_speed
lumina.shut_down
lumina.current_speed
puts lumina.year
puts lumina.color
lumina.color = 'blue'
puts lumina.color
lumina.spray_paint('green')
puts lumina.color
MyCar.calculate_gas_mileage(350, 15)
puts lumina
Vehicle.vehicle_counter
puts explorer.tow
puts Vehicle.ancestors
puts MyCar.ancestors
puts MyTruck.ancestors
puts lumina.age
puts pries.age
puts escalade.age
puts explorer.age
