Tranny
======

Tranny provides a simple DSL to transform a supplied hash with an arbitrary structure to another hash with an even more arbitrary structure.

***Note:*** *Tranny does not simply modify the hash you have passed in. It actually creates a new hash from scratch. It only copies or does transformations on the fields you specify in the transform block.*

Support
=======

Should work for both 1.8 and 1.9 rubies.

Install
=======

Standard gem install.

        gem install tranny


Put this in your Gemfile.

        gem "tranny"

or

        gem "tranny", :git =>
          "git://github.com/joshkrueger/tranny.git"

Basic Usage
===========

All you have to do is create a new class and inherit from Tranny.

        class ExampleTranny < Tranny
        end

Inside your new class you just use the hopefully not-convoluted DSL.

        class ExampleTranny < Tranny
          transform do
            input :from => "foo", :to => :bar
          end
        end

Theres also shorthand for you lazy folks.

        input "foo" => :bar
        
But how do I do more than just re-name my keys?

Let's start simple. Lets take the following hash

        { "foo" => "party" }

and have Tranny change it to

        { :foo => "Party" }

Its pretty easy!

        input "foo" => :foo, :via => :capitalize

See! Nice and simple!

Tranny with a block!

        input "foo" => :foo, :via => lambda { |x| x.capitalize }

Actually Using Tranny
================

So we have our ExampleTranny we created above (with our capitalize transform), saved somewhere. Lets say its in your "lib" folder. Anywhere it's loadable via require should be fine.

        require 'tranny'
        require 'example_tranny'

        contrived_input_hash = { "foo" => "bar" }

        output_hash = ExampleTranny.convert(contrived_input_hash)

and now output_hash should look like

        { :foo => "Bar" }

Congratulations! Go have a beer. You deserve it.

Slightly Less Basic Usage
=================

Want to combine multiple input keys? **TRANNY CAN DO THAT**
        
        input_multiple ["foo", "bar"] => :foo_bar

By default Tranny will just join the multiple elements with a space. i.e. "wham" and "bam" become "wham bam". Need something more complicated?

        input_multiple ["foo", "bar"] => :foo_bar, :via => lambda { |x| x.map{ |v| v.capitalize }.join(" ") }

Here, "wham" and "bam" become "Wham Bam". Easy right?

Hrmm. What about nested hashes? No problem. Just define the nesting order in an array.

Lets start with nested inputs. Given the hash

        { "foo" => { "bar" => "sample text" } }

and a desired hash of

        {  "example" => "sample text" }

we would give Tranny the following operation

        input ["foo", "bar"] => "example"

If we want the opposite, all we do is reverse it.

        input "example" => ["foo", "bar"]

Nested to nested?

        input ["foo", "bar"] => ["baz", "qux"]

this turns

        { "foo" => { "bar" => "hello world" } }

into

        { "baz" => { "qux" => "hello world" } }

Want to combine multiple inputs when one or more are an array?

        input [ [ "foo", "bar" ], "baz" ] => "combined nested hash"

Want to simply pass some parts of your original hash through? Simply specify the keys you want passed through:

        passthrough :this_one, :that_one

Want to pass every part of your original hash that was not transformed through? **TRANNY CAN DO THAT TOO!** Simply add the following at the _end_ of your `transform` block:

        passthrough_remaining

***Note:*** *You MUST specify it only at the end of your `transform` block, as Tranny needs to know all the keys that were transformed before it!*

Shorthand Limitations
==============

Hey, the shorthand isn't perfect and theres really only a couple scenarios I can think of. If you have a key on your input hash of :via, you can't use the shorthand.

        input :via => :not_via

That won't work. Why? **I'm lazy** So just use the long format.

        input :from => :via, :to => :not_via, :via => :capitalize

However, :from or :to will work just fine in the shorthand. The longhand syntax only works if both the :from and :to symbols are passed in.

        input :from => "from"

That will work.

