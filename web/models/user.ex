defmodule Discuss.User do
	use Discuss.Web, :model # tell Phoenix this module is a "model"

	schema "users" do # tell Phoenix what the model looks like in our database
		field :email, :string
		field :provider, :string
		field :token, :string
		
		 # timestamps function is called the same way it is in our migration file
		 # informs our schema of the existence of timestamps in the database
		timestamps()
	end

	# how we turn a struct into something that can actually be inserted in the database (how we want to change a record)
	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:email, :provider, :token]) # cast the struct and params to create a changeset, don't need to specifiy timestamps
		|> validate_required([:email, :provider, :token]) # add validation to the changeset, require all fields in this case
	end
end