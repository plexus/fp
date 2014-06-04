class Proc
  include FP

  def *(other)
    compose(self, other)
  end

  def |(other)
    compose(other, self)
  end

  def trace(name = nil)
    ->(*args) { p :"#{name}_in" => args ; self.(*args).tap{|result| p "#{name}_out" => result } }
  end
end

class Symbol
  [:*, :|, :trace].each do |sym|
    define_method sym do |*args|
      to_proc.public_send(sym, *args)
    end
  end
end

class Method
  [:*, :|, :trace].each do |sym|
    define_method sym do |*args|
      to_proc.public_send(sym, *args)
    end
  end
end

class Symbol
  def []
    ->(hsh) { hsh[self] }
  end
end
