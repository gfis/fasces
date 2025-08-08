/**
  hapyramid_geometry.js - Geometry of Hadamard pyramid
	@(#) $Id$
	2025-08-08: copied from web/threejs/Meander-BoxGeometry.js
	2017-09-17, Georg Fischer: with THREE.CylinderGeometry
*/
			function world( scene, myfont ) {
				// Default Vars
				var pi2 = Math.PI / 2;
				var pi4 = Math.PI / 4;
				var pi8 = Math.PI / 8;
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / 5);
				var corner = 4; // number of corners of the cylinders
				var thick  = parseInt(size5 / 4); // thickness of the cylinders
				var vec_Fs = [0,1,2,3,4,14,24,34,33,23,13,12,22,32,31,21,11,10,20,30,40,41,42,43,44
					,144,244,344,343,243,143,142,242,342,341,241,141,140,240,340,330,230,130,120,220
					,320,310,210,110,111,211,311,321,221,121,131,231,331,332,232,132,122,222,322,312
					,212,112,113,213,313,323,223,123,133,233,333,334,234,134,124,224,324,314,214,114
					,104,204,304,303,203,103,102,202,302,301,201,101,100,200,300,400,401,402,403,404
					,414,424,434,433,423,413,412,422,432,431,421,411,410,420,430,440,441,442,443,444
					,444];
				var vec = vec_Fs;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];
				for ( i = 0; i < vec.length; i ++ ) {
					var digx5 = parseInt(vec[i] /  10) % 10 ;
					var digy5 =          vec[i]        % 10;
					var digz5 = parseInt(vec[i] / 100) % 10;
					// digits run from 0 to 4 or -2 to +2
					var x = center.x + (digx5 - 2) * size5;
					var y = center.y + (digy5 - 2) * size5;
					var z = center.z + (digz5 - 2) * size5;
					points.push(new THREE.Vector3(x, y, z));
					if (false) { // with annotation: node values
						var geometry = new THREE.TextGeometry( vec[i],
							{ font: myfont
							, size: 6
							, height: 1
							, curveSegments: 8
							} );
						var mesh = new THREE.Mesh( geometry, materials );
						mesh.position.x = x + thick;
						mesh.position.y = y + thick;
						mesh.position.z = z + thick;
						var group = new THREE.Group();
						group.add( mesh );
						scene.add( group );
					} // node values
				} // for i
				var shift = (size5 - thick) * 0.5;
				for ( i = 0; i < points.length - 1; i ++ ) {
				//var geometry = new THREE.BoxGeometry( thick, size5, thick );
					var geometry = new THREE.BoxGeometry( thick, thick, thick );
					var diff = vec[i + 1] - vec[i]; // either +-1, +-10 or +-100
					var adiff = diff;
					if (adiff < 0) {
						adiff = - adiff;
					}
					if (false) {
					} else if (diff ==  -10) { // move in +x
						geometry.rotateZ(  pi2);
						geometry.translate(- shift, 0, 0);
					} else if (diff ==  +10) { // move in -x
						geometry.rotateZ(- pi2);
						geometry.translate(+ shift, 0, 0);
					} else if (diff ==    1) { // move in +y
						geometry.rotateZ(pi2 -  pi2);
						geometry.translate(0, + shift, 0);
					} else if (diff ==   -1) { // move in -y
						geometry.rotateZ(pi2 + pi2);
						geometry.translate(0, - shift, 0);
					} else if (diff ==  100) { // move in +z
						geometry.rotateX(+ pi2);
						geometry.translate(0, 0, + shift);
					} else if (diff == -100) { // move in -z
						geometry.rotateX(- pi2);
						geometry.translate(0, 0, - shift);
					} else if (diff ==    0) { // last vertex
						geometry = new THREE.BoxGeometry( thick, thick, thick );
					}
					geometry.translate
						( points[i].x
						, points[i].y
						, points[i].z);
					if (true) { // with edges
						var edges = new THREE.EdgesGeometry( geometry );
						var line = new THREE.LineSegments( edges, new THREE.LineBasicMaterial( { color: 0xffffff } ) );
						scene.add( line );
					}
					// color gradient
					var color3 = new THREE.Color( 0xffffff );
					//color3.setHSL( i * 0.8 / points.length, 1.0, 0.5 ); 
					var opac =  i / points.length; // 0.5
					var material = new THREE.MeshBasicMaterial(
						{ color: color3
						, alphaMap: 0x000000
					//	, emissive: color3
					//, flatShading: true
						, opacity: opac
						, transparent: true
					//	, wireframe: true
						} ); // 0x0000ff} );
					var mesh = new THREE.Mesh( geometry, material );
					scene.add( mesh );
				} // for i
			} // world
