Name = "buku"
NamePretty = "Buku Bookmarks"
Icon = "bookmark"
Cache = true
HideFromProviderlist = false
SearchName = true

-- dofile(os.getenv("HOME") .. "/.config/elephant/shared.lua")

function GetEntries()
    local entries = {}
    -- Run buku: -p (print all), -f 3 (format: index title)
    -- We'll just read stdout
    local p = ReadShellCommand("buku -p -f 3")

    if p then
        for line in p:lines() do
            -- Clean up tabs
            line = line:gsub("\t", " ")

            -- Match ID and Title
            local id, title = line:match("^%s*(%d+)%s+(.+)")

            if id and title then
                table.insert(entries, {
                    Text = title,
                    Subtext = "ID: " .. id,
                    Value = id,
                    Actions = { default = "lua:OpenBookmark" }
                })
            end
        end
        p:close()
    end

    return entries
end

function OpenBookmark(id)
    -- buku -o <id> opens the bookmark in browser
    os.execute(string.format("buku -o %s", id))
end
