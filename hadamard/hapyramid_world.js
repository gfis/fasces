/**
  hapyramid_world.js - Overall geometry of the Hadamard pyramid
	@(#) $Id$
	2025-08-09: *VF=44
	2025-08-08, Georg Fischer: extracted from hapyramid_geometry.js
*/
			function world( scene, myfont ) {
				// Default Vars
				var pi2 = Math.PI / 2;
				var pi4 = Math.PI / 4;
				var pi8 = Math.PI / 8;
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / 5);
				var corner = 4; // number of corners of the blocks
				var thick  = parseInt(size5 / 1); // thickness of the blocks
				var shift = (size5 - thick) * 0.5;
				var vec = vec_pyramid;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];
				var opacis = [];
				for ( i = 0; i < vec.length; i ++ ) {
					opacis[i] =  parseInt(vec[i] / 1000000) % 100;
					var digz5 =  parseInt(vec[i] /   10000) % 100;
					var digx5 =  parseInt(vec[i] /     100) % 100;
					var digy5 =  parseInt(vec[i] /       1) % 100;
					// digits run from 0 to 99 or -50 to +49
					var x = center.x + (digx5 - displ) * size5;
					var y = center.y + (digy5 - displ) * size5;
					var z = center.z + (digz5 - displ) * size5;
					points.push(new THREE.Vector3(x, y, z));
					if (false) { // with annotation: node values
						var geometry = new THREE.TextGeometry( Math.floor(vec[i] / 100) % 10000,
							{ font: myfont
							, size: 6
							, height: 1
							, curveSegments: 8
							} );
						var mesh = new THREE.Mesh( geometry, materials );
						mesh.position.x = x;
						mesh.position.y = y;
						mesh.position.z = z;
						var group = new THREE.Group();
						group.add( mesh );
						scene.add( group );
					} // node values
				} // for i
				for ( i = 0; i < points.length; i ++ ) {
					var geometry = new THREE.BoxGeometry( thick, thick, thick );
					var diff = vec[i + 1] - vec[i]; // either +-1, +-10 or +-100
					var adiff = diff;
					if (adiff < 0) {
						adiff = - adiff;
					}
					geometry.translate
						( points[i].x
						, points[i].y
						, points[i].z);
					if (false) { // with edges
						var edges = new THREE.EdgesGeometry( geometry );
						var line = new THREE.LineSegments( edges, new THREE.LineBasicMaterial( { color: 0xffffff } ) );
						scene.add( line );
					}
					// color gradient
					var color3 = new THREE.Color( 0xffffff );
					//color3.setHSL( i * 0.8 / points.length + 0.1, 1.0, 0.5 ); 
					var opac =  i / points.length; // 0.5
					opac = opacis[i] * 6 / 100;
					var material = new THREE.MeshBasicMaterial(
						{ color: color3
						, alphaMap: 0x000000
						, opacity: opac
						, transparent: true
					//	, wireframe: true
						} ); // 0x0000ff} );
					var mesh = new THREE.Mesh( geometry, material );
					scene.add( mesh );
				} // for i
			} // world
