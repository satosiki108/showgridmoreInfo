local ShowGridMoreInfoMod = GameMain:GetMod("ShowGridMoreInfo")
 
function ShowGridMoreInfoMod:OnInit()
 
	ShowGridMoreInfoMod.tbFertilityColor = {}
	ShowGridMoreInfoMod.tbFertilityColor[XT("Rich Soil")] = "#FF9100"
	ShowGridMoreInfoMod.tbFertilityColor[XT("Fertile Soil")] = "#C80001"
	ShowGridMoreInfoMod.tbFertilityColor[XT("Healthy Soil")] = "#1E90FF"
	ShowGridMoreInfoMod.tbFertilityColor[XT("Poor Soil")] = "#00FF00"
 
	self._insideTradeWindow = false
 
	local tbEventMod = GameMain:GetMod("_Event")
 
	tbEventMod:RegisterEvent(g_emEvent.WindowEvent, self.OnWindowEvent, self)
	tbEventMod:RegisterEvent(g_emEvent.ShowNpcInfoUI, self.OnShow, self)
end
 
function ShowGridMoreInfoMod:OnRender(_)
	self:ShowGridInfo()
end
 
function ShowGridMoreInfoMod:ShowGridInfo()
	if CS.UI_WorldLayer.Instance == nil then
		print("UI_WorldLayer was nil")
		return
	end
 
	if GridMgr == nil then
		print("Grid manager was nil")
		return
	end
 
	if CS.Wnd_GameMain.Instance.UIInfo == nil then
		print("Wnd_GameMain was nil")
		return
	end
 
	if self.bHasResizeTextArea ~= true then
		CS.Wnd_GameMain.Instance.UIInfo.m_n32.UBBEnabled = true
		CS.Wnd_GameMain.Instance.UIInfo.m_n32:SetSize(150, 150)
		self.bHasResizeTextArea = true
	end
 
	local nCurMouseKey = CS.UI_WorldLayer.Instance.MouseGridKey
	if nCurMouseKey == self.nLastMouseKey and self.bForceUpdate ~= true then
		return
	end
	self.nLastMouseKey = nCurMouseKey
	self.bForceUpdate = nil
 
	if not GridMgr:KeyVaild(nCurMouseKey) then
		print("Grid manager was nil")
		return
	end
 
	local fLing = Map:GetLing(nCurMouseKey)
	local fLingAddion = Map.Effect:GetEffect(nCurMouseKey, CS.XiaWorld.g_emMapEffectKind.LingAddion)
	local fLingAddionInFact = Map.Effect:GetEffect(nCurMouseKey, CS.XiaWorld.g_emMapEffectKind.LingAddion, 0, true)
	local fToMaxLingAddionTime = 0
	if fLingAddion ~= fLingAddionInFact then
		local MapEffectData = Map.Effect:GetEffectData(nCurMouseKey, CS.XiaWorld.g_emMapEffectKind.LingAddion)
		fToMaxLingAddionTime = MapEffectData.creattime + 3000 - TolSecond
		self.bForceUpdate = true
	end
 
	local strLingAddion = ""
	if fLingAddion == 0 then
		strLingAddion = "None"
	elseif fToMaxLingAddionTime == 0 then
		strLingAddion = string.format("%.2f[color=#00FF00](Max)[/color]", fLingAddionInFact)
	else
		strLingAddion = string.format("%.2f[color=#FF0000](%s Wait%.2f)[/color]", fLingAddionInFact, self:GameTime2Str(fToMaxLingAddionTime), fLingAddion)
	end
 
	if CS.Wnd_GameMain.Instance.openFengshui then
		local EArray = Map:GetElement(nCurMouseKey)
		local EPArray = Map:GetElementProportion(nCurMouseKey)
		CS.Wnd_GameMain.Instance.UIInfo.m_n32.text = string.format("Qi:%.2f\nQi Gathering:%s\n[color=#FFEB68]Metal  %05.2f  %02.0f%%[/color]\n[color=#78C84E]Wood  %05.2f  %02.0f%%[/color]\n[color=#81C1F5]Water  %05.2f  %02.0f%%[/color]\n[color=#DA494E]Fire  %05.2f  %02.0f%%[/color]\n[color=#986B39]Earth  %05.2f  %02.0f%%[/color]",
				fLing,
				strLingAddion,
				EArray[1], EPArray[1] * 100,
				EArray[2], EPArray[2] * 100,
				EArray[3], EPArray[3] * 100,
				EArray[4], EPArray[4] * 100,
				EArray[5], EPArray[5] * 100)
		return
	end
 
	local fTemperature = Map:GetTemperature(nCurMouseKey)
	local fFertility = Map:GetFertility(nCurMouseKey)
	local fBeauty = Map:GetBeauty(nCurMouseKey, true)
	local fLight = Map:GetLight(nCurMouseKey)
	local strTerrainName = Map.Terrain:GetTerrainName(nCurMouseKey, true)
	local TerrainDef = Map.Terrain:GetTerrain(nCurMouseKey)
 
	local nX = (nCurMouseKey - nCurMouseKey % Map.Size) / Map.Size + 1
	local nY = nCurMouseKey % Map.Size + 1
	local strMsg0 = Map.Terrain:GetTerrainName(nCurMouseKey, false)
	local strMsg1 = self:GetValueByMap(GameDefine.FertilityDesc, fFertility)
	local strMsg3 = self:GetValueByMap(GameDefine.TemperatureDesc, fTemperature)
	local strMsg2 = self:GetValueByMap(GameDefine.BeautyDesc, fBeauty)
	local strMsg4 = self:GetValueByMap(GameDefine.LightDesc, fLight)
	local strMsg5 = ""
	local strMsg6 = ""
	local strMsg7 = tostring(fTemperature)
	local strMsg8 = ""
 
	if AreaMgr:CheckArea(nCurMouseKey, "Room") ~= nil then
		strMsg5 = XT("(Room)")
	end
 
	if TerrainDef.IsWater and Map.Snow:GetSnow(nCurMouseKey) >= 200 then
		strMsg8 = XT("(Snow)")
	end
 
	if strTerrainName ~= nil and strTerrainName ~= "" then
		strMsg6 = string.format("(%s)", strTerrainName)
	end
 
	-- {0}{8}{6}\n{1}\n{2}\n{4}\n{3}{5}({7:f1}℃)
	CS.Wnd_GameMain.Instance.UIInfo.m_n32.text = string.format("Qi:%.2f\nQi Gathering:%s\n%s%s%s(%d, %d)\n%s[color=%s](%.2f)[/color]\n%s(%.2f)\n%s(%.2f)\n%s%s(%.1f℃)",
			fLing,
			strLingAddion,
			strMsg0, strMsg8, strMsg6, nX, nY,
			strMsg1, self.tbFertilityColor[strMsg1], fFertility,
			strMsg2, fBeauty,
			strMsg4, fLight,
			strMsg3, strMsg5, strMsg7)
