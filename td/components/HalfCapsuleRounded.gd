@tool
class_name HalfCapsuleRounded
extends Node3D

@export_range(0.0, 10.0, 0.1) var height = 1.0 : 
    set(v): height = v; generate()
@export_range(0.0, 10.0, 0.1) var radius = 0.5 : 
    set(v): radius = v; generate()
@export_range(3, 36, 1) var segments = 32 :
    set(v): segments = v; generate()
@export_range(3, 32, 1) var rings = 8 :
    set(v): rings = v; generate()
@export_range(0.0, 5.0, 0.01) var roundRadius = 0.1 :
    set(v): roundRadius = v; generate()
@export_range(2, 16, 1) var roundRings = 4 :
    set(v): roundRings = v; generate()
@export var material : Material : 
    set(v): material = v; generate()

func _ready():
    
    generate()
    
func generate():

    var st = SurfaceTool.new()
    
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var cylb = roundRadius * Vector3.UP
    var cylt = (height-radius)*Vector3.UP
    var tip  = height*Vector3.UP
    
    for seg in segments:
        var s1 = deg_to_rad(seg*360.0/segments)
        var s2 = deg_to_rad(((seg+1)%segments)*360.0/segments)
        var v = Vector3.RIGHT * radius
        var v1 = v.rotated(Vector3.UP, s1)
        var v2 = v1 + cylt
        var v3 = v.rotated(Vector3.UP, s2)
        var v4 = v3 + cylt
        
        for ring in range(roundRings):
            var a1 = -deg_to_rad(ring*90.0/(roundRings-1))
            var a2 = -deg_to_rad((ring+1)*90.0/(roundRings-1))
        
            var w1 = v + Vector3.RIGHT * roundRadius - (Vector3.RIGHT.rotated(Vector3.FORWARD, a1)) * roundRadius + cylb
            var w2 = v + Vector3.RIGHT * roundRadius - (Vector3.RIGHT.rotated(Vector3.FORWARD, a2)) * roundRadius + cylb
            
            if ring == roundRings-1:
                w2.y = w1.y
                
            var v5 = w1.rotated(Vector3.UP, s1)
            var v6 = w2.rotated(Vector3.UP, s1)
            var v7 = w1.rotated(Vector3.UP, s2)
            var v8 = w2.rotated(Vector3.UP, s2)
            
            st.add_vertex(v7)
            st.add_vertex(v6)
            st.add_vertex(v5)

            st.add_vertex(v6)
            st.add_vertex(v7)
            st.add_vertex(v8)
        
        v1 += cylb
        v3 += cylb
        st.add_vertex(v1)
        st.add_vertex(v2)
        st.add_vertex(v3)

        st.add_vertex(v4)
        st.add_vertex(v3)
        st.add_vertex(v2)
        
        for ring in range(rings):
            var a1 = -deg_to_rad(ring*90.0/(rings))
            var a2 = -deg_to_rad((ring+1)*90.0/(rings))
            
            var w1 = Vector3.RIGHT.rotated(Vector3.FORWARD, a1) * radius + cylt
            var w2 = Vector3.RIGHT.rotated(Vector3.FORWARD, a2) * radius + cylt
            var v5 = w1.rotated(Vector3.UP, s1)
            var v6 = w2.rotated(Vector3.UP, s1)
            var v7 = w1.rotated(Vector3.UP, s2)
            var v8 = w2.rotated(Vector3.UP, s2)
            
            if ring == rings-1:
                v6 = tip
            
            st.add_vertex(v5)
            st.add_vertex(v6)
            st.add_vertex(v7)

            if ring < rings-1:
                st.add_vertex(v8)
                st.add_vertex(v7)
                st.add_vertex(v6)
    
    st.index()
    st.generate_normals()
    
    var mi = MeshInstance3D.new()
    mi.mesh = st.commit()
    #mi.material_override = material
    mi.set_surface_override_material(0, material)
    mi.transform = Transform3D.IDENTITY
    if get_child_count():
        remove_child(get_child(0))
    self.add_child(mi)
