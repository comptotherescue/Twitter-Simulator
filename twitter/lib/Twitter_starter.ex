defmodule Twitter.Starter do
    use Supervisor
    def start(numNode, numRequest) do
        engineStarter()
        clientStarter(numNode, numRequest)
        :timer.sleep(5000)

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

    # Enum.each(clientLst, fn x->
    #GenServer.cast(Process.whereis(String.to_atom(List.first(clientLst))), {:register, "Inqalab zindabad! #Azadi2  #RuthviseAzadi @User#PID<0.151.0>", List.first(clientLst), numRequest, clientLst})
    #GenServer.cast(Process.whereis(String.to_atom(List.first(clientLst))), {:register, "Inqalab zindabad! #Azadi2  #SonalseAzadi @User#PID<0.149.0> @User#PID<0.150.0>", List.first(clientLst), numRequest, clientLst})
    GenServer.cast(Process.whereis(String.to_atom(List.first(clientLst))), {:changestatus, String.to_atom(List.first(clientLst)) })
    # end)
    end
end
