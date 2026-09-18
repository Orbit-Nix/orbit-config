# OrbitOS
function mkcd --description "mkdir -p and cd into it"
    mkdir -p -- $argv; and cd -- $argv[-1]
end
