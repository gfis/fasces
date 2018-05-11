/**
	@(#) $Id$
	Turning meander cube 4m
	2018-05-10, Georg Fischer
	with THREE.BoxGeometry
*/
			function world( scene, myfont ) {
				// Default Vars
				var base = 4;
				var group = new THREE.Group();
				var pi2 = Math.PI / 2;
				var center = new THREE.Vector3( 0, 0, 0 );
				var size   = 300;
				var size5  = parseInt(size / base );
				var width  = parseInt(size5 / 2 / base); // thickness of the cylinders
				var vec_4m 
   = [0,1,2,3,13,12,11,10,20,21,22,23,33,32,31,30 // leading zeroes would mean octal
     ,130,131,132,133
     ,233,232,231,230
     ,330,331,332,333
     ,323,322,321,320
     ,220,221,222,223
     ,123,122,121,120
     ,110,111,112,113
     ,213,212,211,210
     ,310,311,312,313
     ,303,302,301,300
     ,200,201,202,203
     ,103,102,101,100
     ,100];
				var vec_4n 
   = [0,1,2,3,13,12,11,10,20,21,22,23,33,32,31,30 // leading zeroes would mean octal
     ,130,131,132,133,123,122,121,120,110,111,112,113,103,102,101,100
     ,200,201,202,203,213,212,211,210,220,221,222,223,233,232,231,230
     ,330,331,332,333,323,322,321,320,310,311,312,313,303,302,301,300
     ,300];
				var vec = vec_4n;
				var materials = [
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } ),
					new THREE.MeshBasicMaterial( { color: 0xffffff, overdraw: 0.5 } )
					];
				var points = [];
				var dvals  = [];	
				var sub5   = (base - 1) / 2;
				for ( i = 0; i < vec.length; i ++ ) {
					var digx5 = parseInt(vec[i] /  10) % 10;
					var digy5 =          vec[i]        % 10;
					var digz5 = parseInt(vec[i] / 100) % 10;
					// dvals.push(digz5 * base * base + digx5 * base + digy5); // decimal
					// digits run from 0 to 4 or -2 to +2
					var x = center.x + (digx5 - sub5) * size5;
					var y = center.y + (digy5 - sub5) * size5;
					var z = center.z + (digz5 - sub5) * size5;
					points.push(new THREE.Vector3(x, y, z));
				} // for i
				var shift = (size5 - width) * 0.5;
				for ( i = 0; i < points.length - 1; i ++ ) {
					var geometry = new THREE.BoxGeometry( width, size5, width );
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
					} else if (diff ==    0) { // last vertex - a small cube only
						geometry = new THREE.BoxGeometry( width, width, width );
					}	
					geometry.translate( points[i].x, points[i].y, points[i].z);
					if (true) { // with edges
						var edges = new THREE.EdgesGeometry( geometry );
						var line = new THREE.LineSegments( edges, new THREE.LineBasicMaterial( { color: 0xffffff } ) );
						group.add( line );
					}
					var color3 = new THREE.Color( 0xffffff );
					color3.setHSL( i * 0.8 / points.length, 1.0, 0.5 );
					var material = new THREE.MeshBasicMaterial( 
						{ color: color3
						, alphaMap: 0x000000
					//	, emissive: color3
						, flatShading: true
					//	, opacity: 0.5
					//	, wireframe: true
						} ); // 0x0000ff} );
					var mesh = new THREE.Mesh( geometry, material );
					group.add( mesh  );

					if (true) { // with annotation: node values
						var geometry2 = new THREE.TextGeometry(vec[i], // for base 4
							{ font: myfont
							, size:   8
							, height: 2
							, curveSegments: 8
							} );
						geometry2.translate
								( points[i].x + width
								, points[i].y + width
								, points[i].z + width
								);
						var mesh2 = new THREE.Mesh( geometry2, materials );
						group.add( mesh2 );
						scene.add( group );
					} // node values
					scene.add( group );

				} // for i 
				if (false) { // with label
						var geometry2 = new THREE.TextGeometry( "OEIS A220952",
							{ font: myfont
							, size:   16
							, height: 4
							, curveSegments: 8
							} );
						var plab = points[108];
						geometry2.translate
								( plab.x - 2.7 * size5
								, plab.y + 0.4 * size5
								, plab.z - 0.0 * size5
								);
						var mesh2 = new THREE.Mesh( geometry2, materials );
						group.add( mesh2 );
						scene.add( group );
				} // node values
				scene.add( group );
			} // world
