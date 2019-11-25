defmodule Twitter.HashTags do
    use Ecto.Schema
    @primary_key {:tags, :string, autogenerate: false}
    schema "hashtags" do
        field :tweet, :string
        field :handle, :string
      end
  end