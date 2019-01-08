# README

<strong>This is how to set up Login Application with Bcrypt</strong>

Step 1: Add <strong>"gem 'bcrypt'"</strong> to <strong>Gemfile</strong>. Then create the database by running <strong>'rails db:create'</strong> in the terminal. Once done, create a <strong>Home controller</strong> via terminal and set the root page to index in <strong>routes.rb</strong>.

    rails db:create

===================================

    rails g controller Home index

===================================

    root 'home#index'

Step 2: Create a <strong>User model</strong> and migration file via the terminal by running the code; 

    rails g model User email:string password_digest:string 

Once done, migrate it. After that create the <strong>Users controller</strong> with the action 'new'.

    rails g controller Users new

Before proceeding forward, go into the <strong>User model</strong> that was created and add this code to use the bcrypt functionality.

    has_secure_password

Basically the <strong>User model</strong> will look like this.

    class User < ApplicationRecord
      has_secure_password
    end

Once that settled, open <strong>rails console</strong> and test it by playing around with <strong>"User.new"</strong> and assigning a user with an email and password. The password should be encrypted because of the function <strong>has_secure_password</strong> in the <strong>User model</strong>.

To test if the root page has be successfully implemented in the <strong>routes.rb</strong>, fire up the rails server by executing this code in the terminal

    rails s

Now go to the browser and enter the url <strong>localhost:3000</strong>. This will bring up the root page.

Step 3: Add "resources :users" in the <strong>routes.rb</strong>. After that, in the terminal, enter <strong>rails routes</strong> to see restful routes and understand how they work. Now going back to <strong>Users controller</strong>, inside the <strong>"new" action</strong> add <strong>"@user = User.new"</strong>. The "@user" will corresponds later when we create the form. Now, create the sign up webpage using the <strong>views/users/new</strong>. In the "new" erb, add ;

    <h1>SIGN UP</h1>
    
    <% form_for(@user) do |f| %>
    <%= f.label :email %>
    <%= f.text_field :email %>

    <%= f.label :password %>
    <%= f.password_field :password %>

    <%= f.label :password_confirmation %>
    <%= f.password_field :password_confirmation %>
    <%= f.submit "Create Account" %>
    <% end %>


NOTE: <strong>password_confirmation</strong> is just a way of making sure that the password typed in this box matches the password typed in the first box. Its fairly common in websites that requires the user to retype their password for confirmation. This will not affect the <strong>database</strong>. 


In order to go to the sign up page, just add <strong>/users/new</strong> to the <strong>localhost:3000</strong> in the browser."<strong>form_for(@user)</strong>" refers to <strong>User.new</strong> as assigned with </strong>@user</strong> in the <strong>Users controller</strong>. Therefore, by submitting the form, it is telling rails that "Hey create this new user!". However this will not save the data to the database as the action <strong>create action</strong> was not even defined nor created in the <strong>Users controller</strong>. Now, update the <strong>Users controller</strong> so it might look something like;


    class UsersController < AplicationController

      def show
        @user = User.find(params[:id])
      end

      def new
        @user = User.new
      end

      def create
        @user = User.new(user_params)
        if @user.save
          redirect_to @user
        else
          render 'new'
        end
      end


      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end

Inside <strong>create action</strong>, notice the <strong>@user = User.new(user_params)</strong> when previously in the <strong>new action</strong> it was just <strong>@user = User.new</strong>. Basically, <strong>user_params</strong> is a function called within the <strong>private</strong> section and is defined as "<strong>params.require(:user).permit(:email, :password, :password_confirmation)</strong>". This is like telling rails "Alright permit all these attributes like email,password and password_confirmation if it was to be saved."

