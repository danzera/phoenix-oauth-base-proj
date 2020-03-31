# controller modules use the naming convention Discuss.ResourceController (singular)
defmodule Discuss.TopicController do
	use Discuss.Web, :controller # import Phoenix controller functionality, done with all controllers
	
	# Discuss.Topic refers to "Topic" struct that Phoenix automatically generates from the "Topic" model
	# aliasing here allows us to refer to "Topic" directly (seen below) as opposed to "Discuss.Topic"
	alias Discuss.Topic

	# Show a list of all topics
	def index(conn, _params) do
		# fetch all topics from the database
		topics = Repo.all(Topic) # shortened by aliasing Repo via Discuss.Web and Discuss.Topic above, would otherwise read Discuss.Repo.all(Discuss.Topic)
		# render the index template and make the property "topics" available within the template
		render conn, "index.html", topics: topics
	end

	# conn (connection) is an Elixir struct that is the entire focal point of our Phoenix applciation
	# 	it represents the incoming request to our application AND the outgoing response
	# 	gets passed around from one function to another until the request has been fulfilled its ready to be returned to the user
	# 	contains request origin, request type, request parameters, route info (path), cookies, headers, etc.
	# 	also contains resp_body (response body) - initially nil, resp_cookies, resp_headers, etc.
	# params (parameters) any query params that were included in the URL when the route was hit
	def new(conn, _params) do
		# generate an empty (invalid) changeset that will later be merged with the form
		# inputs for our changeset function in the resource module
		# struct = %Resource{} # %Resource{} == %Discuss.Resource{} thanks to the alias statement above
		# params = %{}
		changeset = Topic.changeset(%Topic{}, %{}) # again, %Resource{} == %Discuss.Resource{} thanks to the alias statement above
		
		# Phoenix knows to look for "new.html" in the "templates > resource" directory because of the module name above, "Discuss.ResourceController"
    render conn, "new.html", changeset: changeset # any custom data can be included as additional args the way "changeset" is included here
	end
	
	# handler for POST /resource route
	# "params" will include the data from our form
	# 	%{"resource" => resource} = params
	def create(conn, %{"topic" => topic}) do
		# generate a new changeset from the resource params that were passed in from the form
		# this represents the changes that we want to make to our database
		changeset = Topic.changeset(%Topic{}, topic) # empty struct is used for the first argument because we are creating a new record
	
		# insert the record to our database via the Repo module
		# reference Repo directly b/c Ecto functionality has been imported/aliased via Discuss.Web
		# Repo.insert automatically checks to see if the changeset is valid, will not attempt to insert if valid? = FALSE
		case Repo.insert(changeset) do
			# 2 possible returns from Repo.insert
			{:ok, _topic} -> # _topic is what was actually inserted
				conn # conn is the first arg to both put_flash and redirect functions, is piped along into both
				|> put_flash(:info, "Topic created successfully!") # shows msg to user once when the page is reloaded
				|> redirect(to: topic_path(conn, :index)) # keyword list with one entry, sends user to the route using the ResourceController index function
			{:error, changeset} ->
				IO.puts("ERROR")
				IO.inspect(changeset)
				# return conn -> show the user the form again if their input was invalid
				conn
				|> put_flash(:error, "Error: Topic not created") # conn is automatically piped in as the first argument
				|> render("new.html", changeset: changeset) # conn is automatically piped in as the first argument
				
		end
	end

	# Show a form to edit an existing topic.
	# ":id" wildcard specified in router.ex file, be more specific in naming the variable here at the controller function level
	def edit(conn, %{"id" => topic_id}) do
		# get existing topic data from the database via Ecto/Repo
		topic = Repo.get(Topic, topic_id)
		# generate a changeset with the data from the existing topic - TO BE PASSED TO THE FORM
		# params arg is defaulted to an empty map in the definition of the changeset function (see Resource model)
		changeset = Topic.changeset(topic) # form helpers expect to receive a changeset to work with
		 # return the existing resource to the form to display the current data, and have the id for reference if/when the form is posted
		render conn, "edit.html", changeset: changeset, topic: topic
	end

	@doc """
	Update an existing topic.
	`params` includes the `id` and other attributes of the resource being updated
	"""
	def update(conn, %{"id" => topic_id, "topic" => updated_topic}) do
		# equivalent long-hand code to the piping done below
		existing_topic = Repo.get(Topic, topic_id) # fetch the existing resource from the database to use in the changeset
		changeset = Topic.changeset(existing_topic, updated_topic) # generate a changeset based on what's in the database and what we received from the form
		
		# the above code could be done via piping, as follows
		# HOWEVER we need a reference to the existing_resource struct to re-render the "edit.html" page in the event of an error (below)
		# changeset =
		#		Repo.get(Resource, resource_id) # existing resource in the database (existing_resource above)
		#		|> Resource.changeset(resource) # gets piped into making a Changeset to be used in updating the database

		# update existing resource with our Changeset using the Ecto.Repo module
		case Repo.update(changeset) do
			{:ok, _topic} ->
				conn
				|> put_flash(:info, "Topic updated successfully!")
				|> redirect(to: topic_path(conn, :index))
			{:error, changeset} ->
				conn
				|> put_flash(:error, "Error: Topic not created") # conn is automatically piped in as the first argument
				|> render("edit.html", changeset: changeset, topic: existing_topic) # conn is automatically piped in as the first argument, "edit.html" template expects resource to be passed in
		end
	end

	@doc """
	Delete a resource record from the database based on its `id`.
	"""
	def delete(conn, %{"id" => topic_id}) do
		# delete function expects a struct, so we fetch the record first
		Repo.get!(Topic, topic_id) |> Repo.delete! # the ! will send the user an error message automatically if an error occurs, so we don't need to use a case statement here

		# redirect the user back to the index route if the deletion is successful
		conn
		|> put_flash(:info, "Topic deleted successfully!")
		|> redirect(to: topic_path(conn, :index))
	end
end
