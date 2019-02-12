class Student
  attr_accessor :name
  
  def initialize(name, grade)
    @name = name
    @grade = grade
  end
  
  # Grade needs to be private
  def better_grade_than?(compare_name)
    self.grade > compare_name.grade
  end      
  
  protected
  
  def grade
    @grade
  end
end

joe = Student.new('joe', 80)
bob = Student.new('bob', 75)
puts "well done!" if joe.better_grade_than?(bob)

