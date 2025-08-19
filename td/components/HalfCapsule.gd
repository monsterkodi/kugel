class_name HalfCapsule
extends Node3D

@export_range(0.0, 10.0, 0.1) var height = 1.0
@export_range(0.0, 10.0, 0.1) var radius = 0.5
@export_range(3, 36, 1) var segments = 32
@export_range(3, 32, 1) var rings = 16
@export var material : Material

func _enter_tree() -> void:
    
    generate()
    
func generate():

    var st = SurfaceTool.new()
    
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var cylh = (height-radius)*Vector3.UP
    var tip  = height*Vector3.UP
    
    for seg in segments:
        var s1 = deg_to_rad(seg*360.0/segments)
        var s2 = deg_to_rad(((seg+1)%segments)*360.0/segments)
        var v = Vector3.RIGHT * radius
        var v1 = v.rotated(Vector3.UP, s1)
        var v2 = v1 + cylh
        var v3 = v.rotated(Vector3.UP, s2)
        var v4 = v3 + cylh
        st.add_vertex(v1)
        st.add_vertex(v2)
        st.add_vertex(v3)

        st.add_vertex(v4)
        st.add_vertex(v3)
        st.add_vertex(v2)
        
        for ring in rings:
            var a1 = -deg_to_rad(ring*90.0/(rings))
            var a2 = -deg_to_rad((ring+1)*90.0/(rings))
            
            var w1 = Vector3.RIGHT.rotated(Vector3.FORWARD, a1) * radius + cylh
            var w2 = Vector3.RIGHT.rotated(Vector3.FORWARD, a2) * radius + cylh
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
    mi.material_override = material
    mi.transform = Transform3D.IDENTITY
    self.add_child(mi)
