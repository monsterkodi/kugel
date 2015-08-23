###
 0000000   000   000   0000000   000000000
000   000  000   000  000   000     000   
000 00 00  000   000  000000000     000   
000 0000   000   000  000   000     000   
 00000 00   0000000   000   000     000   
###

tools    = require './knix/tools'
Vect     = require './vect'
deg2rad  = tools.deg2rad

class Quat extends THREE.Quaternion

    @rand: () -> @euler 2*Math.random()*Math.PI, 2*Math.random()*Math.PI, 2*Math.random()*Math.PI
    @euler: (x,y,z) -> new Quat().setFromEuler new THREE.Euler(x,y,z)
    @axis: (axis,deg) -> new Quat().setFromAxisAngle axis, deg2rad(deg)
    @vecs: (a,b) -> new Quat().setFromUnitVectors a.normalized(), b.normalized()
    @posUpTarget: (pos,up,target) -> 
        upn = up.normalized()
        dir = pos.to target
        right = vec().crossVectors dir, upn
        target = vec().crossVectors upn, right 
        m = new THREE.Matrix4().lookAt vec(), target, upn
        new Quat().setFromRotationMatrix m

module.exports = Quat
