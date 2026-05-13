local api_keys = {}
local request_counts = {}
local last_reset = {}

local RATE_LIMIT = 30
local RATE_WINDOW = 60
local MAX_BURST = 10

local function get_api_key()
    local auth_header = ngx.req.get_headers()["Authorization"]
    if not auth_header then
        return nil
    end

    if string.find(auth_header, "Bearer ") then
        return string.match(auth_header, "Bearer%s+(.+)")
    end
    return nil
end

local function is_valid_key(key)
    if not key or #key < 16 then
        return false
    end

    -- Check against registered keys
    if api_keys[key] then
        return true
    end

    -- For demo/development: accept keys starting with "sk-"
    if string.match(key, "^sk%-") then
        api_keys[key] = os.time()
        return true
    end

    return false
end

local function check_rate_limit(key)
    local now = ngx.now()
    local minute = math.floor(now / RATE_WINDOW)

    if not last_reset[key] or last_reset[key] ~= minute then
        request_counts[key] = 0
        last_reset[key] = minute
    end

    request_counts[key] = (request_counts[key] or 0) + 1

    if request_counts[key] > RATE_LIMIT then
        return false
    end

    return true
end

local function deny_request(reason, status_code)
    ngx.status = status_code
    ngx.header["Content-Type"] = "application/json"
    ngx.say('{"error":{"message":"' .. reason .. '","type":"authentication_error","code":"rate_limit_exceeded"}}')
    ngx.exit(ngx.OK)
end

local function validate_request()
    local key = get_api_key()

    if not key then
        return deny_request("Missing API key. Include: Authorization: Bearer <your-api-key>", 401)
    end

    if not is_valid_key(key) then
        return deny_request("Invalid API key", 401)
    end

    if not check_rate_limit(key) then
        return deny_request("Rate limit exceeded. Max " .. RATE_LIMIT .. " requests per minute.", 429)
    end

    -- Add rate limit headers
    local remaining = RATE_LIMIT - (request_counts[key] or 0)
    ngx.header["X-RateLimit-Remaining"] = remaining
    ngx.header["X-RateLimit-Limit"] = RATE_LIMIT
end

validate_request()