@tool
class_name HalfCapsuleTurret
extends Node3D

@export_range(0.0, 10.0, 0.01) var height = 0.9 : 
    set(v): height = v; generate()
@export_range(0.1, 10.0, 0.01) var radius = 0.25 : 
    set(v): radius = v; generate()
@export_range(3, 36, 1) var segments = 32 :
    set(v): segments = v; generate()
@export_range(3, 32, 1) var rings = 8 :
    set(v): rings = v; generate()
@export_range(0.0, 5.0, 0.01) var roundRadius = 0.05 :
    set(v): roundRadius = v; generate()
@export_range(2, 16, 1) var roundRings = 4 :
    set(v): roundRings = v; generate()
    
@export_range(0.1, 10.0, 0.01) var headHeight = 0.3 : 
    set(v): headHeight = v; generate()
@export_range(0.1, 5.0, 0.01) var holeRadius = 0.1 :
    set(v): holeRadius = v; generate()
    
@export var material : Material : 
    set(v): material = v; generate()

func _ready():
    
    generate()
    
func circleXY(st:SurfaceTool, r1:float, r2:float, center:Vector3, rad:float, startDeg:float, endDeg:float, steps:int, convex=false):
    
    var fullDeg = endDeg - startDeg
            
    for ring in range(steps):
    
        var a1 = deg_to_rad(startDeg+(ring+0)*fullDeg/(steps))
        var a2 = deg_to_rad(startDeg+(ring+1)*fullDeg/(steps))

        var va = center+(Vector3.RIGHT * rad).rotated(Vector3.FORWARD, a1)
        var vb = center+(Vector3.RIGHT * rad).rotated(Vector3.FORWARD, a2)
    
        if convex:
            lineXY(st, r1, r2, va, vb)
        else:    
            lineXY(st, r1, r2, vb, va)
    
func lineXY(st:SurfaceTool, r1:float, r2:float, start:Vector3, end:Vector3):
        
    var v1 = start.rotated(Vector3.UP, r1)
    var v2 = end  .rotated(Vector3.UP, r1)
    var v3 = start.rotated(Vector3.UP, r2)
    var v4 = end  .rotated(Vector3.UP, r2)
    
    if not v1.is_equal_approx(v3):
        st.add_vertex(v1)
        st.add_vertex(v2)
        st.add_vertex(v3)
    
    if not v2.is_equal_approx(v4):
        st.add_vertex(v4)
        st.add_vertex(v3)
        st.add_vertex(v2)
    
func generate():

    var st = SurfaceTool.new()
    
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    if holeRadius == null: return
    assert(roundRadius)
    if headHeight == null: return
    var headRadius = radius + 2*roundRadius
    var tipRadius  = (headRadius - holeRadius) / 2.0
    assert(headHeight)
    assert(tipRadius)
    
    for seg in segments:
        
        var s1 = deg_to_rad(seg*360.0/segments)
        var s2 = deg_to_rad(((seg+1)%segments)*360.0/segments)
    
        circleXY(st, s1, s2, Vector3(0,radius,0), radius, 0, 90, rings)
        lineXY(  st, s1, s2, Vector3(radius, radius, 0), Vector3(radius, height-radius, 0))
        circleXY(st, s1, s2, Vector3(radius+roundRadius, height-radius, 0), roundRadius, -180, -90, roundRings, true)
        circleXY(st, s1, s2, Vector3(radius+roundRadius, height-radius + 2*roundRadius, 0), roundRadius, 0, 90, roundRings)
        lineXY(  st, s1, s2, Vector3(radius+roundRadius*2, height-radius + 2*roundRadius, 0), Vector3(radius+roundRadius*2, height-radius + 2*roundRadius+headHeight, 0))

        circleXY(st, s1, s2, Vector3(headRadius-tipRadius, height-radius + 2*roundRadius+headHeight, 0), tipRadius, -180, 0, rings)
        lineXY(  st, s1, s2, Vector3(holeRadius, height-radius + 2*roundRadius+headHeight, 0), Vector3(holeRadius, radius, 0))
        circleXY(st, s1, s2, Vector3(0, radius, 0), holeRadius, 0, 90, 2, true)
    
    st.index()
    st.generate_normals()
    
    var mi = MeshInstance3D.new()
    mi.mesh = st.commit()
    #mi.material_override = material
    mi.set_surface_override_material(0, material)
    mi.transform = Transform3D.IDENTITY
    if get_child_count():
        get_child(0).queue_free()
        remove_child(get_child(0))
    self.add_child(mi)
