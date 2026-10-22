-- ORVEX HUB | FARM, ESP REESTRUTURADO & DASHBOARD DE ELEIÇÕES (RAYFIELD GEN2)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local jogador = Players.LocalPlayer
local pastaNPC = Workspace:WaitForChild("PopulacaoNPC")
local pastaEntradas = Workspace:WaitForChild("EntradasSaidas")

-- Remotes mapeados do servidor
local remoteAbrirInteracao = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("InteracaoPlayer"):WaitForChild("Abrir")
local remotePedirApoio = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ApoioPolitico"):WaitForChild("Pedir")
local remoteWindBanner = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Campanha"):WaitForChild("ColocarWindBanner")
local remoteDebateEstudo = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("DebateEstudo"):WaitForChild("Estudar")
local remoteComicioAcao = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Comicio"):WaitForChild("Acao")

-- Estados de Controle das Ferramentas (Toggles)
local farmManualAtivo = false
local farmPlayersAtivo = false
local farmWindBannerAtivo = false
local farmEstudoAtivo = false
local farmComicioAtivo = false

local espNPCAtivo = false
local espCargoAtivo = false
local espCandidatosAtivo = false
local espEstudosAtivo = false
local espPorcentagemAtivo = false

local ultimoUso = {}
local COOLDOWN_LOCAL = 5
local politicoSelecionado = ""

-- 1. Inicializa a biblioteca nativa Rayfield Gen2 fornecida
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- 2. Janela Principal do Hub
local Window = Rayfield:CreateWindow({
    Name = "ORVEX HUB | MANAGER",
    Subtitle = "Sistemas Avançados v4",
    Theme = "Default",
    Icon = "rbxassetid://80387863064905",
    ShowName = "Orvex",
    Configuration = {
        AutoSave = true,
        AutoLoad = false,
        FileName = "OrvexFarmConfig"
    }
})

-- Abas Principais do Menu Lateral
local TabFarm = Window:CreateTab({ Name = "Farm", Icon = "rbxassetid://100604009889706" })
local TabTP = Window:CreateTab({ Name = "Teleporte", Icon = "rbxassetid://125823673784681" })
local TabESP = Window:CreateTab({ Name = "Esp", Icon = "rbxassetid://91452555903853" })
local TabTroll = Window:CreateTab({ Name = "Forjar/Troll", Icon = "rbxassetid://10651147057" })
local TabDashboard = Window:CreateTab({ Name = "Hub Candidatos", Icon = "rbxassetid://111263549366178" })

-- Função auxiliar para capturar atributos/valores de cargos de forma flexível
local function obterInformacaoPlayer(p, nomeChave)
    if not p then return nil end
    local char = p.Character
    local attr = p:GetAttribute(nomeChave) or (char and char:GetAttribute(nomeChave))
    if attr then return attr end
    local var = p:FindFirstChild(nomeChave, true) or (char and char:FindFirstChild(nomeChave, true))
    if var and (var:IsA("ValueObject") or var:IsA("StringValue") or var:IsA("NumberValue")) then return var.Value end
    return nil
end

-- Filtro de Políticos Válidos (Ignora NaoEleito, Cidadao e Candidato)
local function verificarSeEhPoliticoValido(p)
    if p == jogador then return false end
    local cargo = obterInformacaoPlayer(p, "Cargo")
    if cargo and cargo ~= "" and cargo ~= "Cidadao" and cargo ~= "NaoEleito" and cargo ~= "Candidato" then
        return true, tostring(cargo)
    end
    return false
end

-- Gera a lista formatada "Cargo | Nick" para o Dropdown de Troll
local function obterListaPoliticos()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local ehPolitico, nomeCargo = verificarSeEhPoliticoValido(p)
        if ehPolitico then
            table.insert(lista, nomeCargo .. " | " .. p.Name)
        end
    end
    if #lista == 0 then table.insert(lista, "Nenhum político online") end
    return lista
end

