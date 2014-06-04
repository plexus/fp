module FP
  def Proc(obj)
    return obj if obj.is_a? Proc
    return obj.to_proc if obj.respond_to?(:to_proc)
    obj.method(:call).to_proc
  end

  I = ->(x) {x}

  def fkey(key)
    ->(hsh) { hsh[key] }
  end

  def fsend(symbol, *args)
    ->(obj) { obj.public_send(symbol, *args) }
  end

  def infix(symbol)
    ->(obj, other) { obj.public_send(symbol, other) }
  end

  def juxt(*procs)
    ->(*args) { procs.map(&fsend(:call, *args)) }
  end

  def fapply(proc = nil)
    if proc
      ->(args) { Proc(proc).call(*args) }
    else
      ->(args) { Proc(args.first).call(*args.drop(1)) }
    end
  end

  def box_args
    ->(*args) { args }
  end

  def unbox_args(proc)
    ->(args) { proc.(*args) }
  end

  def by_args(*procs)
    ->(*args) {
      procs.zip(args).map &fapply
    }
  end

  def compose(*procs)
    return I if procs.empty?
    ->(*args) {
      compose(*procs.map(&method(:Proc)).take(procs.count-1)).(procs.last.(*args))
    }
  end

  def pair2hsh(proc = nil)
    if proc
      compose(pair2hsh, Proc(proc))
    else
      ->(x) {{x[0]=>x[1]}}
    end
  end

  def fn
    MethodObjectProxy.new(self)
  end

  class MethodObjectProxy < BasicObject
    def initialize(subject)
      @subject = subject
    end

    def method_missing?(method, *args)
      args.empty? ? @subject.method(method) : @subject.method(method).to_proc.curry.(*args)
    end
  end
end