<strong>@user.save</strong> basically is what happens when the user clicked on <strong>f.submit "Create Account"</strong> in the <strong>apps/views/users/new</strong>. <strong>@user.save</strong> saves the informations typed by the user into the database with the permissions from <strong>user_params</strong>. Once the user clicked on "Create Account" they will be redirect to <strong>@user</strong> which was already defined in the <strong>show action</strong> as <strong>@user = User.find(params[:id])</strong>. This means that once the user created his account, an <strong>id</strong> will automatically be attached to it and it will be redirected to the users show(profile) page. Rails is smart enough to know this. However, if the information entered by the user is false or incomplete, the sign up page will just be rendered fresh again hence the code <strong>render 'new'</strong>. Before proceeding to the next step, add a new file called <strong>show.html.erb</strong> in the folder <strong>apps/views/users/</strong> to see what will happen if a user sign up. Upon signing up, the user will see something like <strong>localhost:3000/users/1</strong> where the integer 1 refers to the <strong>id</strong> of the user.


Step 4: Now, in order for the user to log in with their credentials, a session must be created for them. With this, create the <strong>Sessions controller</strong> with the action of <strong>new, create, destroy</strong>. Once done, go to the <strong>routes.rb</strong> and add the following;


    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'


To understand further what <strong>get,post,delete</strong> means, self-research is necessary. Once this is done, create a file called <strong>new.html.erb</strong> in <strong>apps/views/sessions/</strong> IF it is not created when creating the <strong>Sessions controller</strong>. In this <strong>new.html.erb</strong> file, put the following codes as this will be the log in page.


    <h1>Log In</h1>
    <%= form_for(:session, url: login_path) do |f| %>
    <%= f.label :email %>
    <%= f.email_field :email %>

    <%= f.label :password %>
    <%= f.password_field :password %>

    <%= f.submit "Log In" %>
    <% end %>


To access this page, simply add <strong>/login</strong> into the browser. Notice previously it was <strong>form_for(@user)</strong> and now it is <strong>form_for(:session, url: login_path)</strong>. So what is going on? Well, basically <strong>:session</strong> is a built in rails method where it can be treated like an empty hash({}). "<strong>url: login_path</strong>" is basically just telling rails, "Hey! Go to this restful route here!" which will have 2 <strong>VERBS</strong> and they are <strong>get</strong> and <strong>post</strong> as defined inside the <strong>routes.rb</strong>. Notice that in <strong>routes.rb</strong>, the "<strong>post 'login', to: 'sessions#create'</strong>" is directing to the <strong>create action</strong> within the <strong>Sessions controller</strong> and currently the action now is empty and undefined.

Lets define it by adding the codes below;


    def create
      user = User.find_by(email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])

      else
        render 'new'
      end
    end


<strong>user = User.find_by(email: params[:session][:email].downcase)</strong> is basically telling rails that "Hey! I am going to look for this <strong>email(email:)</strong> in the database and <strong>downcase(.downcase)</strong> it to put into this empty <strong>hash(:session)</strong> AND I will assign user to this <strong>email(:email)</strong>". That is basically it. To explain thoroughly is very TL;DR so in order to understand it better, once again, self-research is required. The next line <strong>user && user.authenticate(params[:session][:password])</strong> also is telling rails that "Okay, now I have assigned user to this email BUT before I can let user go, I need to know the <strong>password(:password)</strong> that goes together with this email so I can put it in a <strong>hash(:session)</strong> together with the email. If user submit wrong or incomplete form, I will just render this page again.". This is as layman as it can get.

Step 5: Before attempting to log in(you can try if you want but there will be an error I believe), create <strong>Sessions helper</strong> file inside <strong>app/helpers/</strong> called <strong>sessions_helper.rb</strong> IF the file has not been created. Again, if the curiousity peaks the roof on what helpers actually do, self-research it!

Next, open the <strong>application_controller.rb</strong> inside the <strong>app/controllers/</strong> and add the following code in order to include the <strong>Sessions helper</strong> so that it can be used throughout the whole of <strong>app/controllers/</strong>.

    include SessionsHelper

