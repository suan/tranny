require 'spec_helper'
require 'date'

describe Tranny do
  describe "convert" do
    it "returns real hashes" do
      class TestTranny < Tranny
        transform do
          input "foo" => :baz
        end
      end

      input_hash = { "foo" => "bar" }
      result = TestTranny.convert(input_hash)
      result[:missing].should be_nil
    end

    it "can call instance methods from :via" do
      class TestTranny < Tranny
        transform do
          input "foo" => :foo, :via => lambda { |value| my_method(value) }
        end
        def my_method(value); value.reverse; end
      end

      input_hash = { "foo" => "bar" }
      TestTranny.convert(input_hash).should == { :foo => "rab" }
    end

    context "via is a symbol" do
      it "can call instance methods via a symbol" do
        class TestTranny < Tranny
        transform do
          input "foo" => :foo, :via => :single_arg_method
          input_multiple ["num1", "num2"] => :diff, :via => :multi_arg_method
          input :nums => :diff2, :via => :multi_arg_method
          input :nums => :splat_1, :via => :splat_method
          input "foo" => :foo_splat, :via => :splat_method
        end

        def single_arg_method(value); value.reverse; end
        def multi_arg_method(value1, value2); value1 - value2; end
        def splat_method(*arg); arg.join(", "); end
      end

      input_hash = { "foo" => "bar", "num1" => 100, "num2" => 50, :nums => [100, 50] }

      desired_hash = {:foo => "rab", :diff => 50, :diff2 => 50, :splat_1 => "100, 50", :foo_splat => "bar" }
      TestTranny.convert(input_hash).should == desired_hash
      end
    end

    context "the input key is missing" do
      it "does not set it in the output" do
        class TestTranny < Tranny
          transform do
            input "birth_date" => :birthday, :via => lambda { |d| d.strftime('%F') }
          end
        end

        input_hash = { "foo" => "bar" }
        TestTranny.convert(input_hash).should == {}
      end

      context "the input key is present but the value is nil" do
        it "does set it in the input" do
          class TestTranny < Tranny
            transform do
              input "foo" => :bar
            end
          end

          input_hash = { "foo" => nil }
          desired_hash = { :bar => nil }

          TestTranny.convert(input_hash).should == desired_hash
        end
      end

      it "can set a default value" do
        class TestTranny < Tranny
          transform do
            input "birth_date" => :birthday, :default => Date.today
            input "death_date" => :deathday, :default => lambda { Date.today + 5 }
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :birthday => Date.today, :deathday => Date.today + 5 }

        TestTranny.convert(input_hash).should == desired_hash
      end
    end

    context "inserting keys" do
      it "should insert the key regardless of the input hash" do
        class TestTranny < Tranny
          transform do
            insert :bar => 'bar', :quux => 'quux'
          end
        end

        input_hash = { "foo" => "foo" }
        desired_hash = { :bar => 'bar', :quux => 'quux' }
        TestTranny.convert(input_hash).should == desired_hash
      end
    end

    context "the value has no transform" do
      it "should produce the same key (string)" do
        class TestTranny < Tranny
          transform do
            input :from => "foo", :to => "foo"
          end
        end

        input_hash = { "foo" => "bar" }

        TestTranny.convert(input_hash).should == input_hash
      end

      it "should produce the same key via shorthand (symbol)" do
        class TestTranny < Tranny
          transform do
            input :foo => :foo
          end
        end

        input_hash = { :foo => :bar }

        TestTranny.convert(input_hash).should == input_hash
      end

      it "should change the key (string to symbol)" do
       class TestTranny < Tranny
          transform do
            input "foo" => :foo
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :foo => "bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should change the key (symbox to key)" do
        class TestTranny < Tranny
          transform do
            input :foo => "foo"
          end
        end

        desired_hash = { "foo" => "bar" }
        input_hash = { :foo => "bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

    end

    context "the value should be capitalized" do
       it "should produce the same key" do
        class TestTranny < Tranny
          transform do
            input "foo" => "foo", :via => :capitalize
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { "foo" => "Bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should produce a different key" do
        class TestTranny < Tranny
          transform do
            input "foo" => :foo, :via => lambda { |x| x.capitalize }
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :foo => "Bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

    end

    context "use nested input" do
      it "should produce the same key without nesting" do
        class TestTranny < Tranny
          transform do
            input ["foo", "bar"] => "bar"
          end
        end

        input_hash = { "foo" => { "bar" => "FOOBAR!" } }
        desired_hash = { "bar" => "FOOBAR!" }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should produce a different key without nesting" do
        class TestTranny < Tranny
          transform do
            input ["foo", "bar"] => :foo_bar
          end
        end

        input_hash = { "foo" => { "bar" => "FOOBAR!" } }
        desired_hash = { :foo_bar => "FOOBAR!" }

        TestTranny.convert(input_hash).should == desired_hash
      end
    end

    context "use nested output" do
      it "should produce the same key, but nested" do
        class TestTranny < Tranny
          transform do
            input :foo => [:bar, :foo]
          end
        end

        input_hash = { :foo => "FOO!" }
        desired_hash = { :bar => { :foo => "FOO!" } }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should produce a different key, but nested" do
        class TestTranny < Tranny
          transform do
            input "foo" => [:bar, :foo]
          end
        end

        input_hash = { "foo" => "FOO!" }
        desired_hash = { :bar => { :foo => "FOO!" } }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should produce a different key, but nested (with string keys)" do
        class TestTranny < Tranny
          transform do
            input "foo" => ["bar", "foo"]
          end
        end
 
        input_hash = { "foo" => "FOO!" }
        desired_hash = { "bar" => { "foo" => "FOO!" } }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should use nested input and produce the same key, but nested differently" do
        class TestTranny < Tranny
          transform do
            input ["foo", "bar"] => ["baz", "bar"]
          end
        end

        input_hash = { "foo" => { "bar" => "BAR!" } }
        desired_hash = { "baz" => { "bar" => "BAR!" } }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should use nested input and produce a different key, but nested differently" do
        class TestTranny < Tranny
          transform do
            input ["foo", "bar"] => [:baz, :bar]
          end
        end

        input_hash = { "foo" => { "bar" => "BAR!" } }
        desired_hash = { :baz => { :bar => "BAR!" } }

        TestTranny.convert(input_hash).should == desired_hash
      end
    end

    context "use multiple inputs" do
      it "should join two elements with a space and produce a single key" do
        class TestTranny < Tranny
          transform do
            input_multiple [:foo, :bar] => :foo_bar
          end
        end

        input_hash = { :foo => "Foo", :bar => "Bar" }
        desired_hash = { :foo_bar => "Foo Bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

      it "should join two nested elements with a dash, via a lambda and produce a single key" do
        class TestTranny < Tranny
          transform do
            input_multiple [[:foo, :bar], [:baz, :qux]] => :bar_qux, :via => lambda { |x| x.join("-") }
          end
        end

        input_hash = { :foo => { :bar => "fbar" }, :baz => { :qux => "bqux" } }
        desired_hash = { :bar_qux => "fbar-bqux" }

        TestTranny.convert(input_hash).should == desired_hash
      end
    end

  end

  context "multiple trannies" do
    it "does not share transformations between unrelated subclasses" do
      class TrannyA < Tranny
        transform do
          input "foo" => :foo
        end
      end

      class TrannyB < Tranny
        transform do
          input "bar" => :bar
        end
      end

      input_hash = { "foo" => "fooval", "bar" => "barval" }
      TrannyA.convert(input_hash).should == { :foo => "fooval" }
      TrannyB.convert(input_hash).should == { :bar => "barval" }
    end
  end

  context "passthrough" do

    it "ignores a passthrough'd key if it is absent" do
      class TestTranny < Tranny
        transform do
          passthrough :foo
          input :bar => :bar_key
        end
      end

      input_hash = { :bar => 'one' }
      desired_hash = { :bar_key => 'one' }

      result = TestTranny.convert(input_hash)
      result.should == desired_hash
    end

    it "does not ignore the passthrough key if it is present but nil" do
      class TestTranny < Tranny
        transform do
          passthrough :foo
          input :bar => :bar_key
        end
      end

      input_hash = { :bar => 'one', :foo => nil }
      desired_hash = { :bar_key => 'one', :foo => nil }

      result = TestTranny.convert(input_hash)
      result.should == desired_hash
    end

  end

  context "non-hashes" do
    it "works with objects that respond to to_hash" do
      class TestTranny < Tranny
        transform do
          passthrough :foo
          input :bar => :bar_key
        end
      end

      class NonHash
        def to_hash
          { :foo => "FOO", :bar => 'BAR' }
        end
      end

      input_object = NonHash.new
      desired_hash = { :bar_key => 'BAR', :foo => "FOO" }

      result = TestTranny.convert(input_object)
      result.should == desired_hash
    end
  end
end
