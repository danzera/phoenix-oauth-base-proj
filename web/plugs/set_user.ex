defmodule Discuss.Plugs.SetUser do
	import Plug.Conn # helper functions for working with the conn object, specifically the assign() function below
	import Phoenix.Controller # to help working with sessions, specifically the get_session() function below

	alias Discuss.Repo
	alias Discuss.User

	# MODULE PLUG - must have 2 functions defined
	# 1. init: called once when the application boots up
	# 2. call: called every time that the plug runs, must receive and return a conn

	def init(_params) do
		# this plugs purpose is strictly to look at the conn object and work with user information
		# ==> there's no initial setup we really need to do
		# example init function use case: pulling data from database and then doing expensive computation
		# ==> would only be run once and then automatically injected as second arg to call function on subsequent requests
	end

	# fetch user info from database, if any	
	# transform conn object to set user model on the object so other controllers/functions have access to the user's information
	# _params is NOT the same _params as the second argument in our controllers (form data, router info, etc.)
	# in a module plug, _params is the return value from the init(_params) function
	def call(conn, _params) do
		# pull user id from session via a very functional programming approach
		# define a function to do the work for us, pass the conn and the data we want to a function and get some response back
		# NOT referencing conn.session.user_id (non-functional programming approach)
		user_id = get_session(conn, :user_id)
		# cond statement - list of expressions (conditions) where the FIRST that evaluates to true is executed
		cond do
			# exploit the way Elixir handles boolean logic
			# if there is a user_id the result of the SECOND condition in the boolean expression is returned
			# ==> user data from the database is assigned to "user" variable
			user = user_id && Repo.get(User, user_id) ->
				# "assign" (singular) function adds key :user with the specified data "user" to the "assigns" (plurarl) property of the conn object
				assign(conn, :user, user) # conn.assigns.user => user struct, so any plug that executes AFTER this set_user plug will have access to the user data within the conn object
			# no user_id
			true ->
				assign(conn, :user, nil) # assign user property to nil
		end
		# an updated conn object is returned from the "assign" function
		# since both conditions above run the assign function there is an implicit return of the conn object
		# ==> no need to explicitly return the conn object
	end
end