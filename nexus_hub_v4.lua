-- HUB MOBILE | FARM, ESP OTIMIZADO & DASHBOARD DE ELEIÇÕES (RAYFIELD GEN2)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local jogador = Players.LocalPlayer
local pastaNPC = Workspace:WaitForChild("PopulacaoNPC")
local pastaEntradas = Workspace:WaitForChild("EntradasSaidas")

-- Remotes
local remoteAbrirInteracao = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("InteracaoPlayer"):WaitForChild("Abrir")
local remotePedirApoio = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ApoioPolitico"):WaitForChild("Pedir")
local remoteWindBanner = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Campanha"):WaitForChild("ColocarWindBanner")

-- Estados Visuais de Controle
local farmManualAtivo = false
local farmPlayersAtivo = false
local farmWindBannerAtivo = false

local espNPCAtivo = false
local espPoliticoAtivo = false
local espCandidatosAtivo = false
local espPorcentagemAtivo = false

local ultimoUso = {}
local COOLDOWN_LOCAL = 5

-- 1. Inicializa a biblioteca Rayfield Gen2
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- 2. Janela Principal
local Window = Rayfield:CreateWindow({
    Name = "NEXUS HUB | MANAGER",
    Subtitle = "Sistemas Políticos",
    Theme = "Default",
    Icon = "rbxassetid://80387863064905",
    ShowName = "Nexus",
    Configuration = {
        AutoSave = true,
        AutoLoad = false,
        FileName = "NexusFarmConfig"
    }
})

-- Abas Principais
local TabFarm = Window:CreateTab({ Name = "Farm", Icon = "rbxassetid://100604009889706" })
local TabTP = Window:CreateTab({ Name = "Teleporte", Icon = "rbxassetid://125823673784681" })
local TabESP = Window:CreateTab({ Name = "Esp", Icon = "rbxassetid://91452555903853" })
local TabDashboard = Window:CreateTab({ Name = "Hub Candidatos", Icon = "rbxassetid://111263549366178" })
local TabConfig = Window:CreateTab({ Name = "Config", Icon = "rbxassetid://129180860773723" })

----------------------------------------------------
-- CATEGORIA: FARM
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
-- CATEGORIA: ESP (Mecanismo Otimizado e Filtrado)
----------------------------------------------------
TabESP:CreateSection({ Name = "Visualizadores e Filtros Políticos" })

local function obterInformacaoPlayer(p, nomeChave)
    local char = p.Character
    local attr = p:GetAttribute(nomeChave) or (char and char:GetAttribute(nomeChave))
    if attr then return attr end
    local var = p:FindFirstChild(nomeChave, true) or (char and char:FindFirstChild(nomeChave, true))
    if var and (var:IsA("ValueObject") or var:IsA("StringValue") or var:IsA("NumberValue")) then return var.Value end
    return nil
end

local function limparEstruturasCustomESP(char)
    if char then
        local hl = char:FindFirstChild("NexusESP")
        if hl then hl:Destroy() end
        local bill = char:FindFirstChild("Head") and char.Head:FindFirstChild("NexusBillboard")
        if bill then bill:Destroy() end
    end
end

local function criarBillboardCustom(head, texto, cor)
    local bill = head:FindFirstChild("NexusBillboard")
    if bill then bill:Destroy() end

    bill = Instance.new("BillboardGui")
    bill.Name = "NexusBillboard"
    bill.Adornee = head
    bill.Size = UDim2.fromOffset(200, 30)
    bill.StudsOffset = Vector3.new(0, 3.8, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 150
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
    lbl.TextStrokeTransparency = 0.2
    lbl.Parent = bill
end

local function aplicarHighlight(instancia, corBorda)
    local hl = instancia:FindFirstChild("NexusESP")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "NexusESP"
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
    Description = "Contorno visual simples nos NPCs da População.",
    Value = false,
    Callback = function(v)
        local estadoAnterior = espNPCAtivo
        espNPCAtivo = v
        if estadoAnterior and not v then
            for _, npc in ipairs(pastaNPC:GetChildren()) do
                local hl = npc:FindFirstChild("NexusESP") if hl then hl:Destroy() end
            end
        end
    end
})

TabESP:CreateToggle({
    Name = "Esp Político",
    Description = "Exibe o cargo acima da cabeça. Ignora Cidadãos e Não Eleitos.",
    Value = false,
    Callback = function(v)
        local estadoAnterior = espPoliticoAtivo
        espPoliticoAtivo = v
        if estadoAnterior and not v then
            for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
        end
    end
})

TabESP:CreateToggle({
    Name = "Esp Candidates",
    Description = "Verifica 'TipoCandidatura' (CONGRESSO / Presidencia).",
    Value = false,
    Callback = function(v)
        local estadoAnterior = espCandidatosAtivo
        espCandidatosAtivo = v
        if estadoAnterior and not v then
            for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
        end
    end
})

TabESP:CreateToggle({
    Name = "Esp Porcentagem",
    Description = "Exibe o número de 'IntencaoVoto' acima do crânio.",
    Value = false,
    Callback = function(v)
        local estadoAnterior = espPorcentagemAtivo
        espPorcentagemAtivo = v
        if estadoAnterior and not v then
            for _, p in ipairs(Players:GetPlayers()) do if p.Character then limparEstruturasCustomESP(p.Character) end end
        end
    end
})

