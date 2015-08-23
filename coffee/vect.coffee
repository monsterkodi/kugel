###
000   000  00000000   0000000  000000000
000   000  000       000          000   
 000 000   0000000   000          000   
   000     000       000          000   
    0      00000000   0000000     000   
###

tools    = require './knix/tools'
deg2rad  = tools.deg2rad

class Vect extends THREE.Vector3

    @new: (x=0, y=0, z=0) -> new Vect(x,y,z)
    @X: @new 1,0,0
    @Y: @new 0,1,0
    @Z: @new 0,0,1 

THREE.Vector3.prototype.normalized = () -> (new THREE.Vector3 @x, @y, @z).normalize()
THREE.Vector3.prototype.to = (other) -> other.clone().sub(@).normalize()

THREE.Vector2.prototype.normalized = () -> (new THREE.Vector2 @x, @y).normalize()
    
THREE.Object3D.prototype.setQuatHeight = (quat, dist=100) ->
    @quaternion.copy quat
    @position.copy (new THREE.Vector3(0,0,dist)).applyQuaternion(quat)    
    
module.exports = Vect
