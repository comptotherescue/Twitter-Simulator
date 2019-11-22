
import Ecto.Query
defmodule Twitter.Engine do
    use GenServer
    def start_link() do
        GenServer.start_link(__MODULE__,"")
    end
    def init(state)do 
        Process.register(self(), :E2)
        {:ok, state}
    end

    def handle_call({:register, handleName, first_name, last_name, age, email, pass}, _from, state) do
        query = from u in "user_profile", where: u.userID == ^handleName, select: u.status
        lst = Twitter.Repo.all(query)
        if lst == [] do
            user = %Twitter.HandleUsers{userID: handleName, first_name: first_name, last_name: last_name,
                     age: age, email: email, password: pass, status: true}
            Twitter.Repo.insert(user)
            {:reply, "Inserted!", state}
        else
            {:reply, "Failed to insert!", state}
        end
    end

    def handle_call({:delete, handleName}, _from, state) do
        {num, _} = from(x in "user_profile", where: x.userID == ^handleName) |> Twitter.Repo.delete_all
        IO.inspect num
        if num !=0 do
            {:reply, "Deleted!", state}
        else
            {:reply, "Record not present!", state}
        end
    end

    def handle_cast({:subscribe, handleName, tofollow}, state)do
        subscriber = %Twitter.Subscribers{userID: tofollow, follower: handleName}
        Twitter.Repo.insert(subscriber)
        {:noreply, state}
    end

    def handle_cast({:tweet, handleName, tweet}, state)do
        query = from(u in "subscribers", where: u.userID == ^handleName, select: u.follower)
        lst = Twitter.Repo.all(query)
        Enum.each(lst, fn x -> 
            query2 = from u in "user_profile", where: u.userID == ^handleName, select: u.status
            [lst] = Twitter.Repo.all(query2)
            if lst == true do
                record = "%Twitter.User{userID: #{x}, tweets: #{tweet}, read: 1}"
                Twitter.Repo.all(record)
                GenServer.cast(Process.whereis(String.to_atom(x)),{:tweetrec, handleName})
            else
                record = "%Twitter.User{userID: #{x}, tweets: #{tweet}, read: 0}"
                Twitter.Repo.all(record)
            end
        end)
    end

    
end