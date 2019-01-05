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

"redirect_to @user" simply redirects the user who has created his/her account to her page via the "show" action. Rails is smart enough to know what is going on. In the Url browser it will look something like "localhost:3000/users/1" where the number "1" represents the id of the user that was just created. Now users can create an account to the web app but could not log in because we have not implement the login action yet.

Step 4: Login