defmodule Twitter.Starter do
    use Supervisor
    def start(numNode, numRequest) do
        engineStarter()
        clientStarter(numNode, numRequest)
        :timer.sleep(3000)

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
    
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:changestatus, x, false})
          end)

    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(List.delete(clientLst, List.first(clientLst)), 2, [])})
      end)
    IO.inspect clientLst
    Enum.each(clientLst, fn x->
      Enum.each(1..numRequest, fn y ->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:tweet, x, "Tweet Number #{y}"})
          end)
        end)

    #       :timer.sleep(1000)
    # Enum.each(Enum.take(clientLst, -2), fn x->
    #   IO.puts "retweet " <> x
    #   GenServer.cast(Process.whereis(String.to_atom(x)), {:retweet, x})
    #       end)
    #   GenServer.cast(Process.whereis(String.to_atom("@User#PID<0.147.0>")), {:hashtags, "#Maaz", "@User#PID<0.147.0>"})
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