Now open the file called <strong>sessions_helper.rb</strong>. Add the following actions, <strong>log_in(user)</strong>, <strong>current_user</strong>, <strong>logged_in?</strong> and <strong>log_out</strong>. The names of these actions are pretty self-explanatory. Basically, if done correctly, it will look like below;


    module SessionsHelper
      def log_in(user)
  
      end
  
      def current_user
  
      end
  
      def logged_in?
  
      end
  
      def log_out
  
      end    
    end


The action <strong>log_in(user)</strong> need to be defined in such a way that once the email and password matches, the user will be able to proceed accordingly. With that being said add the following code to <strong>log_in(user)</strong>;


    session[:user_id] = user.id


All will be explained later. Next, add the following codes to <strong>current_user</strong>;


  if session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
  end


Basically, <strong>@current_user</strong> if it is not assigned, it will be nil BUT if assigned, it will tell rails to match the <strong>@current_user</strong> with the assigned <strong>id</strong> provided by user.id when the <strong>log_in(user)</strong> action was executed.

Now, test it in the rails console;

1)Assign session to a hash. Then run the code; session[:user_id] and see output.

2)Next run the code; @current_user ||= User.find_by(:id session[:user_id]) and see output.

3)Now assign a user using User.first, if theres no user, create one.

4)Assign that user to session[:user_id]

5)Repeat step 2 and see outcome. Understand what happened.

6)Exit rails console.


Aftter testing it in the rails console, if it is hard to understand what is going on in this part of town, self-research is always a good option as it will cover some of the things that were explained lightly or not at all.

Now onto the next action, <strong>logged_in?</strong>. Notice that this is a boolean action as it just checks for true or false due to the "?" being at the end of the action. Inside this action, add <strong>!current_user.nil?</strong> and that is it. It is just checking whether the user is logged in or not. The expression is making sure that the <strong>current_user</strong> cannot be nil because if it is nil, it means nobody is logged in.

The final part will be the <strong>log_out</strong> which is just deleting the session and assigning nil to the <strong>@current_user</strong>. Just add the codes;


    session.delete(:user_id)
    @current_user = nil


Now, the final product will look like as below;


    module SessionsHelper
      def log_in(user)
        session[:user_id] = user.id
      end

      def current_user
        if session[:user_id]
          @current_user ||= User.find_by(id: session[:user_id])
        end
      end

      def logged_in?
        !current_user.nil?
      end

      def log_out
        session.delete(:user_id)
        @current_user = nil
      end    
    end


Step 6: Now that the helper is done, connect it with the <strong>Sessions controller</strong> by updating the controller to look like as follows;


    class SessionsController < ApplicationController
      def new
      end

      def create
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
          log_in user
          redirect_to user
        else
          render 'new'
        end
      end

      def destroy
        log_out
        redirect_to root_url
      end
    end


Now the explanation of <strong>log_in(user)</strong> comes in handy. So what is going on now is that assuming that the password and email matches, what happens is that rails is assigning the <strong>id</strong> of the user with the email and the password to the hash so that everything else that is also connected to said <strong>id</strong> is accessable. That is basically it.

However small changes needed to be made so that the user will have a smooth transition of signing up, logging in and eventually log out. So let's revisit <strong>Users controller</strong> and update the <strong>create action</strong>;


    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to login_path
      else
        render 'new'
      end
    end


Now when the user has successfully sign up, he/she will be redirected to the login page. In order to know if the user is logged in or not, we can modify the <strong>app/views/users/show.html.erb</strong> to include the <strong>@current_user</strong> code. Just simply put;


    Welcome <%= @current_user.email %>


Now, when the user sign in, he/she will be greeted. On a final note, to log out, simply add the link to log out with the correct verb. In the same page as the greet when they log in, just add a few more codes;

    Welcome <%= @current_user.email %>


    <% if logged_in? %>
    <%= link_to "Log Out", logout_path, method: :delete %>
    <% end %>


And that is it with creating a sign up, sign in and log out with the <strong>bcrypt</strong> gem.