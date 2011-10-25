require "tranny/version"

class Tranny

  class << self
    attr_reader :transform_block

    attr_reader :input_nest
    attr_reader :output_nest

    def convert(input_hash)
      new.convert(input_hash)
    end

    def transform(&trans_block)
      @transform_block = trans_block
    end

  end

  def initialize
    @output_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @input_nest = []
    @output_nest = []
  end

  def convert(input)
    @input_hash = input
    instance_exec(&self.class.transform_block)
    Hash[@output_hash]
  end

  private

  def set_val(dst, val)

    dst = (@output_nest + [dst]).flatten unless @output_nest.empty?

    if dst.is_a? Array
      last_key = dst.pop
      dst.reduce(@output_hash) { |h,k| h[k] }[last_key] = val
    else
      @output_hash[dst] = val
    end
  end

  def get_val(src)

    src = (@input_nest + [src]).flatten unless @input_nest.empty?

    if src.is_a? Array
      src.reduce(@input_hash) { |h,k| h[k] }
    else
      @input_hash[src]
    end
  end

  def parse_options(options)
    from, to, via, default = nil

    via = options[:via] if options.key? :via
    options.delete :via

    default = options[:default] if options.key? :default
    options.delete :default

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

    [from, to, via, default]
  end

  def passthrough(*options)
    options.each do |k|
      input_value = get_val(k)
      set_val(k, input_value)
    end
  end

  def input_multiple(options)
    from, to, via, default = parse_options(options)
    via = lambda { |x| x.join(" ") } if via.nil?

    old_values = from.map{ |k| get_val(k) }
    new_value = via.call old_values

    set_val(to, new_value)
  end

  def input(options)
    from, to, via, default = parse_options(options)
    return if get_val(from).nil? && default.nil?

    new_value = if get_val(from).nil? && !default.nil?
      default.respond_to?(:call) ? default.call : default
    elsif via.is_a? Proc
      via.call get_val(from)
    elsif via.is_a? Symbol
      get_val(from).send(via)
    else
      get_val(from)
    end

    set_val(to, new_value)
  end

  def insert(options)
    options.each { |key, value| set_val(key, value) }
  end

  def nested(options,  &trans_block)
    options[:type] = "output" unless options.key? :type

    if options[:type] == "output" or options[:type] == "input"
      type = options[:type]
      if options[:key]
        key = options[:key]
        nest_var = "@#{type}_nest"
        self.instance_variable_set(:"#{nest_var}", self.instance_variable_get(:"#{nest_var}") + [key].flatten)

        instance_exec(&trans_block)

        self.instance_variable_set(:"#{nest_var}", self.instance_variable_get(:"#{nest_var}") - [key].flatten)
      end
    end
  end

end
