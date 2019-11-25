
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
        IO.puts handleName
        mentionLst = parseTweet(tweet, handleName)
        query = from(u in "subscribers", where: u.userID == ^handleName, select: u.follower)
        lst =  Twitter.Repo.all(query)
        tweetfun(lst, tweet, handleName)
        tweet = "Mentioned by: " <> handleName <> " Tweet: " <> tweet
        tweetfun(mentionLst, tweet, handleName) 
        {:noreply, state}
    end

    def handle_cast({:retweet, handleName, tweet}, state)do
        query = from(u in "subscribers", where: u.userID == ^handleName, select: u.follower)
        lst = Twitter.Repo.all(query)
        tweetfun(lst, tweet, handleName)
        {:noreply, state}
    end

    def tweetfun(lst, tweet, handleName)do
        Enum.each(lst, fn x -> 
            query2 = from u in "user_profile", where: u.userID == ^x, select: u.status
            [lst] = Twitter.Repo.all(query2)
            if lst == true do
                record = %Twitter.User{userID: x, tweets: tweet, read: 1}
                Twitter.Repo.insert(record)
                GenServer.cast(Process.whereis(String.to_atom(x)),{:tweetrec, tweet, handleName})
            else
                record = %Twitter.User{userID: x, tweets: tweet, read: 0}
                Twitter.Repo.insert(record)
            end
        end)
    end

    def parseTweet(tweetStr, handleName) do
        wordLst = String.split(tweetStr, " ")
        mentionLst = Enum.reduce(wordLst,[],fn(x, acc)-> 
            if String.at(x, 0) == "#" do
                tag = %Twitter.HashTags{tags: x, tweet: tweetStr, handle: handleName}
                Twitter.Repo.insert(tag)
            end
            if String.at(x, 0) == "@"do
                 acc ++ [x]
            else
                acc
            end
            
        end)
        mentionLst
    end
end