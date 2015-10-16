local Mixin = {}


function Mixin:set_error(msg, field)
    self.errors[field or '__ERROR__'] = msg
end

return Mixin