----------------------------------------------------
-- CATEGORIA: FARM (NPCs, Players, Banners, Estudo e Comício)
----------------------------------------------------
TabFarm:CreateSection({ Name = "Automação Manual por Aproximação" })
TabFarm:CreateToggle({
    Name = "Farm Apoio Andando (NPCs)",
    Description = "Aproxime-se dos NPCs caminhando normalmente para validar os apoios automaticamente.",
    Value = false,
    Callback = function(valor) farmManualAtivo = valor end
})

TabFarm:CreateSection({ Name = "Automação de Apoio via Players" })
TabFarm:CreateToggle({
    Name = "Farm Apoio + Teleporte (Players)",
    Description = "Teleporta até cada jogador do mapa para validar fisicamente a abertura e o pedido de apoio.",
    Value = false,
    Callback = function(valor) farmPlayersAtivo = valor end
})

TabFarm:CreateSection({ Name = "Automação de Objetos de Campanha" })
TabFarm:CreateToggle({
    Name = "Colocar Windbanner (Todos)",
    Description = "Coloca automaticamente os 10 Windbanners permitidos, movendo o personagem para respeitar o limite de distância.",
    Value = false,
    Callback = function(valor) farmWindBannerAtivo = valor end
})

TabFarm:CreateSection({ Name = "Preparação Eleitoral Avançada" })
TabFarm:CreateToggle({
    Name = "Auto Estudo (Um por Um)",
    Description = "Estuda ciclicamente todos os 6 temas políticos diretamente via Remote, de qualquer lugar do mapa.",
    Value = false,
    Callback = function(valor) farmEstudoAtivo = valor end
})

TabFarm:CreateToggle({
    Name = "Auto Comício (Discurso Automatizado)",
    Description = "Inicia o comício simples no ponto de interação e comanda discursos próprios contínuos para farmar apoio.",
    Value = false,
    Callback = function(valor) farmComicioAtivo = valor end
})

----------------------------------------------------
-- CATEGORIA: TELEPORTE
----------------------------------------------------
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
    Name = "CongressoEntrada",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("CongressoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateButton({
    Name = "PlantaltoEntrada",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("PlantaltoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateButton({
    Name = "SupremoEntrada",
    Callback = function()
        local obj = pastaEntradas:FindFirstChild("SupremoEntrada")
        local cf = obterCFrameDoObjeto(obj)
        if cf then executarTeleporte(cf * CFrame.new(0, 3, 0)) end
    end
})

TabTP:CreateSection({ Name = "Coordenadas da Câmara e Instâncias" })

TabTP:CreateButton({
    Name = "PontoCandidatura",
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
    Name = "MesaEstudo",
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

----------------------------------------------------
-- CATEGORIA: ESP (Rótulos Otimizados)
----------------------------------------------------
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
Description = "Contorno visual simples na pasta de NPCs da População.",
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
Description = "Exibe o cargo acima da cabeça. Ignora Cidadãos e Não Eleitos.",
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
Description = "Destaca os candidatos ao CONGRESSO ou PRESIDENCIA.",
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
Description = "Exibe quantos EstudosDebatesRealizados o player possui.",
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
Description = "Exibe o percentual de IntencaoVoto acima da cabeça.",
Value = false,
Callback = function(v)
espPorcentagemAtivo = v
if not v then
for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
end
end
})

-- CATEGORIA: FORJAR/TROLL (MANTIDA INTACTA)

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
local partes = string.split(opcaoSelecionada, " | ")
politicoSelecionado = partes[2] or ""
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

-- CATEGORIA: HUB CANDIDATOS (DASHBOARD REAL-TIME)

TabDashboard:CreateSection({ Name = "Candidatos Mais Votados (Decrescente)" })
local LabelPresidencia = TabDashboard:CreateText({ Name = "Presidência", Text = "Carregando intenções de voto..." })
TabDashboard:CreateDivider()
local LabelCongresso = TabDashboard:CreateText({ Name = "Congresso", Text = "Carregando intenções de voto..." })

