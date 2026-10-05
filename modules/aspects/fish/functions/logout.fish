function logout
    loginctl terminate-session $XDG_SESSION_ID
end
