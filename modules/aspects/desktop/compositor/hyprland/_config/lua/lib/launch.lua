-- Return a keybinding callback; resolve the window when the key is pressed.
return function(target)
    return function()
        if target.focusClass then
            local window = hl.get_window("class:" .. target.focusClass)
            if window then
                hl.dispatch(hl.dsp.focus({ window = window }))
                return
            end
        end

        hl.exec_cmd(target.command)
    end
end
