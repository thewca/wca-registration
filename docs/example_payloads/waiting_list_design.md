# Requirements: 
- When moved to the waiting list, a registration goes to the end of the waiting list by default
- Organizer can change the order of the waiting list by moving one registration to a new position - all items should move up/down the list accordingly

# Implementation
- We could manually assign a waiting_list_position to each item, but this gets inefficient if we have a lot of waiting list items, as we have to update
tens/hundreds of records
- Instead we can use a linked list, where each registration has a waiting_list_next_user and waiting_list_previous_user property, which gives
the user_ids of the users on either side of them in the waiting list. 
- When the waiting list is built in the frontend, we can assign it a temporary waiting_list_position as this is likely easier to work with and
we'll want to display it to the user/organizer

## Updating a Waiting List Item's Position
- Update payload received with the 

Cases: 
- Move to start of list
- Move to end of list
- Move to middle of list (no shared neighbours)

# Test cases:

## Checker
x organizer can update waiting_list_position
x user cannot update waiting_list_position

## Model
- updating waiting_list position propagates to all other waiting_list items
    - move record to start
    - move record to end
    - move record to middle (not sharing any neighbours)
- add a registration to the waiting list (insert at last value)
- accept a registration from the waiting list (next-highest waiting list index becomes min)
- cancel a registration in the waiting list (move all items behind it in the list up 1 position)
- auto-assign waiting list position
    - first one added should be 1 
    - second on added should be 2
    - 10th one added should be 10th
    - 5 registrations in waiting list, one gets accepted, new one goes to waiting list, should be 5th
- don't add to waiting list if status was already waiting list
- dont change position if waiting_list_position in update == existing waiting_list_position

# TODO: Categorize these tests
