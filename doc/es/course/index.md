http://phptraining.in/training/codeigniter-training

https://www.udemy.com/php-codeigniter/
o
https://jream.com/product/view/php-codeigniter

http://www.lynda.com/CakePHP-tutorials/MVC-Frameworks-Building-PHP-Web-Applications/315196-2.html


----
#Currículo

##Sección 1: Setting Up
- Clase 1   Explicando MVC 
    Learn how the MVC pattern works within a few minutes with a diagram and code samples.
- Clase 2   Installing DBAX
    We will install Code Igniter, it's literally drag and drop into your PHP Directory. Note: This series assumes you know how to run PHP files in the directory you are using.
- Clase 3   Setup SQL Developer
    A brief run-through of my favorite IDE Netbeans, its up to you if you want to use this IDE. Otherwise use your favorite one.
- Clase 4   .htaccess Pretty URL's & Development Modes 
    We will use mod_rewrite so we have nice URLs.
    
##Sección 2: Project: Creating The First Sections
- Clase 5   Front-End Setup: CSS, JS, Includes (jQuery & Twitter Bootstrap)
    Here we download the necessary files and organize our content. We then setup some default include files to use later.
- Clase 6   Home Controller 
    We will now create our first controller!
- Clase 7   Home View 
    We will create our first view and we begin with the Home view which is attached to the controller.
- Clase 8   Dashboard Controller 
    Next we prepare our dashboard controller, similar to the Home controller but with an extra method.
- Clase 9   Dashboard View 
    We'll differentiate the Dashboard page with some bootstrap elements and prepare a wireframe for content further along the road.

##Sección 3: Project: Creating our first Model
- Clase 10  Creating a Database with Heidi SQL (Optional) 
    We'll create the Schema in Heidi SQL. If you are on a Mac you can use SequelPro or a similar alternative.
- Clase 11  Using The Database Class & Active Record 
    Walk through setting up the database configuration, using Active Record to make queries while referencing the Docs.
- Clase 12  Create a User Model 
    We'll go through the stages of creating a User model that we'll use later.
- Clase 13  Using the Profiler to Debug 
    This is a helpful little tool you will want to know about in the future!

##Sección 4: Project: Logging a User In
- Clase 14  Session Class 
    Learn the difference between PHP $_SESSION and Code Igniters Sessions. This is optional, but I suggest using it unless you must pass large amounts of data through a session. 
- Clase 15  Post Class & jQuery AJAX 
    We are going to make the login work with a series of things: The Input Class (Optional), The Session Class, Adjusting the User Model, and adding a fake database user.
- Clase 16  Encryption vs Hashing 
    Know the difference between Encryption and Hashing. We'll use what we've learned for securing our user passwords. 

##Sección 5: Project: Registering Users
- Clase 17  Setup Registration Area 
    Create the view and controller logic for registering a user! We almost finish it in one swoop, but we will in the Extending video!
- Clase 18  Using & Extending the Form Validator 
    You'll learn how to extend a CI Core Library and make use of it instantly! We'll be using it for getting an array of errors to use with our JSON output.
- Clase 19  Security Notes 
    Security is important, here are some things to remember.

##Sección 6: Project: Refactoring to an API and Getting JavaScript Buck-Wild
- Clase 20  Create an API Controller & Prepare For New Methods! 
    Here we build an API controller with reasons related to an AJAX application. We then do a little code refactoring and lines of demarcation! Please also download the dashboard_view.php below.
- Clase 21  Creating a Solid Javascript Structure 
    We create a solid JavaScript hierarchy for our Dashboard. We do separated code logic in JavaScript so it would be easy to add future components if you wish.

##Sección 7: Advancing our Javascript Structure
- Clase 22  Javascript Create Ability 
    We build the API controller to make an AJAX call to create a record.
- Clase 23  Improving our JS Result 
    We give our JavaScript Result class more usability.
- Clase 24  Loading From Database 
    We make our database list out our todo items. We also make sure creating a todo immediately adds it to the DOM, so there is a little refactoring happening as well.
- Clase 25  JavaScript Delete Ability & Debugging 
    We add the delete ability whilst debugging some of our code.
- Clase 26  JavaScript Update Note Completion and Undo 
    We implement edit on existing notes and cancelling them.

##Sección 8: Creating a Reusable CRUD model
- Clase 27  Adding GET ability 
    We are going to Abstract the Active-Record and build out a re-usable CRUD model and begin with the GET ability. This will make queries and models a lot more convenient.
- Clase 28  Adding INSERT and DELETE Ability 
    Add the INSERT ability to the CRUD model in a very simple manner.
- Clase 29  Adding UPDATE Ability 
    The CRUD model needs an UPDATE ability, this is the hardest part.
- Clase 30  Refactoring our API Code with the CRUD Model 
    We'll clean up our Code and you can download the final results.

##Sección 9: Creating Notes
- Clase 31  PHP and JS to List and Create! 
    Following our pattern with the TODO items, we'll now do it with NOTE's. We'll use the same API controller and set everything up to list our notes out.
- Clase 32  Preparing the Note Update: PHP and JS Templating/Event 
    We want a form to edit existing notes, so we modify quite a bit of JavaScript to and build a template for this.
- Clase 33  Saving the Note Updates: PT 1 
    This is a very difficult portion of the JavaScript. It's split into two parts. If you have a lot of trouble following along, you can download the Additional Content right after "Note Updates PT 2" which contains the whole project file if you'd like to check your code.
- Clase 34  Saving the Note Updates: PT 2 
    Here we wrap up the saving of notes. The two update parts were difficult so I've included a ZIP file if you cannot get yours working.
- Clase 35  Deleting Notes 
    We'll easily add the ability to DELETE notes via ajax.
- Clase 36  Making the Create Forms Display Dynamically 
    When we insert our records we never want to refresh the page, so we add this in. We also toss in an AJAX loader so it looks busy.
- Clase 37  Code Cleanup & Current Project Files 
    Here we clean up some of our DOM code and tidy it all up. You can download the entire project progress in the following ZIP file.

##Sección 10: Appearance: Twitter Bootstrap
- Clase 38  Bootstrapping the Login/Register Forms 
    Learn what Scaffolding is, it's quite simple. We'll decorate our forms to look a lot nicer.
- Clase 39  Bootstrapping the Todo: PT 1 
    This entire time the TODO has look ugly, so we'll be using some custom CSS to make it look nice.
- Clase 40  Bootstrapping the Todo: PT 2 (Revised) 
    We are now ready to finish off the TODO styling so people might actually use it! (Revised): I had to manually add the audio at 10 minutes as my mic gave out.
- Clase 41  Bootstrapping the Notes 
    We style the Notes area and start to polish off the project. 
- Clase 42  Fixing Display Bugs 
    What's software without bugs? They are bound to happen. I address a few display issues and we'll fix them up!
- Clase 43  Closing Remarks 
    Closing remarks regarding this project and a few tidbits that may be handy!

##Sección 11: Misc
- Clase 44  Using Languages or Internationalization (i18n) 
    This is a very basic run through of how to take advantage of i18n

