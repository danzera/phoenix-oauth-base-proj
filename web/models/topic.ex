# model modules use the naming convention Discuss.Resource (singular)
defmodule Discuss.Topic do
	# code sharing from the model function in web > web.ex
	# ** automatically generates a %Resource{} struct from this module for us **
	use Discuss.Web, :model

	# describe "resources" table schema for Phoenix, i.e. there should be a matching table name in the database
	schema "topics" do
		# in this example, the topics table has one field called "title" of data type string
		field :title, :string
	end

	# produce a changeset to record new/updated data in the database
	# struct is the existing database record (if any)
	# params is the updated (or new) record
	# generally these will both have the same properties
	# \\ %{} specifies the default argument for 'params' if nothing is passed in (or the function is called with only one arg)
	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:title]) # describe how to get from the struct to the params (what's changing in the DB)
		|> validate_required([:title]) # perform data validation on the specified properties - what's required to have a value
	end
end