end
 
function ShowGridMoreInfoMod:OnWindowEvent(pThing, pObjs)
	local pWnd = pObjs[0]
	local iArg = pObjs[1]
 
	if pWnd == CS.Wnd_SchoolTrade.Instance and iArg == 1 and not self._insideTradeWindow then
		self._insideTradeWindow = true
 
		pWnd.UIInfo.m_itemvalue.visible = true
		pWnd.UIInfo.m_friendpontvalue.visible = true
		pWnd.UIInfo.m_friendpontvalue.y = pWnd.UIInfo.m_itemvalue.y - pWnd.UIInfo.m_friendpontvalue.actualHeight
 
		pWnd.UIInfo.m_n51.onClickItem:Add(
			function(ctx)
				pWnd.UIInfo.m_itemvalue.visible = true
				pWnd.UIInfo.m_friendpontvalue.visible = true
				pWnd.UIInfo.m_friendpontvalue.y = pWnd.UIInfo.m_itemvalue.y - pWnd.UIInfo.m_friendpontvalue.actualHeight
			end
		)
	elseif pWnd == CS.Wnd_SchoolTrade.Instance and iArg == 2 and self._insideTradeWindow then
		self._insideTradeWindow = false;
	end
end
 
function ShowGridMoreInfoMod:GetValueByMap(tbMap, Key)
	local Value
	for k, v in pairs(tbMap) do
		if Key >= k then
			return v
		end
		Value = v
	end
	return Value
end
 
function ShowGridMoreInfoMod:GetTooltipsWindow()
	print("GetTooltipsWindow Event detected")
	return GameMain:GetMod("Windows"):GetWindow("ShowGridMoreInfo_TooltipsWindow"):Show()
end
 
-- 游戏的时间转成便于现实阅读的时间格式
function ShowGridMoreInfoMod:GameTime2Str(fGameTime)
	if fGameTime > 600 then
		return string.format("%.2fDays", fGameTime / 600)
	end
	local fReallyTime = fGameTime / 600 * 24 * 3600
	local nHour = math.modf(fReallyTime / 3600)
	local nMin = math.modf(fReallyTime % 3600 / 60)
	return string.format("%02d:%02d", nHour, nMin)
end
 
function ShowGridMoreInfoMod:BindFertilityColor(strFertility)
	return string.format("[coolor=#%s]%s[color]", self.tbFertilityColor[strFertility], strFertility)
end
 
