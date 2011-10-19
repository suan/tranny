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
       it "should produce the same key and the value should be capitalized" do
        class TestTranny < Tranny
          transform do
            input "foo" => "foo", :via => :capitalize
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { "foo" => "Bar" }

        TestTranny.convert(input_hash).should == desired_hash
      end

      
    end
  end
end
