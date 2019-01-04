# README

This is how to set up Login Application with Bcrypt

Step 1: Add "gem 'bcrypt'" to Gemfile. Then create the database by running 'rails db:create'. Once done, create a home controller to set a root homepage via routes.rb.

Step 2: Create a User model and migration file via running the code "rails g model User email:string password_digest:string". Migrate it. Now create Users controller with the action "new". When everything is done, use rails console to tests it with "User.new" and "user = User.new(email: "John@gmail.com" , password: "123")". If the password returns encrypted, move on to step 3. If not, try and figure out the problem and traceback the steps.