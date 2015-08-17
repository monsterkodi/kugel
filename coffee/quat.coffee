
class Quat extends THREE.Quaternion

    @rand: () -> @euler 2*Math.random()*Math.PI, 2*Math.random()*Math.PI, 2*Math.random()*Math.PI
    @euler: (x,y,z) ->
        new Quat().setFromEuler new THREE.Euler(x,y,z)

module.exports = Quat
