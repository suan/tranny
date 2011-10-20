require 'spec_helper'

describe Tranny do
  describe "convert" do
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
end
