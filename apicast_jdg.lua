local apicast = require('apicast').new()
local _M = { _VERSION = '3.0.0', _NAME = 'APIcast with CORS' }
local mt = { __index = setmetatable(_M, { __index = apicast }) }
local http_ng = require "resty.http_ng"
local env = require('resty.env')

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return v
    end
    return string.gsub(v,'"', '' )
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return table.val_to_str( k )
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        --table.key_to_str( k ) .. ":" .. table.val_to_str( v ) )
         k .. ":" .. table.val_to_str( v ) )
    end
  end
  return table.concat( result, "," )
end
function _M.new()
  return setmetatable({}, mt)
end

function getKey(orig_uri,host,method)
     local new_req_uri, n, err = ngx.re.gsub(orig_uri, [[\buser_key=[^&]*&?]],"", "jo")
    -- ngx.log(ngx.INFO,'NEW_REQ_URI: ',new_req_uri)
     if string.sub(new_req_uri,-1) =='?' then
        new_req_uri=string.sub(new_req_uri, 1,( #new_req_uri - 1 ))
     end
    local key = method..'_'..host..new_req_uri
return ngx.escape_uri(key)
end

function storeJDG(premature,jdg_key,data)
    local http_client = http_ng.new()
    http_client.post('http://'..env.get('APICAST_JDG_URL')..'/rest/default/'..jdg_key,  data,{headers= {['Content-Type']='application/text', ['timeToLiveSeconds']=10}})
end

function _M:body_filter()

    local resp = ngx.arg[1]
    if resp ~= "" and ngx.var.request_method == "GET" then
      if ngx.ctx.jdghit == 0 then
           local jdg_key= getKey(ngx.var.request_uri,ngx.var.http_host,ngx.var.request_method )
           ngx.log(ngx.INFO,'JDG_MISS: ', jdg_key)
           local headers = table.tostring(ngx.resp.get_headers(0,true)):gsub("\"","")
           local respData = headers.."\n"..resp
           ngx.timer.at(0,storeJDG,jdg_key,respData)
         end
    end
    return apicast:body_filter()
end
function _M:balancer()
    if ngx.ctx.jdghit == 1 then
        ngx.status = 200
        return ngx.exit(ngx.status)
    end
    return apicast:balancer()
end
 
 function _M:access()
    if ngx.var.request_method == "GET" then
        local jdg_key= getKey(ngx.var.request_uri,ngx.var.http_host,ngx.var.request_method )
        local http_client = http_ng.new()
        local res = http_client.get('http://'..env.get('APICAST_JDG_URL')..'/rest/default/'..jdg_key)
        if res.status == 200 then
            ngx.log(ngx.INFO,'JDG_HIT, key: ',jdg_key)
            ngx.status = 200
            local separatorIndex = res.body:find("\n")
            local headers = string.sub(res.body,0,separatorIndex-1)
            local body = string.sub(res.body,separatorIndex+1)
            for header in (headers..","):gmatch("(.-)"..",") do
                local sepIndex = header:find(":")
                ngx.header[string.sub(header,0,sepIndex-1)] = string.sub(header,sepIndex+1)
            end
            ngx.header["JDG"] = "true"
            ngx.ctx.jdghit= 1
            ngx.say(body)
        else
            ngx.ctx.jdghit= 0
        end
    end
  return apicast:access()
  end
 return _M
