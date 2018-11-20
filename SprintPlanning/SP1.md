# Spring Planning Meeting #1 
*11-19-2018*

This week the navigation flow of the app was fine-tuned, the backend implementation details were researched and determined, a view and API were created to add and edit events, and an event feed view was developed. The calendar view and login view were started but ended up being more complex than anticipated. Some planned tasks were rolled over to next week.

## Trello Board
https://trello.com/b/Kk6IVYPB/ecs-189e-the-xcoders


##Lindsey Gray - Weekly Progress

### Done:
1.  Event Class  
<https://github.com/ECS189E/ClubHub/commit/118a4fc2288cac120c176d5c9611ec68800d6a55>
Created an Event class with initialization functions and a print function for debugging.

* Event API 
<https://github.com/ECS189E/ClubHub/commit/118a4fc2288cac120c176d5c9611ec68800d6a55>
Created an EventApi struct for adding, updating, deleting, and getting events from a firebase database.

* Add/Edit Event 
<https://github.com/ECS189E/ClubHub/commit/118a4fc2288cac120c176d5c9611ec68800d6a55>
Created a view controller for adding new events or editing existing ones. Includes basic event information and the ability to add an event image.

* Event Feed 
<https://github.com/ECS189E/ClubHub/commit/4d4c659161b7e8dd9656361da24c077a4afcc5a7> 
Created a table view controller that displays all upcoming events. Events are ordered by date and old events are filtered out.
Implemented a search controller for the feed that searches by event and club name.

### Doing:
1. Fixing a bug related to keyboard resignation in the add/edit events view controller

### Planned:
1. Allow event images to be deleted 
* Filter Event Feed  (User/All)
* Start calendar table view for 
* Add images to the database (with Cindy)


## Sravya Divakarla - Weekly Progress

### Done:
1. Research Application Flow  
Planned out the flow of the app and researched how the flow would play out into the code. Researched what was the best way to organize the data and the flow since there were many components to the app. 

* Create Club Class  
Created a class with basic information such as name IDs, club IDs, and events IDs

### Doing:
1. Login  <https://github.com/ECS189E/ClubHub/commit/86849686b03596bc509a5059e51e89952ce5abfd>
I am working on the login however it is not complete yet

* Club/User Profile and Club API  
The login implementation took longer than expected so these tasks will be moved for next week

### Planned:
1. Club/User Profile
* Club API  
* Club Feed   


## Cindy Hoang  - Weekly Progress

### Done:
1. Research Data Models  
<https://codeshare.io/5OXdrj> 

*  Check with Profiles/Events for data population 
Checked out different Firebase social networking applications and found relevancy in flattened data modeling. Created a baseline model for how each object will reference data from another. Redundancy is required, which means any changes to membership will need manual updates to multiple locations.

* Setup Database  
Setup backend support through Firebase

* Research Server Support  
Researched if firebase was the best option

### Doing:
1. Write Technical Design Doc for Data Model and Review
<http://bit.ly/clubhubTDD>

* Started writing up TDD for Firebase database model to have uniform naming/referencing across objects and smooth out any potential disputes.

### Planned:
1. Event Details

* Event Details  View

* Research Real-time/Refresh Updates

* Test out database requests with a Pull-to-Refresh model in a mock app

* Add images to the database (with Lindsey)


## Srivarshini Ananta  - Weekly Progress

### Done:
Setting up the calendar view took longer than predicted and was not completed. Will continue tasks next week.

### Doing:
1. Setup Calendar View  
Will finish calendar view next week.

### Planned:
1. Setup Calendar View
* Adding Events to Calendar
* Selected Days Events view
