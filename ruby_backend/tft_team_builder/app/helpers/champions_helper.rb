module ChampionsHelper
  def champion_sprite(champion, options = {})
    # 确保这里的路径是 "tft-champion/"
    sprite_sheet_path = image_path("tft-champion/#{champion.sprite_name}")

    style = [
      "background-image: url(#{sprite_sheet_path});",
      "background-position: -#{champion.sprite_x}px -#{champion.sprite_y}px;",
      "width: #{champion.sprite_w}px;",
      "height: #{champion.sprite_h}px;",
      "display: inline-block;",
      "zoom: 1.2;"
    ].join(" ")

    content_tag(:div, nil, class: options[:class], style: style, title: champion.name)
  end
end
