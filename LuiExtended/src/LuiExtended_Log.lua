-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class NOP
--- @field Debug fun(self: NOP, message: string, ...: any)
--- @field Info fun(self: NOP, message: string, ...: any)
--- @field Warn fun(self: NOP, message: string, ...: any)
--- @field Error fun(self: NOP, message: string, ...: any)
--- @field Verbose fun(self: NOP, message: string, ...: any)
local NOP = {}

--- Debug logger function that does nothing
--- @param message string The message to log
--- @param ... any Additional values to format into message
function NOP:Debug(message, ...)
    df(message, ...)
end

--- Info logger function that does nothing
--- @param message string The message to log
--- @param ... any Additional values to format into message
function NOP:Info(message, ...)
    df(message, ...)
end

--- Warning logger function that does nothing
--- @param message string The message to log
--- @param ... any Additional values to format into message
function NOP:Warn(message, ...)
    df(message, ...)
end

--- Error logger function that does nothing
--- @param message string The message to log
--- @param ... any Additional values to format into message
function NOP:Error(message, ...)
    df(message, ...)
end

--- Verbose logger function that does nothing
--- @param message string The message to log
--- @param ... any Additional values to format into message
function NOP:Verbose(message, ...)
    df(message, ...)
end

local string_format = string.format

-- Default log settings
LUIE.log_to_chat = false
LUIE.log_stack_traces = true

--- Retrieves the logger object
--- @return table|NOP logger The logger object
function LUIE.Logger()
    local self = LUIE
    if not self.logger then
        if LibDebugLogger then
            self.logger = LibDebugLogger.Create(self.name)
            self.logger:SetLogTracesOverride(LUIE.log_stack_traces)
        end
        if not self.logger then
            self.logger = NOP
        end
    end
    return self.logger
end

local LUIE_LOGGER = LUIE.Logger()

--- Logs a message with a specified color
--- @param color string The color code for the log message
--- @param ... any Variable number of arguments to be formatted and logged
function LUIE.Log(color, ...)
    if LUIE.log_to_chat then
        local message = LUIE.name .. ": "
        if select("#", ...) > 0 then
            message = message .. string_format(...)
        end
        CHAT_ROUTER:AddSystemMessage("|c" .. color .. message .. "|r")
    end
end

--- Logs a debug message
--- @param message string The message to log
--- @param ... any Additional values to format into message
function LUIE.Debug(message, ...)
    LUIE.Log("666666", ...)
    LUIE_LOGGER:Debug(message, ...)
end

--- Logs an info message
--- @param message string The message to log
--- @param ... any Additional values to format into message
function LUIE.Info(message, ...)
    LUIE.Log("999999", ...)
    LUIE_LOGGER:Info(message, ...)
end

--- Logs a warning message
--- @param message string The message to log
--- @param ... any Additional values to format into message
function LUIE.Warn(message, ...)
    LUIE.Log("FF8800", ...)
    LUIE_LOGGER:Warn(message, ...)
end

--- Logs an error message
--- @param message string The message to log
--- @param ... any Additional values to format into message
function LUIE.Error(message, ...)
    LUIE.Log("FF6666", ...)
    LUIE_LOGGER:Error(message, ...)
end

--- Logs a verbose message
--- @param message string The message to log
--- @param ... any Additional values to format into message
function LUIE.Verbose(message, ...)
    LUIE.Log("777575", ...)
    LUIE_LOGGER:Verbose(message, ...)
end
