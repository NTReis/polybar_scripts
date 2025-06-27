[module/spotify]
type = custom/script
exec = bash -c 'playerctl --player=spotify status &>/dev/null && echo -n "%{T1}%{T-} $(playerctl --player=spotify metadata --format "{{ artist }} - {{ title }}")" || echo -n ""'
interval = 1.0
click-left = playerctl --player=spotify play-pause&
click-right = playerctl --player=spotify next
