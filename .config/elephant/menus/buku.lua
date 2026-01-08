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
    local handle = io.popen("buku -p -f 3")
    if not handle then return entries end

    if handle then
        for line in handle:lines() do
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
        handle:close()
    end

    return entries
end

function OpenBookmark(id)
    -- buku -o <id> opens the bookmark in browser
    os.execute(string.format("buku -o %s", id))
end
