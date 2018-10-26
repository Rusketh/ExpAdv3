/*============================================================================================================================================
	Component for Lua syntax highlighting for Golem
	Author: Oskar
============================================================================================================================================*/

local table_concat = table.concat 
local string_match = string.match 
local string_rep = string.rep 
local string_sub = string.sub 
local string_gsub = string.gsub 
local string_find = string.find 
local string_gmatch = string.gmatch 

local type = type 
local pairs = pairs 

local Syntax = { sName = "Lua" }
Syntax.__index = Syntax

function Syntax:Init( dEditor )
	self.dEditor = dEditor
	self.Syntaxer.dEditor = dEditor
	dEditor:SetSyntax( self ) 
	dEditor:SetCodeFolding( true ) 
	dEditor:SetParamMatching( true )
end

/*---------------------------------------------------------------------------
Formating and folding
---------------------------------------------------------------------------*/

function Syntax:FindValidLines( )
	local LinesToFold = self.dEditor:ExpandAll( )
	local tRows = self.dEditor.tRows
	local MultilineComment
	local ValidLines = { }
	local Row, Char = 1, 0
	
	while Row <= #tRows do
		local Line = tRows[Row]
		while Char < #Line do
			Char = Char + 1
			local Text = Line[Char]
			local sType = type( MultilineComment )
			
			if sType == "number" then -- End comment or string (]])
				if string_match( string_sub( Line, 1, Char ), "%]" .. string_rep( "=", MultilineComment ) .. "%]$" ) then
					ValidLines[#ValidLines][2] = { Row, Char }
					MultilineComment = nil
				end
			elseif sType == "string" then -- End string 
				if Text == MultilineComment and Line[Char-1] ~= "\\" then
					ValidLines[#ValidLines][2] = { Row, Char }
					MultilineComment = nil
				end 
			elseif sType == "boolean" and MultilineComment then -- End comment (*/)
				if Text == "/" and Line[Char-1] == "*" then
					ValidLines[#ValidLines][2] = { Row, Char }
					MultilineComment = nil
				end 
			elseif string_match( Line, "^%[=*%[", Char ) then -- Multi line string ([[)
				MultilineComment = #string_match( Line, "^%[(=*)%[", Char )
				ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
			elseif string_match( Line, "^[\"']", Char ) then -- Normal string (" or ')
				MultilineComment = string_match( Line, "^([\"'])", Char )
				ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
			elseif string_match( Line, "^%-%-%[=*%[", Char ) then -- Multi line comment (--[[)
				MultilineComment = #string_match( Line, "^%-%-%[(=*)%[", Char )
				ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
			elseif string_match( Line, "^%-%-", Char ) then -- Single line comment (--)
				ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
				break
			elseif Text == "/" then -- Test for comments
				if Line[Char+1] == "/" then -- Single line comment (//)
					ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
					break
				elseif Line[Char+1] == "*" then -- Multi line comment (/*)
					MultilineComment = true
					ValidLines[#ValidLines+1] = { { Row, Char }, { Row, #Line + 1 } }
				end
			end
		end
				
		Char = 0
		Row = Row + 1
	end
	
	self.dEditor:FoldAll( LinesToFold )
	
	return function( nLine, nStart ) 
		for i = 1, #ValidLines do
			local tStart, tEnd = ValidLines[i][1], ValidLines[i][2]
			
			if tStart[1] < nLine and tEnd[1] > nLine then 
				return false 
			end 
			
			if tStart[1] == tEnd[1] then
				if tStart[1] == nLine then 
			 		if tStart[2] <= nStart and tEnd[2] >= nStart then 
			 			return false 
			 		end 
			 	end 
			else 
			 	if tStart[1] == nLine then 
			 		if tStart[2] <= nStart then 
			 			return false 
			 		end 
			 	elseif tEnd[1] == nLine then 
			 		if tEnd[2] >= nStart then 
			 			return false 
			 		end 
			 	end 
			end 
		end
		
		return true 
	end, ValidLines
end

// { FoldLevel, Folded, FoldOverride }
function Syntax:MakeFoldData( nExit )
	local LinesToFold = self.dEditor:ExpandAll( )
	local ValidLines = self:FindValidLines( ) 
	local nLevel = 0
	
	for nLine = 1, #self.dEditor.tRows do
		if nLine == nExit then break end 
		local text = self.dEditor.tRows[nLine]
		self.dEditor.tFoldData[nLine] = self.dEditor.tFoldData[nLine] or { nLevel, false, false }
		
		local nElse, nBracket = 0, 0
		string.gsub( text, "()([a-z{}]+)", function( nStart, sType )
			if not ValidLines( nLine, nStart ) then return end 
			if sType == "do" then 
				nLevel = nLevel + 1
			elseif sType == "then" then 
				nLevel = nLevel + 1
			elseif sType == "repeat" then 
				nLevel = nLevel + 1
			elseif sType == "function" then 
				nLevel = nLevel + 1
			elseif sType == "{" then 
				nLevel = nLevel + 1
				nBracket = nBracket + 1
			elseif sType == "elseif" then 
				nLevel = nLevel - 1
			elseif sType == "else" then 
				-- nLevel = nLevel - 1
				nElse = nElse + 1
			elseif sType == "end" then 
				nLevel = nLevel - 1
				if nElse > 0 then 
					nElse = nElse - 1
				end 
			elseif sType == "untill" then 
				nLevel = nLevel - 1
			elseif sType == "}" then 
				nLevel = nLevel - 1
				if nBracket > 0 then 
					nBracket = nBracket - 1
				end 
			end 
		end )
		
		
		if (nBracket > 0 or nElse > 0) and self.dEditor.tFoldData[nLine][1] == nLevel then
			self.dEditor.tFoldData[nLine][3] = true 
		else 
			self.dEditor.tFoldData[nLine][3] = false 
		end
		
		nLevel = nLevel < 0 and 0 or nLevel
		
		if self.dEditor.tFoldData[nLine][1] ~= nLevel then 
			self.dEditor.tFoldData[nLine][1] = nLevel 
		end 
	end
	
	self.dEditor.tFoldData[#self.dEditor.tRows+1] = { 0, false, false }
	
	self.dEditor:FoldAll( LinesToFold )
end 

local ParamPairs = {
	["{"] = { "{", "}", true }, 
	["["] = { "[", "]", true }, 
	["("] = { "(", ")", true }, 
	
	["}"] = { "}", "{", false }, 
	["]"] = { "]", "[", false }, 
	[")"] = { ")", "(", false }, 
}

function Syntax:FindMatchingParam( nRow, nChar )
	if not self.dEditor.tRows[nRow] then return false end 
	local LinesToFold = self.dEditor:ExpandAll( )
	local Param, EnterParam, ExitParam = ParamPairs[self.dEditor.tRows[nRow][nChar]] 
	
	if ParamPairs[self.dEditor.tRows[nRow][nChar-1]] and not ParamPairs[self.dEditor.tRows[nRow][nChar-1]][3] then 
		nChar = nChar - 1
		Param = ParamPairs[self.dEditor.tRows[nRow][nChar]] 
	end 
	
	if not Param then 
		nChar = nChar - 1
		Param = ParamPairs[self.dEditor.tRows[nRow][nChar]] 
	end 
	
	if not Param then
		self.dEditor:FoldAll( LinesToFold ) 
		return false 
	end 
	
	EnterParam = Param[1]
	ExitParam = Param[2]
	
	local line, pos, level = nRow, nChar, 0 
	local ValidLines = self:FindValidLines( ) 
	
	if not ValidLines( line, pos ) then 
		self.dEditor:FoldAll( LinesToFold )
		return false 
	end 
	
	if Param[3] then -- Look forward 
		while line <= #self.dEditor.tRows do 
			local Line = self.dEditor.tRows[line]
			while pos < #Line do 
				pos = pos + 1
				local Text = Line[pos]
				
				if not ValidLines( line, pos ) then continue end 
				
				if Text == EnterParam then 
					level = level + 1 
				elseif Text == ExitParam then 
					if level > 0 then 
						level = level - 1 
					else 
						self.dEditor:FoldAll( LinesToFold )
						return { Vector2( nRow, nChar ), Vector2( line, pos ) }
					end 
				end 
			end 
			pos = 0 
			line = line + 1 
		end 
	else -- Look backwards 
		while line > 0 do 
			local Line = self.dEditor.tRows[line]
			while pos > 0 do 
				pos = pos - 1 
				
				local Text = Line[pos] 
				
				if not ValidLines( line, pos ) then continue end 
				
				if Text == EnterParam then 
					level = level + 1 
				elseif Text == ExitParam then 
					if level > 0 then 
						level = level - 1 
					else 
						self.dEditor:FoldAll( LinesToFold )
						return { Vector2( line, pos ), Vector2( nRow, nChar ) }
					end 
				end 
			end 
			line = line - 1 
			pos = #(self.dEditor.tRows[line] or "") + 1
		end 
	end 
	
	self.dEditor:FoldAll( LinesToFold )
	
	return false 
end 

/*============================================================================================================================================
	Syntax highlighting
============================================================================================================================================*/

/*---------------------------------------------------------------------------
Colors
---------------------------------------------------------------------------*/
local colors = { 
	["comment"]      = Color( 128, 128, 128 ), 
	["function"]     = Color(  80, 160, 240 ), 
	["library"]      = Color(  80, 160, 240 ), 
	["keyword"]      = Color(   0, 120, 240 ), 
	["number"]       = Color(   0, 200,   0 ), 
	["operator"]     = Color( 240,   0,   0 ), 
	["string"]       = Color( 188, 188, 188 ), 
	["variable"]     = Color(   0, 180,  80 ),  
	["metamethod"]   = Color(   0, 200, 255 ),
}

-- fallback for nonexistant entries: 
setmetatable( colors, { __index = function( tbl, index ) return Color( 255, 255, 255 ) end } ) 
Syntax.Colors = colors

Golem.Syntax:RegisterColors( Syntax.sName, colors )

/*---------------------------------------------------------------------------
Keywords
---------------------------------------------------------------------------*/
local keywords = {
	["and"] 		= true,
	["break"] 		= true,
	["continue"] 	= true,
	["do"] 			= true,
	["else"] 		= true,
	["elseif"] 		= true,
	["end"] 		= true,
	["false"] 		= true,
	["for"] 		= true,
	["function"] 	= true,
	["if"] 			= true,
	["in"] 			= true,
	["local"] 		= true,
	["nil"] 		= true,
	["not"] 		= true,
	["or"] 			= true,
	["repeat"] 		= true,
	["return"] 		= true,
	["then"] 		= true,
	["true"] 		= true,
	["until"] 		= true,
	["while"] 		= true,
}

/*---------------------------------------------------------------------------
Syntaxer
---------------------------------------------------------------------------*/
local Syntaxer = { }
Syntax.Syntaxer = Syntaxer

function Syntaxer:NextCharacter( )
	if not self.sChar then return end

	self.sTokenData = self.sTokenData .. self.sChar
	self.nPosition = self.nPosition + 1

	if self.nPosition <= #self.sLine then
		self.sChar = self.sLine[self.nPosition]
	else
		self.sChar = nil
	end
end

function Syntaxer:NextPattern( sPattern, bSkip )
	if not self.sChar then return false end
	local startpos, endpos, text = string_find( self.sLine, sPattern, self.nPosition  )
	
	if startpos ~= self.nPosition then return false end 
	text = text or string_sub( self.sLine, startpos, endpos ) 
	
	if not bSkip then 
		self.sTokenData = self.sTokenData .. text
	end 
	
	self.nPosition = endpos + 1
	if self.nPosition <= #self.sLine then
		self.sChar = self.sLine[self.nPosition]
	else
		self.sChar = nil
	end
	
	return bSkip and text or true 
end

function Syntaxer:AddToken( sTokenName, sTokenData )
	local color = colors[sTokenName]
	if not sTokenData then 
		sTokenData = self.sTokenData 
		self.sTokenData = ""
	end 
		
	if self.tLastColor and color == self.tLastColor[2] then
		self.tLastColor[1] = self.tLastColor[1] .. sTokenData
	else
		self.tOutput[self.nRow][#self.tOutput[self.nRow] + 1] = { sTokenData, color }
		self.tLastColor = self.tOutput[self.nRow][#self.tOutput[self.nRow]]
	end
end


function Syntaxer:SkipSpaces( )
	self:NextPattern( " *" )
	self:AddToken( "operator" )
end


function Syntaxer:ResetTokenizer( )
	self.nPosition = 0
	self.sChar = ""
	self.sTokenData = ""
	self.bBlockComment = nil
	self.bMultilineString = nil
	
	local tmp = self.dEditor:ExpandAll( )
	self.tRows = table.Copy( self.Editor.tRows )
	self.dEditor:FoldAll( tmp )
	
	self:Parse( ) 
end

function Syntaxer:Parse( )
	self.tOutput, self.tLastColor = { }, nil 
	local tRows = self.dEditor.tRows
	
	for i = 1, #tRows do
		self.sLine = tRows[i]
		self.nRow = i 
		self.tLastColor = nil 
		self.tOutput[i] = { }
		
		self.nPosition = 0
		self.sChar = ""
		self.sTokenData = ""
		
		self:NextCharacter( )
		
		if self.bBlockComment then 
			local sType = type( self.bBlockComment ) 
			if sType == "number" then -- End comment (]])
				if self:NextPattern( ".-%]" .. string_rep( "=", self.bBlockComment ) .. "%]$" ) then 
					self.bBlockComment = nil 
				else
					self:NextPattern( ".*" )
				end 
				
				self:NextPattern( "comment" ) 
			elseif sType == "boolean" and bBlockComment then -- End comment (*/)
				if self:NextPattern( ".-%*/" ) then
					self.bBlockComment = nil
				else
					self:NextPattern( ".*" )
				end
				
				self:NextPattern( "comment" ) 
			end 
		elseif self.bMultilineString then 
			local sType = type( self.bMultilineString ) 
			if sType == "number" then -- End string (]])
				if self:NextPattern( ".-%]" .. string_rep( "=", self.bMultilineString ) .. "%]$" ) then 
					self.bMultilineString = nil 
				else
					self:NextPattern( ".*" )
				end 
				
				self:NextPattern( "string" ) 
			elseif sType == "string" then -- End string ("')
				while self.sChar do 
					if self.sChar == self.bMultilineString then
						self.bMultilineString = nil
						self:NextCharacter( )
						break
					end
					if self.sChar == "\\" then self:NextCharacter( ) end
					self:NextCharacter( )
				end
				
				self:AddToken( "string" )
			end
		end 
		
		while self.sChar do 
			self:SkipSpaces( ) 
			if not self.sChar then break end 
			
			-- if self:NextPattern( "^[a-z]+" ) then 
			if self:NextPattern( "^[a-zA-Z_][_A-Za-z0-9]*" ) then 
				if keywords[self.sTokenData] then 
					self:AddToken( "keyword" )
				elseif istable(_G[self.sTokenData]) then 
					self:AddToken( "library" )
				elseif isfunction(_G[self.sTokenData]) then 
					self:AddToken( "function" )
				else 
					-- TODO: Make it highlight global/local functions and variables
					self:AddToken( "variable" )
				end 
			-- elseif self:NextPattern( "^[a-zA-Z_][_A-Za-z0-9]*" ) then 
			-- 	self:AddToken( "variable" )
			elseif self:NextPattern( "^0x[%x]+" ) then -- Hexadecimal numbers
				self:AddToken( "number" )
			elseif self:NextPattern( "^[%d][%d%.e]*" ) then -- Normal numbers
				self:AddToken( "number" )
			elseif self:NextPattern( "^%-%-%[=*%[" ) then -- Multi line comment type --[[ ]]
				self.bBlockComment = #string_match( self.sTokenData, "=" ) 
				
				if self:NextPattern( ".-%]" .. string_rep( "=", self.bBlockComment ) .. "%]$" ) then 
					self.bBlockComment = nil 
				else
					self:NextPattern( ".*" )
				end 
				
				self:AddToken( "comment" )
			elseif self:NextPattern( "^%-%-" ) then -- Single line comment type --
				self:NextPattern( ".*" ) 
				self:AddToken( "comment" )
			elseif self:NextPattern( "^%[=*%[" ) then -- Multi line string 
				self.bMultilineString = #string_match( self.sTokenData, "=" ) 
				
				if self:NextPattern( ".-%]" .. string_rep( "=", self.bMultilineString ) .. "%]$" ) then 
					self.bMultilineString = nil 
				else
					self:NextPattern( ".*" )
				end 
				
				self:AddToken( "string" )
			elseif self.sChar == '"' or self.sChar == "'" then -- Single line string
				local sType = self.sChar
				self:NextCharacter( )
				
				while self.sChar do 
					if self.sChar == sType then break end
					if self.sChar == "\\" then self:NextCharacter( ) end
					self:NextCharacter( )
				end
				
				self:NextCharacter( ) 
				self:AddToken( "string" ) 
			elseif self.sChar == "/" then 
				self:NextCharacter( ) 
				
				if self.sChar == "*" then -- Multi line comment type /*
					self.bBlockComment = true
					while self.sChar do 
						if self.sChar == "*" then 
							self:NextCharacter( ) 
							if self.sChar == "/" then 
								self:NextCharacter( ) 
								self:AddToken( "comment" ) 
								self.bBlockComment = false
								break 
							end 
						end 
						
						self:NextCharacter( ) 
					end 	
					self:AddToken( "comment" ) 
				elseif self.sChar == "/" then -- Single line comment type //
					self:NextPattern( ".*" )
					self:AddToken( "comment" )
				else 
					self:AddToken( "operator" )
				end
			end 
			
			self:NextCharacter( )
			self:AddToken( "white" ) -- Todo
		end 
	end
end

function Syntax:GetSyntax( nRow )
	if not self.Syntaxer.tOutput then self.Syntaxer:Parse() end 
	return self.Syntaxer.tOutput[nRow]
end

function Syntax:Parse( )
	self.Syntaxer:Parse( ) 
end



Golem.Syntax:Add( Syntax.sName, Syntax ) 