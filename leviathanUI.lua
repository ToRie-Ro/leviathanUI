local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GlassUI = {}
GlassUI.__index = GlassUI

-- Default theme (glass-like)
local THEME = {
	windowSize = UDim2.new(0, 550, 0, 360),
	blurColor = Color3.fromRGB(255, 255, 255),
	accent = Color3.fromRGB(10, 132, 255),
	bgTransparency = 0.60,
	gradientColor1 = Color3.fromRGB(255,255,255),
	gradientColor2 = Color3.fromRGB(240,240,255),
	textColor = Color3.fromRGB(28,28,30),
	subTextColor = Color3.fromRGB(80,80,85),
	font = Enum.Font.GothamSemibold,
	radius = UDim.new(0, 12),
	animationTime = 0.18
}

-- Helpers
local function make(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function tween(obj, props, time)
	time = time or THEME.animationTime
	local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

-- Glass background creator (frame with gradient, stroke, corner)
local function applyGlassStyle(frame)
	frame.BackgroundTransparency = THEME.bgTransparency
	frame.BackgroundColor3 = THEME.blurColor

	-- Gradient to simulate frosted look
	local grad = make("UIGradient", {
		Parent = frame,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, THEME.gradientColor1),
			ColorSequenceKeypoint.new(1, THEME.gradientColor2),
		},
		Rotation = 90
	})

	-- Subtle stroke
	local stroke = make("UIStroke", {
		Parent = frame,
		Color = Color3.fromRGB(255,255,255),
		Transparency = 0.8,
		Thickness = 1
	})

	-- Shadow (using subtle shadow frame)
	local shadow = make("Frame", {
		Name = "Shadow",
		Parent = frame,
		Size = UDim2.new(1,12,1,12),
		Position = UDim2.new(0,-6,0,-6),
		ZIndex = 0,
		BackgroundTransparency = 1,
	})
	-- corner
	local corner = make("UICorner", {
		Parent = frame,
		CornerRadius = THEME.radius
	})
end

-- Create main ScreenGui container
local function getPlayerGui()
	local pg = LocalPlayer:WaitForChild("PlayerGui")
	return pg
end

local function createScreenGui()
	local parent = getPlayerGui()
	local sg = Instance.new("ScreenGui")
	sg.Name = "GlassUILib"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = parent
	return sg
end

-- Window object
local Window = {}
Window.__index = Window

