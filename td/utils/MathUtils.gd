extends Node

func max_length(v, l:float):
    
    if v.length() > l:
        return v.normalized()*l
    return v
