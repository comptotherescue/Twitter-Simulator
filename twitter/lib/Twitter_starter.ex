defmodule Twitter.Starter do
    use Supervisor
    def start(numNode, numRequest) do
        IO.puts "Simulation started...."
        coverge_progress = Task.async(fn -> converge_progress(numNode*numRequest) end)
        Process.register(coverge_progress.pid, :supervisor)
        engineStarter()
        clientStarter(numNode, numRequest)
        Task.await(coverge_progress, 1000000)
        :timer.sleep(3000)
      end

    def converge_progress(count)do
        if count > 0 do
          receive do
              {:Converged} -> 
              IO.puts "#{count-1} To finish"
              converge_progress(count-1)
          end
      end
    end
    def engineStarter do
      {:ok, _pid} = Twitter.Engine.start_link()
    end

    def startRegistration(numNode)do
      clientLst = []
      clientLst = Enum.map(1..numNode, fn x->
      {:ok, _pid} = Twitter.Client.start_link()
      handleName = "@User" <> inspect(_pid)
      Process.register(_pid, String.to_atom(handleName))
      handleName
      end)
    
      Enum.each(clientLst, fn x->
        GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
            end)
    end

    def subscriber(numNode)do
      clientLst = []
    clientLst = Enum.map(1..numNode, fn x->
    {:ok, _pid} = Twitter.Client.start_link()
    handleName = "@User" <> inspect(_pid)
    Process.register(_pid, String.to_atom(handleName))
    handleName
    end)
  
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
          end)
          
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(List.delete(clientLst, List.first(clientLst)), 2, [])})
      end)
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom(List.first(clientLst))), {:delete, clientLst})
    end

    def clientStarter(numNode, numRequest)do
    clientLst = []
    clientLst = Enum.map(1..numNode, fn x->
    {:ok, _pid} = Twitter.Client.start_link()
    handleName = "@User" <> inspect(_pid)
    Process.register(_pid, String.to_atom(handleName))
    handleName
    end)
  
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
          end)
    
    sub = Enum.random(clientLst)
    GenServer.cast(Process.whereis(String.to_atom(sub)), {:changestatus, sub, false})
    :timer.sleep(2000)
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(List.delete(clientLst, List.first(clientLst)), 2, [])})
      end)
    Enum.each(clientLst, fn x->
      Enum.each(1..numRequest, fn y ->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:tweet, "Tweets", x})
          end)
        end)
    GenServer.cast(Process.whereis(String.to_atom(sub)), {:changestatus, sub, true})
    :timer.sleep(1000)
    GenServer.cast(Process.whereis(String.to_atom(sub)), {:getMessages, sub})
        end  

    def getUniqueLst(clientLst, num, lst)do
      if num != 0 do
        sub = Enum.random(clientLst)
        lst = lst ++ getUniqueLst(List.delete(clientLst, sub), num-1, lst) ++ [sub]
      else
        []
      end
    end
end
