defmodule Twitter.Subscribers do
    use Ecto.Schema
    
    @primary_key {:userID, :string, autogenerate: false}
    schema "subscribers" do
        field :follower, :string
      end
  end