-- ENGENHARIA DE EXECUÇÃO DOS SCRIPT-LOOPS (BACKGROUND)

-- Loop 1: Farm Manual NPCs (Delay Perfeito de 0.4s)
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
-- Loop 2: Teleporte + Pedidos em Players
task.spawn(function()
while true do
task.wait(1)
if farmPlayersAtivo then
local listaPlayers = Players:GetPlayers()
for i = 1, #listaPlayers do
if not farmPlayersAtivo then break end
local outroPlayer = listaPlayers[i]
if outroPlayer ~= jogador and outroPlayer.UserId then
local raizAlvo = outroPlayer.Character and outroPlayer.Character:FindFirstChild("HumanoidRootPart")
local minhaRaiz = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
if raizAlvo and minhaRaiz then
local targetId = outroPlayer.UserId
pcall(function()
minhaRaiz.CFrame = raizAlvo.CFrame * CFrame.new(0, 0, 1.5)
task.wait(0.18)
remoteAbrirInteracao:FireServer(targetId)
task.wait(0.08)
remotePedirApoio:FireServer(targetId)
end)
task.wait(0.4)
end
end
end
end
end
end)
-- Loop 3: Windbanners Automáticos
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
-- Loop 4: Farm Estudo Cíclico via Pure Remotes (Sem Teleporte)
task.spawn(function()
local listaTemasValidos = {"AGRICULTURA", "ECONOMIA", "SAÚDE", "SEGURANÇA", "EDUCAÇÃO", "INFRAESTRUTURA"}
while true do
task.wait(1)
if farmEstudoAtivo then
for i = 1, #listaTemasValidos do
if not farmEstudoAtivo then break end
local temaAtual = listaTemasValidos[i]
pcall(function()
remoteDebateEstudo:InvokeServer({ tema = temaAtual })
end)
-- Sincronização de Progresso Interno (4s Duração + 3s Cooldown Nativos)
task.wait(7.3)
end
end
end
end)
-- Loop 5: Auto Comício Inteligente (Discurso em Loop)
task.spawn(function()
while true do
task.wait(1)
if farmComicioAtivo then
local pontoComicioObj = workspace:FindFirstChild("PontosInteracao") and workspace.PontosInteracao:FindFirstChild("PontoComicio")
if pontoComicioObj then
pcall(function()
-- Passo 1: Inicia o comício no local
remoteComicioAcao:InvokeServer({
ponto = pontoComicioObj,
acao = "INICIAR",
palcoId = "SIMPLES"
})
task.wait(1)
-- Passo 2: Executa discursos contínuos durante os 40 segundos de duração do evento
local tempoInicio = os.clock()
while os.clock() - tempoInicio < 40 and farmComicioAtivo do
remoteComicioAcao:InvokeServer({
acao = "DISCURSO",
tipo = "PROPRIO"
})
task.wait(2.2) -- Intervalo seguro baseado no IntervaloPing de replicação do jogo
end
end)
-- Cooldown do organizador registrado no sistema (180 segundos) antes de recomeçar
task.wait(180.5)
end
end
end
end)
-- Loop 6: Gerenciador de ESP Complexo e Dashboard Geral
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
if tipoCand == "Presidencia" then
table.insert(dadosPresidencia, {nome = nomeExibicao, votos = intencao})
elseif tipoCand == "CONGRESSO" then
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
if tipoCand == "CONGRESSO" or tipoCand == "Presidencia" then
textoAcumulado = textoAcumulado .. string.format("[%s] ", tostring(tipoCand):upper())
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
if cargo and cargo ~= "" and cargo ~= "Cidadao" and cargo ~= "NaoEleito" then
textoAcumulado = textoAcumulado .. string.format("[%s] ", tostring(cargo):upper())
corEtiqueta = Color3.fromRGB(255, 215, 90)
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
Window:Notify({
Title = "Orvex Hub",
Content = "Orvex Hub carregado com sucesso!",
Duration = 4,
Icon = "rbxassetid://80387863064905"
})
