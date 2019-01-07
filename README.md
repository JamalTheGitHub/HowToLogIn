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

Step 3: Add "resources :users" in the <strong>routes.rb</strong>. Now going back to <strong>Users controller</strong>, inside the <strong>"new" action</strong> add <strong>"@user = User.new"</strong>. The "@user" will corresponds later when we create the form. Now, create the sign up webpage using the <strong>views/users/new</strong>. In the "new" erb, add ;


    <% form_for(@user) do |f| %>
    <%= f.label :email %>
    <%= f.text_field :email %>

    <%= f.label :password %>
    <%= f.password_field :password %>

    <%= f.label :password_confirmation %>
    <%= f.password_field :password_confirmation %>
    <% f.submit "Create Account" %>


In order to go to the sign up page, just add <strong>/users/new</strong> to the <strong>localhost:3000</strong> in the browser."<strong>form_for(@user)</strong>" refers to <strong>User.new</strong> as assigned with </strong>@user</strong> in the <strong>Users controller</strong>. Therefore, by submitting the form, it is telling rails that "Hey create this new user!". However this will not save the data to the database as the action <strong>create action</strong> was not even defined nor created in the <strong>Users controller</strong>. Now, update the <strong>Users controller</strong> so it might look something like;


    class UsersController < AplicationController

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

      def show
        @user = User.find(params[:id])
      end


      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end

Inside <strong>create action</strong>, notice the <strong>@user = User.new(user_params)</strong> when previously it the <strong>new action</strong> it was just <strong>@user = User.new</strong>. Basically, <strong>user_params</strong> is a function called within the <strong>private</strong> section and is defined as "<strong>params.require(:user).permit(:email, :password, :password_confirmation)</strong>"

Step 4: Create a sessions controller. Inside the controller, add the 'new' , 'create' and 'destroy' action. After that, in the routes.rb, add the following code;


  get 'login', to: 'sessions#cnew'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'


By adding this to routes.rb, rails now recognize the restful routes and will work properly. Since there is an action 'new' in sessions controller, create a file called "new.html.erb" in the folder "app/views/sessions/". That "new" file is your login page but it is empty now since nothing was added to it. To create a login page, do the following;


<%= form_for(:session, url: login_path) do |f| %>
<%= f.label :email %>
<%= f.email_field :email %>

<%= f.label :password %>
<%= f.password_field :password %>

<%= f.submit "Log In" %>
<% end %>


Notice that "form_for" used there is for ":session" and not "@user" because it is creating a session for that particular user and to use the "login_path". By default, any prefix will be a "post" verb in "rails routes" IF the post verb is included in the prefix. To change the verb, it has to be explicitly stated in the html itself. This particular method will not be covered here. Now that this is done and over with, go back to sessions controller and modify the "create" action to include the code, "render 'new'". Try out in the browser. When any user tries to log in, nothing will happen but the page just refereshes because render 'new' means to render the 'new' file within our app/views/sessions/ as well as defined in sessions controller although that the action is empty.

Now going back to sessions controller, the "crate" action need to know that there will be an email input and that email will go with the password that it was registered with. To do this, modify the "create" action;


def create
  user = User.find_by(email: params[:session][:email].downcase)
  if user && user.authenticate(params[:session][:password])

  else
    render 'new'
  end
end


"params[:session][:email]" is telling rails that there will be an email coming to log in but rails will not know where that email is coming from THUS "User.find_by" is used to tell rails to look for something from the database. Also, "session" can be treated like a hash, {}. Basically, when a user signed up, their email and password are stored into the database. "User.find_by" helps to look for a column in the database and "user = User.find_by(email: params[:session][:email].downcase) is telling rails that an email is coming from the database. If the email matched the one from the database, then rails will proceed. ".downcase" is just a function that downcases something. For example if the email is QWER@zzz.com, it will be qwer@zzz.com.

"if user && user.authenticate(params[:session][:password])" means that if the user has submitted the email and the password that matches the email, therefore the user will proceed with logging in. However, if at least one of them is mismatched, the log in will not proceed. However, once all of this is done, the user is still not able to login because the session is not defined. Sure the user can enter the email and the respective password but this will not create the session for the user.

Step 5: To create a session for the user, a login method should be defined as well the "user.id". In order to do this, go to application_controller.rb in the controller folder and add the code "include SessionsHelper". The reason for this is to also inherit from rails "helpers" so the function can be called throughout the files within the controller folder.

Now, within the "helpers" folder, open a file called "sessions_helper.rb". In that file, add 4 methods, log_in(user), current_user, logged_in? and log_out. It will look something like as below;


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


Initially, log_in needs to be defined so that rails will know that "Oh this particular email and password matches therefore I must create a session for the user!". With that being said add the following code to "log_in" method,
"session[:user_id] = user.id". What this does is that it creates a temporary cookie using the rails session method which is automatically encrypted.

Next, current_user method needs to be defined so that it will be easier to call it in the view files or controllers. For the method, add the codes below;


if session[:user_id]
  @current_user ||= User.find_by(id: session[:user_id])
end


Test it in rails console;

1)Assign session to a hash. Then run the code; session[:user_id] and see output.

2)Next run the code; @current_user ||= User.find_by(:id session[:user_id]) and see output.

3)Now assign a user using User.first, if theres no user, create one.

4)Assign that user to session[:user_id]

5)Repeat step 2 and see outcome. Understand what happened.

6)Exit rails console.


Now that it has been tested in rails console and it works, understand that @current_user is nil because it is undefined global instance. "||=" means "OR EQUALS TO". It is quite hectic to explain the type of expressions available in rails but for further understanding, an independent research will help significantly.

Next is to indentify if the user is logged in or not. This function can also be used in views to enable certain functions to users who are already logged in. With that, just add "!current_user?" to the "logged_in?" method within the helper. What this means is that if current_user is not nil, then do ..... . It just simply means that. The exclamation(!) at the beginning means NOT.

To log out, simply delete the session that was created by the user and make sure that the @current_user is nil. Just add the code, "session.delete(:user_id)" and "@current_user = nil". All in all if done correctly, it will look like the following;


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


Step 6: Now that the helper is done, connect it with the sessions controller by updating the controller to look like as follows;


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


What is left now is to create links from the root page to sign up and login. Once logged in, create a log out link and those links must corresponds to the restful routes created with their own prefixs and verbs.

That is it, this is a basic login/logout with bcrypt gem.