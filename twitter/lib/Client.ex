import Ecto.Changeset
defmodule Twitter.Client do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__,[])
    end

    def init(state)do 
        {:ok, state}
    end

    def handle_cast({:register, tweet, handleName, numRequest, clientLst}, state)do
        GenServer.call(:E2 ,{:register, handleName, handleName, "UFL", 25, "abc@ufl.edu", "abc"})
        #GenServer.call(:E2, {:delete, handleName})
        #GenServer.cast(:E2, {:subscribe, "@User#PID<0.149.0>" , "@User#PID<0.148.0>"})
        #GenServer.cast(:E2, {:tweet, handleName, tweet})
        {:noreply, state}
    end

    def handle_cast({:tweetrec, tweet, handleName}, state)do
        IO.puts tweet 
        state = state ++ [tweet]
    
        userID= "@User" <> inspect(self())
        IO.inspect userID
        GenServer.cast(:E2, {:retweet, userID, tweet})
        {:noreply, state}
    end

    def handle_cast({:changestatus, handleName}, state)do
        
    end
end