----------------------------------------------------
-- CATEGORIA: HUB CANDIDATOS (DASHBOARD REAL-TIME)
----------------------------------------------------
TabDashboard:CreateSection({ Name = "Candidatos Mais Votados (Decrescente)" })

local LabelPresidencia = TabDashboard:CreateText({ Name = "Presidência", Text = "Carregando intenções de voto..." })
TabDashboard:CreateDivider()
local LabelCongresso = TabDashboard:CreateText({ Name = "Congresso", Text = "Carregando intenções de voto..." })

----------------------------------------------------
-- EXECUÇÃO CENTRALIZADA DOS LOOPS DO HUB
----------------------------------------------------

-- Loop 1: Farm Manual NPCs (Estável e Intocado)
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

-- Loop 3: Windbanners
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

-- Loop 4: Renderizador Inteligente de ESP e Dashboard Geral
task.spawn(function()
    while true do
        task.wait(0.6) -- Otimização para impedir gargalo gráfico no Mobile
        
        -- ESP: NPCs
        if espNPCAtivo then
            for _, npc in ipairs(pastaNPC:GetChildren()) do
                if npc:IsA("Model") then aplicarHighlight(npc, Color3.fromRGB(0, 180, 255)) end
            end
        end

        -- Coleta estruturada para o Hub de Estatísticas das Eleições
        local dadosPresidencia = {}
        local dadosCongresso = {}

        local todosPlayers = Players:GetPlayers()
        for i = 1, #todosPlayers do
            local p = todosPlayers[i]
            
            -- Coleta de metadados de intenção
            local nomeExibicao = p.DisplayName or p.Name
            local intencao = tonumber(obterInformacaoPlayer(p, "IntencaoVoto")) or 0
            local tipoCand = obterInformacaoPlayer(p, "TipoCandidatura")
            
            if tipoCand == "Presidencia" then
                table.insert(dadosPresidencia, {nome = nomeExibicao, votos = intencao})
            elseif tipoCand == "CONGRESSO" then
                table.insert(dadosCongresso, {nome = nomeExibicao, votos = intencao})
            end

            -- Processamento de ESPs ativos nos personagens vivos
            if p.Character and p.Character:FindFirstChild("Head") and p ~= jogador then
                local head = p.Character.Head
                local processado = false

                -- Função: ESP Porcentagem (Prioridade 1)
                if espPorcentagemAtivo then
                    criarBillboardCustom(head, string.format("%d%% Votos", intencao), Color3.fromRGB(90, 255, 90))
                    aplicarHighlight(p.Character, Color3.fromRGB(90, 255, 90))
                    processado = true
                end

                -- Função: ESP Candidatos (Prioridade 2)
                if espCandidatosAtivo and not processado then
                    if tipoCand == "CONGRESSO" or tipoCand == "Presidencia" then
                        criarBillboardCustom(head, tostring(tipoCand), Color3.fromRGB(0, 255, 235))
                        aplicarHighlight(p.Character, Color3.fromRGB(0, 255, 235))
                        processado = true
                    end
                end

                -- Função: ESP Político com Filtro de Remoção (Prioridade 3)
                if espPoliticoAtivo and not processado then
                    local cargo = obterInformacaoPlayer(p, "Cargo")
                    if cargo and cargo ~= "" and cargo ~= "Cidadao" and cargo ~= "NaoEleito" then
                        criarBillboardCustom(head, tostring(cargo), Color3.fromRGB(255, 215, 90))
                        aplicarHighlight(p.Character, Color3.fromRGB(255, 180, 0))
                        processado = true
                    end
                end

                -- Limpa se nenhum dos toggles correlacionados estiver ligado
                if not espPorcentagemAtivo and not espCandidatosAtivo and not espPoliticoAtivo then
                    limparEstruturasCustomESP(p.Character)
                end
            end
        end

        -- Ordenação das Tabelas (Decrescente: do maior para o menor)
        table.sort(dadosPresidencia, function(a, b) return a.votos > b.votos end)
        table.sort(dadosCongresso, function(a, b) return a.votos > b.votos end)

        -- Formata e renderiza os dados organizados na aba Hub Candidatos
        local strPres = ""
        for index, item in ipairs(dadosPresidencia) do
            strPres = strPres .. string.format("%d. %s — %d%%\n", index, item.nome, item.votos)
        end
        LabelPresidencia:SetTitle(strPres == "" and "Nenhum candidato à Presidência ativo." or strPres)

        local strCong = ""
        for index, item in ipairs(dadosCongresso) do
            strCong = strCong .. string.format("%d. %s — %d%%\n", index, item.nome, item.votos)
        end
        LabelCongresso:SetTitle(strCong == "" and "Nenhum candidato ao Congresso ativo." or strCong)
    end
end)

Window:Notify({
    Title = "Nexus Hub",
    Content = "Painel Eleitoral e Filtros Otimizados carregados!",
    Duration = 4,
    Icon = "rbxassetid://80387863064905"
})
