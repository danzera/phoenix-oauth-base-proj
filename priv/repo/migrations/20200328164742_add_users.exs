defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

	def change do
		# create a new table called "users"
		# our primary reason for storing user information is so we can track who adds topics/comments
		# will be used to determine edit/delete permissions
		create table(:users) do
			# add columns
			add :email, :string
			add :provider, :string # github (could change if other providers are added)
			add :token, :string # sent from the provider, would be used for followup requests to the providers
			
			# timestamps function automatically adds a inserted_at and updated_at property to each record in the table
			timestamps()
		end

  end
end
