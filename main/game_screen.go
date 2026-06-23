components {
  id: "screen_proxy"
  component: "/monarch/screen_proxy.script"
  properties {
    id: "screen_id"
    value: "game"
    type: PROPERTY_TYPE_HASH
  }
}
embedded_components {
  id: "collectionproxy"
  type: "collectionproxy"
  data: "collection: \"/scenes/game/game.collection\"\n"
  ""
}
