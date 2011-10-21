require "tranny/version"

class Tranny

  class << self
    attr_reader :transform_block

    def convert(input_hash)
      new.convert(input_hash)
    end

    def transform(&trans_block)
      @transform_block = trans_block
    end
  end

  def initialize
    @output_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  end

  def convert(input)
    @input_hash = input
    instance_exec(&self.class.transform_block)
    Hash[@output_hash]
  end

  private

  def set_val(dst, val)
    if dst.is_a? Array
      last_key = dst.pop
      dst.reduce(@output_hash) { |h,k| h[k] }[last_key] = val
    else
      @output_hash[dst] = val
    end
  end

  def get_val(src)
    if src.is_a? Array
      src.reduce(@input_hash) { |h,k| h[k] }
    else
      @input_hash[src]
    end
  end

  def parse_options(options)
    from, to, via = nil

    via = options[:via] if options.key? :via
    options.delete :via

    from, to = if options.key? :from and options.key? :to
      [options[:from], options[:to]]
    else
      options.delete :from
      options.delete :to

      lazy_args = options.shift
      if lazy_args.is_a? Array and lazy_args.length == 2
        lazy_args
      end
    end

    [from, to, via]
  end

  def passthrough(*options)
    options.each do |k|
      input_value = get_val(k)
      set_val(k, input_value)
    end
  end

  def input_multiple(options)
    from, to, via = parse_options(options)
    via = lambda { |x| x.join(" ") } if via.nil?

    old_values = from.map{ |k| get_val(k) }
    new_value = via.call old_values

    set_val(to, new_value)
  end

  def input(options)
    from, to, via = parse_options(options)

    new_value = if via.is_a? Proc
      via.call get_val(from)
    elsif via.is_a? Symbol
      get_val(from).send(via)
    else
      get_val(from)
    end

    set_val(to, new_value)
  end

end
