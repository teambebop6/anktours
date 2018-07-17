maskedKeys = ['MAILTO', 'pass', 'user', 'SESSION_SECRET', 'ADMIN_PASSWORD', 'SMTP_PW']

hide = (key) ->
  unmasked = ""
  if key.length > 4
    unmasked = key.substr(-2)
  else if key.length > 2
    unmasked = key.substr(-2)
  
  return "***" + unmasked

printMasked = (obj, indent="  ") -> 
  Object.keys(obj).forEach (key) ->
    value = if maskedKeys.indexOf(key) > -1 then hide(obj[key]) else obj[key];
    if typeof(value) == "object"
      console.log(indent+key + ": {");
      printMasked(value, indent+"  ");
      console.log(indent+"}");
    else
      console.log(indent+key + ": " + value + ", ");

module.exports = printMasked
