# README

This is how to set up Login Application with Bcrypt

Step 1: Add "gem 'bcrypt'" to Gemfile. Then create the database by running 'rails db:create'. Once done, create a home controller to set a root homepage via routes.rb.

Step 2: Create a User model and migration file via running the code "rails g model User email:string password_digest:string". Migrate it. Now create Users controller with the action "new". After that add "has_secure_password" to the model user.rb. When everything is done, use rails console to tests it with "User.new" and "user = User.new(email: "John@gmail.com" , password: "123")". If the password returns encrypted, move on to step 3. If not, try and figure out the problem and traceback the steps.

Step 3: Add "resources :users" in the routes.rb. Now going back to users controller, inside the "new" action add "@user = User.new". The "@user" will corresponds later when we create the form. Now, create the sign up webpage using the views/users/new. In the "new" erb, add ;


<% form_for(@user) do |f| %>
<%= f.label :email %>
<%= f.text_field :email %>

<%= f.label :password %>
<%= f.password_field :password %>

<%= f.label :password_confirmation %>
<%= f.password_field :password_confirmation %>
<% f.submit "Create Account" %>


"form_for(@user)" refers to the action of "new" in the users controller hence why this "@user = User.new" was added. However this will not save the data to the database as the action 'create' in the users controller is still nil. Update the users controller so it might look something like this;


class UsersController < AplicationController

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
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

"redirect_to @user" simply redirects the user who has created his/her account to her page via the "show" action. Rails is smart enough to know what is going on. In the Url browser it will look something like "localhost:3000/users/1" where the number "1" represents the id of the user that was just created IF you try to sign up AGAIN after doing all the necessary procedures. Now users can create an account to the web app but could not log in because we have not implement the login action yet.

Step 4: Create a sessions controller. Inside the controller, add the 'new' , 'create' and 'destroy' action. After that, in the routes.rb, add the following code;


  get 'login', to: 'sessions#cnew'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'


By adding this to routes.rb, rails now recognize the restful routes and will work properly. Since there is an action 'new' in sessions controller, create a file called "new.html.erb" in the folder "app/views/sessions/". That "new" file is your login page but it is empty now since nothing was added to it. To create a login page, do the following;


<%= form_for(:sessions, url: login_path) do |f| %>
<%= f.label :email %>
<%= f.email_field :email %>

<%= f.label :password %>
<%= f.password_field :password %>

<%= f.submit "Log In" %>
<% end %>


Notice that "form_for" used there is for ":sessions" and not "@user" because in the sessions controller @user is not defined and therefore need to manually tell rails what to do. In simple English, this translates to "form for sessions controller and execute the create action". By default, any prefix will be a post verb in "rails routes" IF the post verb is included in the prefix. To change the verb, it has to be explicitly stated in the html itself. This particular method will not be covered here. Now that this is done and over with, go back to sessions controller and modify the "create" action to include the code, "render 'new'". Try out in the browser. When any user tries to log in, nothing will happen but the page just refereshes because render 'new' means to render the 'new' file within our app/views/sessions/ as well as defined in sessions controller although that the action is empty.

Now going back to sessions controller, the "crate" action need to know that there will be an email input and that email will go with the password that it was registered with. To do this, modify the "create" action;


def create
  user = User.find_by(email: params[:session][:email].downcase)
  if user && user.authenticate(params[:session][:password])

  else
    render 'new'
  end
end


"params[:session][:email]" is telling rails that there will be an email coming to log in but rails will not know where that email is coming from THUS "User.find_by" is used to tell rails to look for something from the database. Basically, when a user signed up, their email and password are stored into the database. "User.find_by" helps to look for a column in the database and "user = User.find_by(email: params[:session][:email].downcase) is telling rails that an email is coming from the database. If the email matched the one from the database, then rails will proceed. ".downcase" is just a function that downcases something. For example if the email is QWER@zzz.com, it will be qwer@zzz.com.

"if user && user.authenticate(params[:session][:password])" means that if the user has submitted the email and the password that matches the email, therefore the user will proceed with logging in. However, if at least one of them is mismatched, the log in will not proceed.