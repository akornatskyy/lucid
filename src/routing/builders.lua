return {
    require('routing.routes.plain').new,
    require('routing.routes.choice').new,
    require('routing.routes.curly').new,
    require('routing.routes.pattern').new
}
