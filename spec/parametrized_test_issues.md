# WHAT DO I WANT TO DO? 
I want to be able to easily parametrize tests - ie, run the same test with multiple different sets of data / input. In Python, this is really just a cash of passing an array of the different test objects to the test. In Ruby this seems to be much harder. 

Specifically, I want to: 
1. Define a number of different JSON payloads which will be sent to the same test definition
2. Assert that all those different payloads will result in the same outcome
3. Abstract as much of this out of the tests as possible, to improve readability and maintainability

## The best way to achieve what I want would seem to be: 
- definining JSON payloads in a JSON file
- using a shared context to create variables for all these different JSON payloads (using a custom-defined `get_` function which returns the payload in the format I need for the test)
- pass the variables defined in the shared context to shared examples 

## The problem is that the way RSpec executes tests, it seems very difficult/impossible to send dynamically-defined values to a shared example. 

On a gut level, I might need to do one of the following: 
1. Define the JSON payloads in the spec files/a helper file, not in a separate .json file
2. Stop trying to used shared examples, and just accept the duplicate tests (it isn't THAT much repeated code, but it is a lot of clutter)

# APPROACHES OVERVIEW
x do/let assignment
- instance var in context
- let statement in context
- try various approaches without example groups
- use `subject` instead of passing a parameter

# ATTEMPT AT DESCRIBING THE PROBLEM:

2 phases in RSpec test execution:
1. Test preparation
2. Test execution

The problem is that shared examples are evaluated during the preparation stage, and when they're evaluted the value of the variables we're trying to assign hasn't been set yet - so they show up as `nil`. 

This is usually overcome with `let() {}` definitions, but 
- let definitions are lazily evaluated, so we can't define a variable outside the shared example and then pass it to the shared example as a parameter - it will still evaluate as nil
- I tried doing the let definition in a block instead of as a parameter, but that didn't work either (struggling to get the variable visibility to help me understand why)


IDEA: 
- call the get_registration function in the shared example, and in the test definition pass it a hardcoded parameter (registration ID or hash id or something)
    - didn't work - we can't call `get_registration` unless it's in a before block, and if it is in a before block it isn't ready to be assigned by the time we assign a vlue to the registration parameter. 
    - only other thing I could think of here would be assigning it directly to the registration parameter (not using let) 


# WHAT HAVE I TRIED?

## test_spec_1.rb

This is the most 'naive' implementation. 
- Payloads are instance variables defined in the context
- Payloads are NOT showing up in print statements 

Now we try to simplify to figure out at what point stuff does start working. Once we get it working, we try to add back in functionality.

## test_spec_2.rb

HARDCODE PAYLOADS IN SHARED CONTEXT

puts'ing @basic_rgistration still results in a nil output, because we're doing explicit assignment instead of let statements. That makes sense - let's try it with a let statement.

## test_spec_3.rb

LET DECLARATION OF HARDCODED PAYLOADS IN SHARED CONTEXT

Currently getting:
```bash
Failure/Error: it_behaves_like 'payload test', basic_registration
  `basic_registration` is not available on an example group (e.g. a `describe` or `context` block). It is only available from within individual examples (e.g. `it` blocks) or from constructs that run in the scope of an example (e.g. `before`, `let`, etc).
```

Ok there's a lot of things that could be going wrong here: 
- I might need to pass in the context in a let declaration in a do block to the shared example
x I might not be including the context correctly  [ moved context around and it didn't make a difference ]
x I could be referencing "basic_registration" incorrectly (`basic_registration` vs `:basic_registration`) [investigated this, don't need to reference a symbol with : to reference it]

## test_spec_4.rb

PASS PAYLOADS IN DO-LET BLOCKS

Progress: 
- basic_registration now prints from the `before` block

Issue: 
- Blank payload still being received by shared example

## test_spec_5.rb

ASSIGN THE VAR FROM SHARED CONTEXT TO NEW VARIABLE IN BEFORE BLOCK

Doesn't work - payload_1 isn't defined at the time the shared example is prepared

Question: is get_registration even working? 
