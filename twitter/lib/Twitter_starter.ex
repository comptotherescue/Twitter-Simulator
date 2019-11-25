defmodule Twitter.Starter do
    use Supervisor
    def start(numNode, numRequest) do
        engineStarter()
        clientStarter(numNode, numRequest)
        :timer.sleep(8000)

      end

    def engineStarter do
      {:ok, _pid} = Twitter.Engine.start_link()
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
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(List.delete(clientLst, List.first(clientLst)), 2, [])})
      end)
    IO.inspect clientLst
    Enum.each(Enum.take(clientLst, 2), fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:tweet, x, "Apun bola tu meri laila! @User#PID<0.151.0>"})
          end)
          :timer.sleep(1000)
    Enum.each(Enum.take(clientLst, -2), fn x->
      IO.puts x
      GenServer.cast(Process.whereis(String.to_atom(x)), {:retweet, x})
          end)
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
