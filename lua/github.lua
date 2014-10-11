-- load packages
cjson = require "cjson"
str = require "resty.string"

-- get POST body and headers
local body = ngx.req.get_body_data()
local h = ngx.req.get_headers()

local event_name = h['X-GitHub-Event']
local guid = h['X-GitHub-Delivery']
local signature = h['X-Hub-Signature']

-- set response headers
ngx.header['Content-Type'] = "application/json"

-- check if request has POST body
if body then
  -- verify request with SHA1 signature
  --local digest = ngx.hmac_sha1("test", ngx.var.request_body)
  --local sig = "sha1="..str.to_hex(digest)
  --if sig ~= signature then
  --  ngx.log(ngx.ERR, "INVALID SIGNATURE", sig, signature)
  --  ngx.exit(ngx.HTTP_FORBIDDEN)
  --end

  -- decode POST body
  local data = cjson.decode(body)
  -- ISO time string
  local time = os.date("!%Y-%m-%dT%TZ", ngx.now())

  -- json response object
  local response = {}

  -- step 1: identify is sender is available
  if data.sender then
    -- set logging variable
    ngx.var.json = cjson.encode({
      event = event_name,
      guid = guid,
      sender_id = data.sender.id,
      sender_name = data.sender.login,
      repo = data.repository.name
    })

    -- query Github API for user data
    -- data.sender.url is the user endpoint and returns e.g. email, full name, ...
    local res = ngx.location.capture("/github/api", {
      method = ngx.HTTP_GET, args={uri=data.sender.url}
    })
    local user = cjson.decode(res.body)

    -- send to crate
    -- create table github_events (time timestamp, event string, username string, name string, info object(dynamic));
    local stmt = {
       stmt = "insert into github_events (time, event, username, name, info) values (?, ?, ?, ?, ?)",
       args = { ngx.now(), event_name, user.login, user.name, user }
    }

    local res = ngx.location.capture("/crate", {
        method = ngx.HTTP_GET, body=cjson.encode(stmt)
    })
    response.crate = cjson.decode(res.body)
    if res.status == 200 then
       response.success = true
    else
       response.success = false
    end

  end

  -- return JSON response
  ngx.say(cjson.encode(response))

else
  ngx.say('{"error": true}')
end
