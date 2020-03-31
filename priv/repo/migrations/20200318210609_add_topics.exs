defmodule Discuss.Repo.Migrations.AddTopics do
  use Ecto.Migration

	# this is where database structure is described
	def change do
		
		# create a new table called "topics"
		create table(:topics) do
			# add a column called "title" with the data type string
			add :title, :string
		end

  end
end
