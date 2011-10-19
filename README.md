Tranny
======

Tranny provides a simple DSL to transform a supplied hash with an arbitrary structure to another hash with an even more arbitrary structure.

Install
=======

TODO: Fill this out

Basic Usage
===========

All you have to do is create a new class and inherit from Tranny.

        class MyLittleTranny < Tranny
        end

Inside your new class you just use the hopefully not-convoluted DSL.

        class MyLittleTranny < Tranny
          transform do
            input :from => "foo", :to => :bar
          end
        end

Theres also shorthand for you lazy folks.

        input "foo" => :bar