function Window:CreateTab(title)
	local tabButton = make("TextButton", {
		Name = title .. "_TabBtn",
		Size = UDim2.new(0, 120, 0, 36),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = THEME.textColor,
		Font = THEME.font,
		TextSize = 14,
		ZIndex = 5,
		Parent = self._tabsBar
	})

	local tabContent = make("Frame", {
		Name = title .. "_Content",
		Size = UDim2.new(1, -20, 1, -60),
		Position = UDim2.new(0, 10, 0, 50),
		BackgroundTransparency = 1,
		Parent = self._body
	})
	local layout = make("UIListLayout", {Parent = tabContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() end)

	local tabObj = {
		_title = title,
		_button = tabButton,
		_content = tabContent,
		_children = {}
	}
	setmetatable(tabObj, {__index = function(t, k)
		if k == "CreateButton" then
			return function(_, text, callback)
				local btn = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.fromRGB(255,255,255),
					BackgroundTransparency = 0.85,
					Text = text,
					TextColor3 = THEME.textColor,
					Font = THEME.font,
					TextSize = 14,
					Parent = tabContent
				})
				applyGlassStyle(btn)
				btn.MouseButton1Click:Connect(function()
					pcall(callback)
					-- click animation
					local orig = btn.BackgroundTransparency
					tween(btn, {BackgroundTransparency = math.clamp(orig - 0.08, 0, 1)}, 0.06)
					wait(0.06)
					tween(btn, {BackgroundTransparency = orig}, 0.12)
				end)
				return btn
			end
		elseif k == "CreateToggle" then
			return function(_, labelText, default, callback)
				local container = make("Frame", {Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1, Parent = tabContent})
				local label = make("TextLabel", {
					Parent = container,
					Position = UDim2.new(0, 12, 0, 😎,
					Size = UDim2.new(1, -84, 0, 28),
					BackgroundTransparency = 1,
					Text = labelText,
					TextColor3 = THEME.textColor,
					Font = THEME.font,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local switch = make("ImageButton", {
					Parent = container,
					Size = UDim2.new(0, 52, 0, 28),
					Position = UDim2.new(1, -64, 0, 😎,
					BackgroundTransparency = 0.6,
					AutoButtonColor = false,
					BorderSizePixel = 0,
				})
				applyGlassStyle(switch)
				local switchCorner = make("UICorner", {Parent = switch, CornerRadius = UDim.new(0, 14)})
				local knob = make("Frame", {
					Parent = switch,
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(default and 1 or 0, 4, 0, 2),
					BackgroundColor3 = Color3.fromRGB(255,255,255),
					BackgroundTransparency = 0.9
				})
				knob.ZIndex = 6
				local knobCorner = make("UICorner", {Parent = knob, CornerRadius = UDim.new(1,0)})
				local state = default or false

				local function setState(s, noCallback)
					state = s
					if state then
						tween(knob, {Position = UDim2.new(1, -28, 0, 2)})
					else
						tween(knob, {Position = UDim2.new(0, 4, 0, 2)})
					end
					if not noCallback then
						pcall(callback, state)
					end
				end

				switch.MouseButton1Click:Connect(function()
					setState(not state)
				end)

				-- init
				setState(state, true)
				return {
					_container = container,
					Set = setState,
					Get = function() return state end
				}
			end
		elseif k == "CreateCheckbox" then
			return function(_, labelText, default, callback)
				local container = make("Frame", {Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = tabContent})
				local label = make("TextLabel", {
					Parent = container,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -40, 0, 24),
					BackgroundTransparency = 1,
					Text = labelText,
					TextColor3 = THEME.textColor,
					Font = THEME.font,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local box = make("ImageButton", {
					Parent = container,
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -36, 0, 6),
					BackgroundTransparency = 0.6,
					AutoButtonColor = false,
					BorderSizePixel = 0,
				})
				applyGlassStyle(box)
				local tick = make("TextLabel", {
					Parent = box,
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					Text = default and "✓" or "",
					TextColor3 = THEME.accent,
					Font = Enum.Font.GothamBold,
					TextSize = 18
				})
				local state = default or false

				local function setState(s, noCallback)
					state = s
					tick.Text = state and "✓" or ""
					if not noCallback then pcall(callback, state) end
				end

				box.MouseButton1Click:Connect(function()
					setState(not state)
				end)
				setState(state, true)
				return {
					_container = container,
					Set = setState,
					Get = function() return state end
				}
			end
		elseif k == "CreateDropdown" then
			return function(_, labelText, options, callback, defaultIndex)
				options = options or {}
				local container = make("Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Parent = tabContent})
				local label = make("TextLabel", {
					Parent = container,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -140, 0, 28),
					BackgroundTransparency = 1,
					Text = labelText,
					TextColor3 = THEME.textColor,
					Font = THEME.font,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local box = make("TextButton", {
					Parent = container,
					Size = UDim2.new(0, 120, 0, 28),
					Position = UDim2.new(1, -132, 0, 6),
					AutoButtonColor = false,
					Text = options[defaultIndex] or "Select",
					Font = THEME.font,
					TextSize = 14,
					TextColor3 = THEME.textColor,
					BackgroundTransparency = 0.6,
					BorderSizePixel = 0
				})
				applyGlassStyle(box)
				local dropdownFrame = make("Frame", {
					Parent = self._screenGui,
					Size = UDim2.new(0, 160, 0, 0),
					Position = UDim2.new(0, 100, 0, 100),
					BackgroundTransparency = 1,
					ZIndex = 50,
					Visible = false
				})
				local dfBody = make("Frame", {
					Parent = dropdownFrame,
					Size = UDim2.new(1,0,0,0),
					Position = UDim2.new(0,0,0,0),
					BackgroundTransparency = 0,
					BackgroundColor3 = THEME.blurColor
				})
				applyGlassStyle(dfBody)
				local scroll = make("ScrollingFrame", {
					Parent = dfBody,
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					CanvasSize = UDim2.new(0,0,0,0),
					ScrollBarThickness = 6
				})
				local listLayout = make("UIListLayout", {Parent = scroll, Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder})
				listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					local newY = listLayout.AbsoluteContentSize.Y + 12
					dfBody.Size = UDim2.new(1,0,0,newY)
					dropdownFrame.Size = UDim2.new(0, 160, 0, newY)
				end)
				local selected = options[defaultIndex] or nil

				local function clearDropdown()
					for _, child in ipairs(scroll:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
				end

				local function openDropdown()
					dropdownFrame.Visible = true
					local targetPos = box.AbsolutePosition + Vector2.new(0, box.AbsoluteSize.Y + 6)
					dropdownFrame.Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
					tween(dropdownFrame, {Size = dropdownFrame.Size}, 0.12)
				end

				local function closeDropdown()
					dropdownFrame.Visible = false
				end

				local function rebuild()
					clearDropdown()
					for i, opt in ipairs(options) do
						local item = make("TextButton", {
							Parent = scroll,
							Size = UDim2.new(1, -12, 0, 28),
							BackgroundTransparency = 0.6,
							AutoButtonColor = false,
							Text = tostring(opt),
							Font = THEME.font,
							TextSize = 14,
							TextColor3 = THEME.textColor
						})
						applyGlassStyle(item)
						item.MouseButton1Click:Connect(function()
							selected = opt
							box.Text = tostring(opt)
							pcall(callback, opt)
							closeDropdown()
						end)
					end
					scroll.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 😎
				end

				box.MouseButton1Click:Connect(function()
					if dropdownFrame.Visible then
						closeDropdown()
					else
						rebuild()
						openDropdown()
					end
				end)

				-- Click anywhere outside to close dropdown (simple)
				self._screenGui.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if dropdownFrame.Visible then
							-- if click not inside dropdownFrame and not the box
							local m = LocalPlayer:GetMouse()
							if not dropdownFrame:IsAncestorOf(m.Target) and not box:IsAncestorOf(m.Target) then
								closeDropdown()
							end
						end
					end
				end)

				-- initial build
				rebuild()

				return {
					_container = container,
					Get = function() return selected end,
					SetOptions = function(newOptions)
						options = newOptions
						rebuild()
					end
				}
			end
		elseif k == "CreateMultiDropdown" then
			return function(_, labelText, options, callback, defaultList)
				options = options or {}
				defaultList = defaultList or {}
				local container = make("Frame", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Parent = tabContent})
				local label = make("TextLabel", {
					Parent = container,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -200, 0, 28),
					BackgroundTransparency = 1,
					Text = labelText,
					TextColor3 = THEME.textColor,
					Font = THEME.font,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local box = make("TextButton", {
					Parent = container,
					Size = UDim2.new(0, 160, 0, 28),
					Position = UDim2.new(1, -172, 0, 6),
					AutoButtonColor = false,
					Text = "Select...",
					Font = THEME.font,
					TextSize = 14,
					TextColor3 = THEME.textColor,
					BackgroundTransparency = 0.6,
					BorderSizePixel = 0
				})
				applyGlassStyle(box)

				-- Dropdown area
				local dropdownFrame = make("Frame", {
					Parent = self._screenGui,
					Size = UDim2.new(0, 220, 0, 0),
					Position = UDim2.new(0, 100, 0, 100),
					BackgroundTransparency = 1,
					ZIndex = 50,
					Visible = false
				})
				local dfBody = make("Frame", {
					Parent = dropdownFrame,
					Size = UDim2.new(1,0,0,0),
					Position = UDim2.new(0,0,0,0),
					BackgroundTransparency = 0,
					BackgroundColor3 = THEME.blurColor
				})
				applyGlassStyle(dfBody)
				local scroll = make("ScrollingFrame", {
					Parent = dfBody,
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					CanvasSize = UDim2.new(0,0,0,0),
					ScrollBarThickness = 6
				})
				local listLayout = make("UIListLayout", {Parent = scroll, Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder})
				listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					local newY = listLayout.AbsoluteContentSize.Y + 12
					dfBody.Size = UDim2.new(1,0,0,newY)
					dropdownFrame.Size = UDim2.new(0, 220, 0, newY)
				end)

				local selectedSet = {}
				for _, v in pairs(defaultList) do selectedSet[v] = true end

				local function updateBoxText()
					local t = {}
					for k, _ in pairs(selectedSet) do table.insert(t, k) end
					if #t == 0 then
						box.Text = "Select..."
					else
						box.Text = table.concat(t, ", ")
					end
					pcall(callback, t)
				end

				local function rebuild()
					for _, child in ipairs(scroll:GetChildren()) do
						if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
					end
					for _, opt in ipairs(options) do
						local entry = make("Frame", {Parent = scroll, Size = UDim2.new(1, -12, 0, 32), BackgroundTransparency = 1})
						local cb = make("ImageButton", {
							Parent = entry,
							Size = UDim2.new(0, 28, 0, 28),
							Position = UDim2.new(0, 4, 0, 2),
							BackgroundTransparency = 0.6,
							AutoButtonColor = false
						})
						applyGlassStyle(cb)
						local mark = make("TextLabel", {
							Parent = cb,
							Size = UDim2.new(1,0,1,0),
							BackgroundTransparency = 1,
							Text = selectedSet[opt] and "✓" or "",
							TextColor3 = THEME.accent,
							Font = Enum.Font.GothamBold,
							TextSize = 16
						})
						local lab = make("TextLabel", {
							Parent = entry,
							Position = UDim2.new(0, 40, 0, 4),
							Size = UDim2.new(1, -44, 0, 24),
							BackgroundTransparency = 1,
							Text = tostring(opt),
							TextColor3 = THEME.textColor,
							Font = THEME.font,
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left
						})
						cb.MouseButton1Click:Connect(function()
							selectedSet[opt] = not selectedSet[opt]
							mark.Text = selectedSet[opt] and "✓" or ""
							updateBoxText()
						end)
					end
					scroll.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 12)
				end

				local function open()
					dropdownFrame.Visible = true
					local targetPos = box.AbsolutePosition + Vector2.new(0, box.AbsoluteSize.Y + 6)
					dropdownFrame.Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
				end
				local function close()
					dropdownFrame.Visible = false
				end

				box.MouseButton1Click:Connect(function()
					if dropdownFrame.Visible then
						close()
					else
						rebuild()
						open()
					end
				end)

				self._screenGui.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if dropdownFrame.Visible then
							local m = LocalPlayer:GetMouse()
							if not dropdownFrame:IsAncestorOf(m.Target) and not box:IsAncestorOf(m.Target) then
								close()
							end
						end
					end
				end)

				updateBoxText()
				return {
					_container = container,
					Get = function()
						local t = {}
						for k,_ in pairs(selectedSet) do table.insert(t,k) end
						return t
					end,
					SetOptions = function(newOptions)
						options = newOptions
						rebuild()
					end
				}
			end
		elseif k == "CreateParagraph" then
			return function(_, text)
				local container = make("Frame", {Size = UDim2.new(1,0,0,80), BackgroundTransparency = 1, Parent = tabContent})
				local label = make("TextLabel", {
					Parent = container,
					Position = UDim2.new(0,12,0,6),
					Size = UDim2.new(1, -24, 1, -12),
					BackgroundTransparency = 1,
					Text = text or "",
					TextColor3 = THEME.subTextColor,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top
				})
				return label
			end
		else
			return rawget(Window, k)
		end
	end})

	-- add basic click to switch content
	tabButton.MouseButton1Click:Connect(function()
		for _, child in ipairs(self._body:GetChildren()) do
			if child:IsA("Frame") then child.Visible = false end
		end
		tabContent.Visible = true
		-- style selected
		for _, btn in ipairs(self._tabsBar:GetChildren()) do
			if btn:IsA("TextButton") then
				tween(btn, {TextTransparency = 0.3}, 0.12)
			end
		end
		tween(tabButton, {TextTransparency = 0}, 0.12)
	end)

	-- auto-select if first tab
	if #self._tabs == 0 then
		tabContent.Visible = true
		tween(tabButton, {TextTransparency = 0}, 0.12)
	else
		tabContent.Visible = false
		tween(tabButton, {TextTransparency = 0.6}, 0.12)
	end

	table.insert(self._tabs, tabObj)
	return tabObj
end

-- Public API: CreateWindow
function GlassUI:CreateWindow(title)
	local sg = self._screenGui or createScreenGui()
	self._screenGui = sg

	-- Main window
	local win = make("Frame", {
		Name = title or "Window",
		Size = THEME.windowSize,
		Position = UDim2.new(0.5, -THEME.windowSize.X.Offset/2, 0.5, -THEME.windowSize.Y.Offset/2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = sg
	})
	applyGlassStyle(win)

	-- Title bar
	local titleBar = make("Frame", {
		Parent = win,
		Size = UDim2.new(1, 0, 0, 48),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
	})
	local titleLabel = make("TextLabel", {
		Parent = titleBar,
		Text = title or "Window",
		Position = UDim2.new(0, 12, 0, 😎,
		Size = UDim2.new(1, -24, 0, 32),
		BackgroundTransparency = 1,
		TextColor3 = THEME.textColor,
		Font = THEME.font,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	-- body
	local body = make("Frame", {
		Parent = win,
		Size = UDim2.new(1,0,1, -60),
		Position = UDim2.new(0,0,0,48),
		BackgroundTransparency = 1
	})
	-- tabs bar
	local tabsBar = make("Frame", {
		Parent = win,
		Size = UDim2.new(1,0,0,40),
		Position = UDim2.new(0,0,0,48-40),
		BackgroundTransparency = 1
	})

	local winObj = {
		_frame = win,
		_body = body,
		_tabsBar = tabsBar,
		_tabs = {},
		_screenGui = sg
	}
	setmetatable(winObj, {__index = Window})

	-- Simple drag
	local dragging = false
	local dragStart = nil
	local startPos = nil
	titleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = win.Position
		end
	end)
	game:GetService("UserInputService").InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - dragStart
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	titleBar.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	return winObj
end

-- Constructor
function GlassUI.new()
	local self = setmetatable({}, GlassUI)
	self._screenGui = createScreenGui()
	return self
end

-- Allow quick usage: require(Module)() returns library instance
return setmetatable({}, {
	_call = function(, ...)
		return GlassUI.new(...)
	end
})
