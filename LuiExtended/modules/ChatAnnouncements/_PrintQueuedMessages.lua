-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local eventManager = GetEventManager()

--- @class (partial) LuiExtended
local LUIE = LUIE
local printToChat = LUIE.PrintToChat

-- ChatAnnouncements namespace
--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements
local moduleName = ChatAnnouncements.moduleName


function ChatAnnouncements.PrintQueuedMessages()
    -- Resolve notification messages first
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "NOTIFICATION" then
            local isSystem
            if ChatAnnouncements.QueuedMessages[i].isSystem then
                isSystem = true
            else
                isSystem = false
            end
            printToChat(ChatAnnouncements.QueuedMessages[i].message, isSystem)
        end
    end

    -- Resolve quest POI added
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "QUEST_POI" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Next display Quest/Objective Completion and Experience
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and (ChatAnnouncements.QueuedMessages[i].messageType == "QUEST" or ChatAnnouncements.QueuedMessages[i].messageType == "EXPERIENCE") then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Level Up Notifications
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "EXPERIENCE_LEVEL" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Skill Gain
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "SKILL_GAIN" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Skill Morph
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "SKILL_MORPH" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Skill Line
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "SKILL_LINE" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Skill
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "SKILL" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Postage
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "CURRENCY_POSTAGE" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Quest Items (Remove)
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "QUEST_LOOT_REMOVE" then
            local itemId = ChatAnnouncements.QueuedMessages[i].itemId
            if not ChatAnnouncements.questItemAdded[itemId] == true then
                printToChat(ChatAnnouncements.QueuedMessages[i].message)
            end
        end
    end

    -- Loot (Container)
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "CONTAINER" then
            ChatAnnouncements.ResolveItemMessage(ChatAnnouncements.QueuedMessages[i].message, ChatAnnouncements.QueuedMessages[i].formattedRecipient, ChatAnnouncements.QueuedMessages[i].color, ChatAnnouncements.QueuedMessages[i].logPrefix, ChatAnnouncements.QueuedMessages[i].totalString, ChatAnnouncements.QueuedMessages[i].groupLoot)
        end
    end

    -- Currency
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "CURRENCY" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Quest Items (ADD)
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "QUEST_LOOT_ADD" then
            local itemId = ChatAnnouncements.QueuedMessages[i].itemId
            if not ChatAnnouncements.questItemRemoved[itemId] == true then
                printToChat(ChatAnnouncements.QueuedMessages[i].message)
            end
        end
    end

    -- Loot
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "LOOT" then
            ChatAnnouncements.ResolveItemMessage(ChatAnnouncements.QueuedMessages[i].message, ChatAnnouncements.QueuedMessages[i].formattedRecipient, ChatAnnouncements.QueuedMessages[i].color, ChatAnnouncements.QueuedMessages[i].logPrefix, ChatAnnouncements.QueuedMessages[i].totalString, ChatAnnouncements.QueuedMessages[i].groupLoot)
        end
    end

    -- Resolve achievement update messages second to last
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "ANTIQUITY" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Collectible
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "COLLECTIBLE" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Resolve achievement update messages second to last
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "ACHIEVEMENT" then
            printToChat(ChatAnnouncements.QueuedMessages[i].message)
        end
    end

    -- Display the rest
    for i = 1, #ChatAnnouncements.QueuedMessages do
        if ChatAnnouncements.QueuedMessages[i] and ChatAnnouncements.QueuedMessages[i].message ~= "" and ChatAnnouncements.QueuedMessages[i].messageType == "MESSAGE" then
            local isSystem
            if ChatAnnouncements.QueuedMessages[i].isSystem then
                isSystem = true
            else
                isSystem = false
            end
            printToChat(ChatAnnouncements.QueuedMessages[i].message, isSystem)
        end
    end

    -- Clear Messages and Unregister Print Event
    ChatAnnouncements.QueuedMessages = {}
    ChatAnnouncements.QueuedMessagesCounter = 1
    eventManager:UnregisterForUpdate(moduleName .. "Printer")
end
