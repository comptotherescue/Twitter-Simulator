import Ecto.Changeset
defmodule Twitter.Client do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__,[])
    end

    def init(state)do 
        {:ok, state}
    end

    def handle_cast({:register, handleName}, state)do
        GenServer.call(:E2 ,{:register, handleName, handleName, "UFL", 25, "abc@ufl.edu", "abc"})
        #GenServer.call(:E2, {:delete, handleName})
        #GenServer.cast(:E2, {:subscribe, "@User#PID<0.149.0>" , "@User#PID<0.148.0>"})
        #GenServer.cast(:E2, {:tweet, handleName, tweet})
        {:noreply, state}
    end

    def handle_cast({:delete, handleLst}, state)do
        Enum.each(handleLst, fn handleName -> 
        GenServer.call(:E2, {:delete, handleName})
        end)
    end

    def handle_cast({:tweet, tweet, handleName}, state)do
        GenServer.cast(:E2, {:tweet, tweet, handleName})
        {:noreply, state}
    end

    def handle_cast({:tweetrec, tweet, handleName}, state)do
         IO.puts tweet
         IO.inspect self()
        state = state ++ [tweet]
        {:noreply, state}
    end

    def handle_cast({:subscribe, handleName, subLst}, state)do
        Enum.each(subLst, fn x ->
            GenServer.cast(:E2, {:subscribe, x, handleName})
        end)
        {:noreply, state}
    end

    def handle_cast({:retweet, handleName}, state)do
        tweet = List.first(state)
        IO.puts tweet
        if tweet != nil do
            tweet = "Retweet: " <> tweet
            GenServer.cast(:E2, {:retweet, handleName, tweet})
        end
        {:noreply, state}
    end

    def handle_cast({:changestatus, handleName}, state)do
        
    end
end