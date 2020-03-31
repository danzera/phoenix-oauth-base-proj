defmodule Discuss.AuthController do
	use Discuss.Web, :controller
	alias Discuss.User # allow us to refer to User struct/model directly
	plug Ueberauth

	# ueberauth expects us to define a function called "callback"
	def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
		user_params = %{
			email: auth.info.email,
			provider: to_string(auth.provider), # auth.provider returns an atom, must be coerced to a string to be inserted into the database
			token: auth.credentials.token
		}

		# make a changeset and pass it to our private function so we can insert/update a database record and store applicable user information in a session
		# this logic isn't directly tied to the callback, so we put it in separate functions
		changeset = User.changeset(%User{}, user_params) # %User{} == %Discuss.User{} struct/model thanks to the alias statement above
		login(conn, changeset)
	end

	# stash user information on a session
	# if there is a user_id on the session, we will assume the user is logged in
	defp login(conn, changeset) do
		case insert_or_update_user(changeset) do
			{:ok, user} -> # user logged in successfully
				conn
				|> put_flash(:info, "Login successful!")
				|> put_session(:user_id, user.id) # update session/cookies to reflect successful login, session information is encrypted so user cannot tamper with the info
				|> redirect(to: topic_path(conn, :index))
			{:error, _reason} -> # handle unpredictable situation if login fails for some reason
				conn
				|> put_flash(:error, "Error logging in") # conn is automatically piped in as the first argument
				|> redirect(to: topic_path(conn, :index)) # send user to list of all topics if there is an error signing in
		end
	end

	# "defp" specifies a private function as opposed "def" which specifies public functions
	# denoting this function as private will restrict it from being called by any other modules
	# we do this b/c it is a stand-alone helper function, only useful to our auth controller
	defp insert_or_update_user(changeset) do
		# verify if user already exists in our database
		case Repo.get_by(User, email: changeset.changes.email) do
			# Repo.get_by will return nil if no entry exists in the database for the given email address
			nil ->
				Repo.insert(changeset) # add record to the database
			user -> # user is found
				# Repo.insert returns a tuple of the form {:ok, user} on a successful insert, or {:error, }
				# returning a tuple of the same type if the user already exists in the database (without needing to insert a record)
				# this guarantees that this insert_or_update_user function will have the same return type regardless of which case is hit
				{:ok, user}
		end
	end

	def logout(conn, _params) do
		# could use put_session(:user_id, nil)...
		# better to use configure_session(drop: true)
		# this future-proofs our app in case additional info is added to the session at some point
		# this is better from a security standpoint
		conn
		|> configure_session(drop: true)
		|> redirect(to: topic_path(conn, :index)) # send user to list of all topics if there is an error signing in
	end
end