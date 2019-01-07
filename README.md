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


To access this page, simply add <strong>/login</strong> into the browser. Notice previously it was <strong>form_for(@user)</strong> and now it is </strong>form_for(:session, url: login_path)</strong>. So what is going on? Well, basically <strong>:session</strong> is a built in rails method where it can be treated like an empty hash({}). "<strong>url: login_path</strong>" is basically just telling rails, "Hey! Go to this restful route here!" which will have 2 <strong>VERBS</strong> and they are <strong>get</strong> and <strong>post</strong> as defined inside the <strong>routes.rb</strong>. Notice that in <strong>routes.rb</strong>, the "<strong>post 'login', to: 'sessions#create'</strong>" is directing to the <strong>create action</strong> within the <strong>Sessions controller</strong> and currently the action now is empty and undefined.

Lets define it by adding the codes below;


    def create
      user = User.find_by(email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])

      else
        render 'new'
      end
    end


<strong>user = User.find_by(email: params[:session][:email].downcase)</strong> is basically telling rails that "Hey! I am going to look for this email in the database and downcase it to put into this empty hash(:session) AND I will assign user to this email". That is basically it. To explain thoroughly is very TL;DR so in order to understand it better, once again, self-research is required. The next line <strong>user && user.authenticate(params[:session][:password])</strong> also is telling rails that "Okay, now I have assigned user to this email BUT before I can let user go, I need to know the password that goes together with this email so I can put it in a hash together with the email. If user submit wrong or incomplete form, I will just render this page again.". That is as layman as it can get.

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